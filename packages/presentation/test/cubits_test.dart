import 'package:boveda_domain/boveda_domain.dart';
import 'package:boveda_presentation/src/common/search_highlight.dart';
import 'package:boveda_presentation/src/generator/generator_cubit.dart';
import 'package:boveda_presentation/src/lock/lock_cubit.dart';
import 'package:boveda_presentation/src/vault/detail/entry_detail_cubit.dart';
import 'package:boveda_presentation/src/vault/editor/entry_editor_cubit.dart';
import 'package:boveda_presentation/src/vault/list/vault_list_cubit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('generator', () {
    late FakeSettingsRepository settings;
    late FakeClipboard clipboard;
    late GeneratorCubit cubit;

    setUp(() async {
      settings = FakeSettingsRepository(const AppSettings(generatorOptions: PasswordOptions(length: 12, symbols: false)));
      clipboard = FakeClipboard();
      cubit = GeneratorCubit(fakeDependencies(settings: settings, clipboard: clipboard));
      await pumpEventQueue();
    });

    tearDown(() => cubit.close());

    test('starts from the remembered options', () {
      expect(cubit.state.options, const PasswordOptions(length: 12, symbols: false));
      expect(cubit.state.password?.value, hasLength(12));
      expect(cubit.state.password!.value.codeUnits.every(isLetterOrDigitUnit), isTrue);
    });

    test('dragging the length regenerates live but saves only when the drag ends', () {
      cubit
        ..onLengthChange(30)
        ..onLengthChange(31);

      expect(cubit.state.password?.value, hasLength(31));
      expect(settings.savedOptions, isEmpty);

      cubit.onLengthChangeFinished();
      expect(settings.savedOptions.single.length, 31);
    });

    test('the last character set cannot be turned off', () {
      cubit
        ..onUppercaseChange(false)
        ..onDigitsChange(false)
        ..onLowercaseChange(false);

      expect(cubit.state.options.enabledSetCount, 1);
      expect(cubit.state.options.lowercase, isTrue);
    });

    test('regenerate keeps the options and changes the password', () {
      final before = cubit.state;

      cubit.regenerate();

      expect(cubit.state.options, before.options);
      expect(cubit.state.password?.value, isNot(before.password?.value));
    });

    test('copy puts the secret on the clipboard and says when it clears', () async {
      final message = cubit.messages.first;

      await cubit.copy();

      expect(clipboard.secrets, [cubit.state.password!.value]);
      expect(await message, contains('45 s'));
    });
  });

  group('entry editor', () {
    const existing = VaultEntry(id: 'e1', title: 'Banco', username: 'ana', password: '123456');
    late FakeVaultRepository vault;

    setUp(() => vault = FakeVaultRepository(entries: [existing]));

    test('a new entry needs a name before it can be saved', () {
      final cubit = EntryEditorCubit(fakeDependencies(vault: vault), null)..onPasswordChange('x');
      expect(cubit.state.canSave, isFalse);

      cubit.onTitleChange('Correo');
      expect(cubit.state.canSave, isTrue);
    });

    test('saving a new entry reports its id and that it was new', () async {
      final cubit = EntryEditorCubit(fakeDependencies(vault: vault), null)
        ..onTitleChange('Correo')
        ..onPasswordChange('s3creto-largo!');
      final event = cubit.events.first;

      await cubit.save();

      final saved = await event as EditorSaved;
      expect(saved.wasNew, isTrue);
      expect(vault.entries.value.singleWhere((e) => e.id == saved.id).title, 'Correo');
    });

    test('editing loads the entry and rates its password', () async {
      final cubit = EntryEditorCubit(fakeDependencies(vault: vault), 'e1');
      await pumpEventQueue();

      expect(cubit.state.isNew, isFalse);
      expect(cubit.state.draft, existing);
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.strength.level, StrengthLevel.veryWeak);

      cubit.onPasswordChange('q7Rk2mZp9xLw4nVb!');
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.strength.level, StrengthLevel.veryStrong);
    });

    test('editing an entry that no longer exists closes', () async {
      final cubit = EntryEditorCubit(fakeDependencies(vault: vault), 'gone');

      expect(await cubit.events.first, isA<EditorGone>());
    });
  });

  group('vault list', () {
    late FakeVaultRepository vault;
    late FakeClipboard clipboard;
    late VaultListCubit cubit;

    setUp(() async {
      vault = FakeVaultRepository(
        entries: const [
          VaultEntry(id: '1', title: 'Telefónica', username: 'ana', password: 'a'),
          VaultEntry(id: '2', title: 'banco', url: 'https://www.banco.es/login', password: 'b'),
          VaultEntry(id: '3', title: 'Correo', username: 'ana@correo.es'),
        ],
      );
      clipboard = FakeClipboard();
      cubit = VaultListCubit(fakeDependencies(vault: vault, clipboard: clipboard));
      await pumpEventQueue();
    });

    tearDown(() => cubit.close());

    test('lists entries sorted without exposing passwords', () {
      expect(cubit.state.items, const [
        EntryListItem(id: '2', title: 'banco', subtitle: 'banco.es', hasPassword: true),
        EntryListItem(id: '3', title: 'Correo', subtitle: 'ana@correo.es', hasPassword: false),
        EntryListItem(id: '1', title: 'Telefónica', subtitle: 'ana', hasPassword: true),
      ]);
      expect(cubit.state.totalCount, 3);
    });

    test('search filters but keeps the total', () {
      cubit.onQueryChange('telefonica');

      expect(cubit.state.items.map((item) => item.id), ['1']);
      expect(cubit.state.totalCount, 3);
    });

    test('copying from the list uses the stored password', () async {
      final message = cubit.messages.first;

      await cubit.copyPassword('2');

      expect(clipboard.secrets, ['b']);
      await message;
    });

    test('pull to refresh asks the vault to sync', () async {
      await cubit.refresh();

      expect(vault.syncs, 1);
    });
  });

  group('lock', () {
    late LockCubit cubit;

    setUp(() async {
      cubit = LockCubit(fakeDependencies(), const User(id: 'u1', email: 'ana@correo.es'));
      await cubit.biometricsKnown;
    });

    test('every failed attempt counts as a new rejection', () async {
      await cubit.submit(isSetup: false);
      await cubit.submit(isSetup: false);

      expect(cubit.state.rejections, 2);
      expect(cubit.state.error, isNotNull);
      expect(cubit.state.isWorking, isFalse);
    });

    test('typing clears the error but keeps the count', () async {
      await cubit.submit(isSetup: false);
      cubit.onPasswordChange('c');

      expect(cubit.state.rejections, 1);
      expect(cubit.state.error, isNull);
    });

    test('unlocking starts the next lock screen from zero and forgets the password', () async {
      await cubit.submit(isSetup: false);
      cubit.onPasswordChange('correcto-caballo-bateria');
      await cubit.submit(isSetup: false);

      expect(cubit.state.rejections, 0);
      expect(cubit.state.password, isEmpty);
    });
  });

  group('entry detail', () {
    final vault = FakeVaultRepository(entries: const [VaultEntry(id: 'e1', title: 'Banco', username: 'ana', password: '123456')]);

    test('an entry already decrypted shows before anything arrives', () {
      final state = EntryDetailCubit(fakeDependencies(vault: vault), 'e1').state;

      expect(state, isA<DetailLoaded>());
      expect((state as DetailLoaded).entry.title, 'Banco');
    });

    test('an unknown entry waits for the vault, then says it is gone', () async {
      final cubit = EntryDetailCubit(fakeDependencies(vault: vault), 'nope');
      expect(cubit.state, isA<DetailLoading>());

      await pumpEventQueue();
      expect(cubit.state, isA<DetailMissing>());
    });
  });

  group('search highlight', () {
    List<String> bold(String text, String query) => [
          for (final span in highlightMatches(text, query).children ?? const <InlineSpan>[])
            if (span is TextSpan && span.style?.fontWeight == FontWeight.w700) span.text!,
        ];

    test('marks why a row matched', () => expect(bold('ana@correo.es', 'co'), ['co']));

    test('ignores case and accents like the search', () => expect(bold('Telefónica', 'TELEFONICA'), ['Telefónica']));

    test('marks every occurrence and nothing for a blank query', () {
      expect(bold('aba', 'a'), ['a', 'a']);
      expect(bold('Banco', '  '), isEmpty);
    });
  });
}
