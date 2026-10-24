import 'package:boveda_domain/boveda_domain.dart';
import 'package:test/test.dart';

import 'fake/fakes.dart';

void main() {
  group('vault and entries', () {
    late FakeVaultRepository vault;
    setUp(() => vault = FakeVaultRepository());

    test('creating a vault validates length and confirmation before touching it', () async {
      final create = CreateVaultUseCase(vault);

      expect((await create('u1', 'short', 'short')).errorOrNull, AppError.masterPasswordTooShort);
      expect(
        (await create('u1', 'long enough secret', 'long enough secrets')).errorOrNull,
        AppError.masterPasswordMismatch,
      );
      expect(vault.createdWith, isNull);

      expect((await create('u1', 'long enough secret', 'long enough secret')).isSuccess, isTrue);
      expect(vault.createdWith, 'long enough secret');
    });

    test('unlocking reports a wrong master password', () async {
      final unlock = UnlockVaultUseCase(vault);

      expect((await unlock('u1', 'nope')).errorOrNull, AppError.wrongMasterPassword);
      expect((await unlock('u1', '')).errorOrNull, AppError.emptyMasterPassword);
      expect((await unlock('u1', 'correct horse battery')).isSuccess, isTrue);
    });

    test('saving requires a name and trims everything but the password', () async {
      final save = SaveEntryUseCase(vault);

      expect((await save(const VaultEntry(title: '   '))).errorOrNull, AppError.emptyTitle);

      final saved = (await save(const VaultEntry(title: '  Banco ', username: ' ana ', password: ' p4ss ', url: ' banco.es ')))
          .valueOrThrow;
      expect(saved, VaultEntry(id: saved.id, title: 'Banco', username: 'ana', password: ' p4ss ', url: 'banco.es'));
    });

    test('entries are sorted ignoring case and accents, ñ after n', () async {
      await vault.unlock('u1', 'correct horse battery');
      for (final title in ['zeta', 'Ábaco', 'ñandú', 'banco', 'Álgebra', 'nube']) {
        await vault.save(VaultEntry(title: title));
      }

      final titles = (await ObserveEntriesUseCase(vault)().first).map((e) => e.title);
      expect(titles, ['Ábaco', 'Álgebra', 'banco', 'nube', 'ñandú', 'zeta']);
    });

    test('search matches title, username and site without accents', () {
      const entries = [
        VaultEntry(id: '1', title: 'Telefónica', username: 'ana'),
        VaultEntry(id: '2', title: 'Correo', username: 'ana@correo.es'),
        VaultEntry(id: '3', title: 'Banco', url: 'https://banco.example'),
        VaultEntry(id: '4', title: 'Ñu Exprés'),
      ];
      const search = SearchEntriesUseCase();

      expect(search(entries, 'telefonica').map((e) => e.id), ['1']);
      expect(search(entries, ' ANA ').map((e) => e.id), ['1', '2']);
      expect(search(entries, 'example').map((e) => e.id), ['3']);
      expect(search(entries, 'nu expres').map((e) => e.id), ['4']);
      expect(search(entries, ''), entries);
    });
  });

  group('account', () {
    test('registering checks the email and the account password length on the device', () async {
      final register = RegisterUseCase(FakeAuthRepository());

      expect((await register('', 'x')).errorOrNull, AppError.missingCredentials);
      expect((await register('ana', 'suficiente')).errorOrNull, AppError.invalidEmail);
      expect((await register('ana@correo.es', 'corta')).errorOrNull, AppError.weakAccountPassword);
      expect((await register(' ana@correo.es ', 'suficiente')).isSuccess, isTrue);
    });

    test('a reset needs an email', () async {
      final reset = SendPasswordResetUseCase(FakeAuthRepository());

      expect((await reset('  ')).errorOrNull, AppError.missingEmail);
      expect((await reset('ana@correo.es')).isSuccess, isTrue);
    });
  });

  group('app state', () {
    const user = User(id: 'u1', email: 'ana@example.com');
    late FakeAuthRepository auth;
    late FakeVaultRepository vault;
    late ObserveAppStateUseCase observeAppState;

    setUp(() {
      auth = FakeAuthRepository(user);
      vault = FakeVaultRepository();
      observeAppState = ObserveAppStateUseCase(auth, vault);
    });

    test('walks through setup, unlock, lock and sign out', () async {
      final states = <AppState>[];
      final subscription = observeAppState().listen(states.add);
      await pumpEventQueue();
      expect(states.last, const NeedsSetup(user));

      await vault.create(user.id, 'correct horse battery');
      await pumpEventQueue();
      expect(states.last, const Unlocked(user));

      vault.status.add(const VaultPresent());
      vault.lock();
      await pumpEventQueue();
      expect(states.last, const Locked(user));

      await auth.signOut();
      await pumpEventQueue();
      expect(states.last, const SignedOut());
      await subscription.cancel();
    });

    test('a key unlocked for another user does not unlock this one', () async {
      vault.status.add(const VaultPresent());
      await vault.unlock('someone-else', 'correct horse battery');

      expect(await observeAppState().first, const Locked(user));
    });

    test('backend failures surface as a failed state', () async {
      vault.status.add(const VaultStatusFailed(AppError.network));

      expect(await observeAppState().first, const AppFailed(AppError.network));
    });
  });
}
