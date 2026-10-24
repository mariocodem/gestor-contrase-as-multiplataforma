import 'package:boveda_domain/boveda_domain.dart';
import 'package:boveda_presentation/boveda_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fakes.dart';

const _user = User(id: 'u1', email: 'ana@correo.es');

/// Lets streams deliver and the 460 ms state transitions finish, without waiting on endless
/// animations (the loading bar, the placeholders' pulse).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('signed out, the app asks for the account', (tester) async {
    await tester.pumpWidget(BovedaApp(dependencies: fakeDependencies(auth: FakeAuthRepository())));
    await settle(tester);

    expect(find.text(S.authSubtitleSignIn), findsOneWidget);
    expect(find.text(S.authSignIn), findsOneWidget);

    await tester.tap(find.text(S.authSwitchToRegister));
    await settle(tester);
    expect(find.text(S.authRegister), findsOneWidget);
  });

  testWidgets('a wrong master password is refused, the right one opens the vault', (tester) async {
    final vault = FakeVaultRepository(
      unlockedFor: null,
      entries: const [
        VaultEntry(id: 'e1', title: 'Banco', username: 'ana', password: 'p4ss-del-banco'),
        VaultEntry(id: 'e2', title: 'Correo', username: 'ana@correo.es', password: 'otra'),
      ],
    );
    final clipboard = FakeClipboard(systemConfirmsCopies: false);
    await tester.pumpWidget(
      BovedaApp(dependencies: fakeDependencies(auth: FakeAuthRepository(_user), vault: vault, clipboard: clipboard)),
    );
    await settle(tester);
    expect(find.text(S.lockTitleLocked), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'no es esta');
    await tester.tap(find.text(S.lockUnlock));
    await settle(tester);
    expect(find.text(S.errorWrongMasterPassword), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'correcto-caballo-bateria');
    await tester.tap(find.text(S.lockUnlock));
    await settle(tester);

    expect(find.text(S.lockTitleLocked), findsNothing);
    expect(find.text('Banco'), findsOneWidget);
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text(S.vaultSearchCount(2)), findsOneWidget);

    // Into an entry: the detail shows the fields and copies from the thumb-reach button.
    await tester.tap(find.text('Banco'));
    await settle(tester);
    expect(find.text(S.detailUsername), findsOneWidget);
    expect(find.text('p4ss-del-banco'), findsNothing, reason: 'the password starts hidden');

    await tester.tap(find.text(S.detailCopyPassword));
    await settle(tester);
    expect(clipboard.secrets, ['p4ss-del-banco']);
    expect(find.text(S.copiedPassword(45)), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));

    // Back to the list, then lock: the lock screen returns.
    await tester.tap(find.byTooltip(S.back));
    await settle(tester);
    await tester.tap(find.byTooltip(S.lock));
    await settle(tester);
    expect(find.text(S.lockTitleLocked), findsOneWidget);
  });

  testWidgets('a new account creates its vault with a confirmed master password', (tester) async {
    final vault = FakeVaultRepository(unlockedFor: null, status: const VaultMissing());
    await tester.pumpWidget(BovedaApp(dependencies: fakeDependencies(auth: FakeAuthRepository(_user), vault: vault)));
    await settle(tester);
    expect(find.text(S.lockTitleSetup), findsOneWidget);
    expect(find.text(S.lockWarning), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'una frase larga y mia');
    await tester.enterText(fields.at(1), 'una frase larga y otra');
    await tester.tap(find.text(S.lockCreate));
    await settle(tester);
    expect(find.text(S.errorMasterPasswordMismatch), findsOneWidget);

    await tester.enterText(fields.at(1), 'una frase larga y mia');
    await tester.tap(find.text(S.lockCreate));
    await settle(tester);
    expect(find.text(S.vaultEmptyTitle), findsOneWidget);
  });

  testWidgets('wide windows get a navigation rail, and the generator tab works', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(BovedaApp(dependencies: fakeDependencies()));
    await settle(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text(S.navGenerator));
    await settle(tester);
    expect(find.text(S.generatorAssumption), findsOneWidget);
    expect(find.text(S.strengthVeryStrong), findsOneWidget);
  });
}
