import 'package:boveda_data/boveda_data.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';

void main() {
  const uid = 'u1';
  const master = 'correct horse battery staple';
  late FakeServer server;
  late VaultSession session;
  late VaultCrypto crypto;
  late VaultCache cache;

  VaultRepositoryImpl repository() => VaultRepositoryImpl(
        api: BovedaApi(baseUrl: Uri.parse('https://boveda.test'), token: () => 'token-1', client: server.client),
        cache: cache,
        session: session,
        crypto: crypto,
        pollInterval: const Duration(hours: 1),
      );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    server = FakeServer();
    session = VaultSession();
    crypto = VaultCrypto(pbkdf2: dartPbkdf2);
    cache = VaultCache();
  });

  Future<List<String>> titles(VaultRepository vault) async =>
      (await vault.observeEntries().firstWhere((entries) => entries.isNotEmpty)).map((e) => e.title).toList()..sort();

  test('a new account has no vault; creating one unlocks it and reports it present', () async {
    final vault = repository();
    expect(await vault.observeStatus(uid).firstWhere((s) => s is! VaultStatusLoading), const VaultMissing());

    await vault.create(uid, master);

    expect(await vault.unlockedUserId.first, uid);
    expect(await vault.observeStatus(uid).first, const VaultPresent());
    expect(server.vault?['kdfIterations'], VaultCrypto.defaultIterations);
  });

  test('saved entries show at once and reach the server as ciphertext only', () async {
    final vault = repository();
    await vault.create(uid, master);

    final saved = await vault.save(const VaultEntry(title: 'Banco', username: 'ana', password: 's3creto!'));
    expect(saved.id, hasLength(20));
    expect(await titles(vault), ['Banco']);

    await vault.sync();
    final stored = server.rows[saved.id]!.data!;
    expect(stored, isNot(contains('s3creto')));
    expect(stored, isNot(contains('Banco')));
  });

  test('writes made offline queue on the device and go out on the next sync', () async {
    final vault = repository();
    await vault.create(uid, master);
    server.offline = true;

    await vault.save(const VaultEntry(title: 'Sin red'));
    expect(await titles(vault), ['Sin red']);
    expect((await cache.load(uid)).pending, hasLength(1));
    await expectLater(vault.sync(), throwsA(isA<AppException>().having((e) => e.error, 'error', AppError.network)));

    server.offline = false;
    await vault.sync();
    expect((await cache.load(uid)).pending, isEmpty);
    expect(server.rows.values.where((row) => !row.deleted), hasLength(1));
  });

  test('changes and deletions from another device arrive on sync', () async {
    final phone = repository();
    await phone.create(uid, master);
    final first = await phone.save(const VaultEntry(title: 'Correo'));
    await phone.save(const VaultEntry(title: 'Banco'));
    await phone.sync();

    // The laptop: another session and cache over the same server.
    final laptopSession = VaultSession();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    final laptop = VaultRepositoryImpl(
      api: BovedaApi(baseUrl: Uri.parse('https://boveda.test'), token: () => 'token-1', client: server.client),
      cache: VaultCache(),
      session: laptopSession,
      crypto: crypto,
      pollInterval: const Duration(hours: 1),
    );
    await laptop.unlock(uid, master);
    expect(await titles(laptop), ['Banco', 'Correo']);

    await laptop.delete(first.id);
    await laptop.sync();
    await phone.sync();
    expect(await titles(phone), ['Banco']);
  });

  test('the vault unlocks offline from the device copy, and a wrong master password is rejected', () async {
    final vault = repository();
    await vault.create(uid, master);
    await vault.save(const VaultEntry(title: 'Banco'));
    await vault.sync();
    vault.lock();
    server.offline = true;

    await expectLater(
      vault.unlock(uid, 'not the password'),
      throwsA(isA<AppException>().having((e) => e.error, 'error', AppError.wrongMasterPassword)),
    );
    await vault.unlock(uid, master);
    expect(await titles(vault), ['Banco']);
  });

  test('with no copy and no connection the status says so, and retrying recovers', () async {
    server.vault = {'kdfIterations': 600000, 'salt': 'AAAAAAAAAAAAAAAAAAAAAA==', 'wrappedKey': 'AA=='};
    server.offline = true;
    final vault = repository();

    expect(
      await vault.observeStatus(uid).firstWhere((s) => s is! VaultStatusLoading),
      const VaultStatusFailed(AppError.network),
    );
    server.offline = false;
    expect(await vault.observeStatus(uid).firstWhere((s) => s is! VaultStatusLoading), const VaultPresent());
  });

  test('locking drops the entries', () async {
    final vault = repository();
    await vault.create(uid, master);
    await vault.save(const VaultEntry(title: 'Banco'));

    vault.lock();

    expect(await vault.observeEntries().first, isEmpty);
    expect(vault.lastKnownEntries, isNull);
  });
}
