import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:rxdart/rxdart.dart';

import '../crypto/entry_codec.dart';
import '../crypto/vault_crypto.dart';
import '../local/vault_cache.dart';
import '../remote/boveda_api.dart';
import '../session/vault_session.dart';

/// The vault on Cloudflare D1, through the Worker, with this device's encrypted copy in front of
/// it: the list opens from the copy, writes land in it at once and queue for the server, and a sync
/// (on unlock, every [pollInterval] while unlocked, on demand) pushes the queue and pulls what
/// other devices changed. Only ciphertext is ever stored or sent.
class VaultRepositoryImpl implements VaultRepository {
  VaultRepositoryImpl({
    required this._api,
    required this._cache,
    required this._session,
    required VaultCrypto crypto,
    this.pollInterval = const Duration(seconds: 30),
    int Function()? clock,
    Random? random,
  })  : _crypto = crypto,
        _codec = EntryCodec(crypto),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _random = random ?? Random.secure() {
    _session.addListener(_onVaultChanged);
  }

  final BovedaApi _api;
  final VaultCache _cache;
  final VaultSession _session;
  final VaultCrypto _crypto;
  final EntryCodec _codec;
  final int Function() _clock;
  final Random _random;
  final Duration pollInterval;

  final Map<String, BehaviorSubject<VaultStatus>> _statuses = {};
  _VaultEngine? _engine;
  final _engines = BehaviorSubject<_VaultEngine?>.seeded(null);

  @override
  Stream<VaultStatus> observeStatus(String userId) => Rx.defer(() {
        final subject = _statuses.putIfAbsent(userId, BehaviorSubject.new);
        final current = subject.valueOrNull;
        if (current == null || current is VaultStatusFailed) {
          // Replaces a failure at once, so a retry never sees the old one.
          subject.add(const VaultStatusLoading());
          unawaited(_loadStatus(userId, subject));
        }
        return subject.stream;
      });

  /// The device's copy answers first (so the lock screen works offline); the server is only asked
  /// when there's no copy yet.
  Future<void> _loadStatus(String userId, BehaviorSubject<VaultStatus> subject) async {
    final cached = await _cache.load(userId);
    if (cached.meta != null) {
      subject.add(const VaultPresent());
      return;
    }
    try {
      final meta = await _api.getVault();
      if (meta == null) {
        subject.add(const VaultMissing());
      } else {
        cached.meta = meta;
        await _cache.save(userId, cached);
        subject.add(const VaultPresent());
      }
    } on AppException catch (e) {
      subject.add(VaultStatusFailed(e.error));
    }
  }

  @override
  Stream<String?> get unlockedUserId => _session.userId;

  @override
  Future<void> create(String userId, String masterPassword) async {
    final salt = _crypto.newSalt();
    const iterations = VaultCrypto.defaultIterations;
    final passwordKey = await _crypto.deriveKey(masterPassword, salt, iterations);
    final vaultKey = _crypto.newVaultKey();
    final wrapped = await _crypto.wrapKey(passwordKey, vaultKey);
    final meta = VaultMetaDto(salt: base64.encode(salt), iterations: iterations, wrappedKey: base64.encode(wrapped));
    await _api.createVault(meta);
    final cached = await _cache.load(userId);
    cached.meta = meta;
    await _cache.save(userId, cached);
    _statuses.putIfAbsent(userId, BehaviorSubject.new).add(const VaultPresent());
    _session.open(userId, vaultKey);
  }

  @override
  Future<void> unlock(String userId, String masterPassword) async {
    final cached = await _cache.load(userId);
    var meta = cached.meta;
    if (meta == null) {
      meta = await _api.getVault();
      if (meta == null) throw const AppException(AppError.vaultDataCorrupted);
      cached.meta = meta;
      await _cache.save(userId, cached);
    }
    final passwordKey = await _crypto.deriveKey(masterPassword, base64.decode(meta.salt), meta.iterations);
    try {
      _session.open(userId, await _crypto.unwrapKey(passwordKey, base64.decode(meta.wrappedKey)));
    } on CiphertextRejected catch (e) {
      throw AppException(AppError.wrongMasterPassword, e);
    }
  }

  @override
  void lock() => _session.close();

  void _onVaultChanged(UnlockedVault? vault) {
    _engine?.dispose();
    _engine = vault == null
        ? null
        : _VaultEngine(
            vault: vault,
            api: _api,
            cache: _cache,
            session: _session,
            codec: _codec,
            clock: _clock,
            newId: _newEntryId,
            pollInterval: pollInterval,
          );
    _engines.add(_engine);
  }

  @override
  Stream<List<VaultEntry>> observeEntries() =>
      _engines.switchMap((engine) => engine == null ? Stream.value(const <VaultEntry>[]) : engine.entries);

  @override
  List<VaultEntry>? get lastKnownEntries {
    final vault = _session.current;
    return vault == null ? null : _session.entriesOf(vault);
  }

  @override
  Future<VaultEntry> save(VaultEntry entry) {
    final engine = _engine;
    if (engine == null) throw const AppException(AppError.vaultLocked);
    return engine.save(entry);
  }

  @override
  Future<void> delete(String id) {
    final engine = _engine;
    if (engine == null) throw const AppException(AppError.vaultLocked);
    return engine.delete(id);
  }

