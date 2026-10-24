import 'dart:typed_data';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:rxdart/rxdart.dart';

class UnlockedVault {
  UnlockedVault(this.uid, this.key);

  final String uid;

  /// The raw 256-bit vault key.
  final Uint8List key;
}

/// The decrypted vault key, and what it last decrypted, held in memory only while the vault is unlocked.
class VaultSession {
  final _vault = BehaviorSubject<UnlockedVault?>.seeded(null);
  final _listeners = <void Function(UnlockedVault?)>[];
  (UnlockedVault, List<VaultEntry>)? _decrypted;

  /// Called synchronously on every open and close, before [vault]'s stream delivers the change.
  void addListener(void Function(UnlockedVault? vault) listener) => _listeners.add(listener);

  Stream<UnlockedVault?> get vault => _vault.stream;

  Stream<String?> get userId => _vault.stream.map((vault) => vault?.uid).distinct();

  UnlockedVault? get current => _vault.value;

  void open(String uid, Uint8List key) {
    _close();
    _publish(UnlockedVault(uid, key));
  }

  void close() {
    if (_vault.value == null) return;
    _close();
    _publish(null);
  }

  void _publish(UnlockedVault? vault) {
    // The subject's value updates synchronously; its stream delivers on a later microtask.
    _vault.add(vault);
    for (final listener in _listeners) {
      listener(vault);
    }
  }

  void _close() {
    // Overwrite the key bytes we own; Dart can't promise no other copy exists, but don't leave this one.
    _vault.value?.key.fillRange(0, _vault.value!.key.length, 0);
    _decrypted = null;
  }

  /// Keeps [entries] as the latest decryption of [vault], unless that vault has been closed since.
  void rememberEntries(UnlockedVault vault, List<VaultEntry> entries) {
    if (identical(_vault.value, vault)) _decrypted = (vault, entries);
  }

  /// The entries last decrypted with [vault]'s key, or null if none yet or it's no longer open.
  List<VaultEntry>? entriesOf(UnlockedVault vault) {
    final decrypted = _decrypted;
    return decrypted != null && identical(decrypted.$1, vault) ? decrypted.$2 : null;
  }
}