  @override
  Future<void> sync() async => _engine?.sync(reportErrors: true);

  /// 20 alphanumeric characters, the shape of the Firestore ids the Android app used.
  String _newEntryId() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(List.generate(20, (_) => alphabet.codeUnitAt(_random.nextInt(alphabet.length))));
  }
}

/// One unlocked vault's entries and sync loop; lives exactly as long as the key is in memory.
class _VaultEngine {
  _VaultEngine({
    required this.vault,
    required this.api,
    required this.cache,
    required this.session,
    required this.codec,
    required this.clock,
    required this.newId,
    required Duration pollInterval,
  }) {
    final known = session.entriesOf(vault);
    if (known != null) _entries.add(known);
    _loaded = _load();
    unawaited(_loaded.then((_) => sync()));
    _poll = Timer.periodic(pollInterval, (_) => sync());
  }

  final UnlockedVault vault;
  final BovedaApi api;
  final VaultCache cache;
  final VaultSession session;
  final EntryCodec codec;
  final int Function() clock;
  final String Function() newId;

  final _entries = BehaviorSubject<List<VaultEntry>>();
  /// The device's copy is in memory; writes wait for this, never for the network.
  late final Future<void> _loaded;
  late final Timer _poll;
  CachedVault _copy = CachedVault();

  /// Decryptions by entry id, kept with the ciphertext they came from.
  final Map<String, (String, VaultEntry?)> _decrypted = {};
  Future<void>? _syncing;
  var _disposed = false;

  Stream<List<VaultEntry>> get entries => _entries.stream;

  Future<void> _load() async {
    _copy = await cache.load(vault.uid);
    if (_disposed) return;
    if (_copy.rows.isNotEmpty || _copy.revision > 0) await _publish();
  }

  /// Pushes queued writes (in chunks the Worker accepts) and pulls what changed. Calls made while
  /// one runs join it. Failures stay quiet while there's a copy to show, unless [reportErrors].
  Future<void> sync({bool reportErrors = false}) async {
    if (_disposed) return;
    await _loaded;
    final running = _syncing ??= _sync().whenComplete(() => _syncing = null);
    try {
      await running;
    } on AppException catch (e) {
      if (reportErrors) rethrow;
      // Nothing decrypted yet (first unlock on this device, offline): the list shows the error.
      if (!_entries.hasValue && !_disposed) _entries.addError(e);
    }
  }

  Future<void> _sync() async {
    do {
      final batch = _copy.pending.take(BovedaApi.maxChangesPerSync).toList();
      final response = await api.sync(_copy.revision, batch);
      if (_disposed) return;
      _copy.pending.removeWhere((change) => batch.any((sent) => identical(sent, change)));
      if (response.reset) {
        final local = {for (final change in _copy.pending) change.id};
        _copy.rows.removeWhere((id, _) => !local.contains(id));
      }
      // A change still queued here is newer than what the server just echoed.
      final queued = {for (final change in _copy.pending) change.id};
      for (final row in response.entries) {
        if (queued.contains(row.id)) continue;
        if (row.deleted || row.data == null) {
          _copy.rows.remove(row.id);
        } else {
          _copy.rows[row.id] = row.data!;
        }
      }
      _copy.revision = response.revision;
      await cache.save(vault.uid, _copy);
      await _publish();
    } while (_copy.pending.isNotEmpty && !_disposed);
  }

  Future<VaultEntry> save(VaultEntry entry) async {
    await _loaded;
    final id = entry.id.isEmpty ? newId() : entry.id;
    final saved = entry.copyWith(id: id, updatedAt: clock());
    final data = base64.encode(await codec.encode(saved, vault.key));
    _queue(ChangeDto.put(id, data));
    _copy.rows[id] = data;
    _decrypted[id] = (data, saved);
    await cache.save(vault.uid, _copy);
    await _publish();
    unawaited(sync());
    return saved;
  }

  Future<void> delete(String id) async {
    await _loaded;
    _queue(ChangeDto.delete(id));
    _copy.rows.remove(id);
    _decrypted.remove(id);
    await cache.save(vault.uid, _copy);
    await _publish();
    unawaited(sync());
  }

  /// Only the newest write per entry needs to reach the server.
  void _queue(ChangeDto change) {
    _copy.pending
      ..removeWhere((queued) => queued.id == change.id)
      ..add(change);
  }

  Future<void> _publish() async {
    final result = <VaultEntry>[];
    for (final MapEntry(key: id, value: data) in _copy.rows.entries.toList()) {
      final known = _decrypted[id];
      VaultEntry? entry;
      if (known != null && known.$1 == data) {
        entry = known.$2;
      } else {
        entry = await codec.decode(id, base64.decode(data), vault.key);
        _decrypted[id] = (data, entry);
      }
      if (entry != null) result.add(entry);
    }
    _decrypted.removeWhere((id, _) => !_copy.rows.containsKey(id));
    if (_disposed) return;
    session.rememberEntries(vault, result);
    _entries.add(result);
  }

  void dispose() {
    _disposed = true;
    _poll.cancel();
    _decrypted.clear();
    unawaited(_entries.close());
  }
}
