import 'package:boveda_domain/boveda_domain.dart';
import 'package:boveda_presentation/boveda_presentation.dart';
import 'package:rxdart/rxdart.dart';

class FakeClipboard implements SecretClipboard {
  FakeClipboard({this.systemConfirmsCopies = true});

  @override
  final bool systemConfirmsCopies;
  final secrets = <String>[];
  final plain = <String>[];

  @override
  Future<void> copySecret(String label, String text) async => secrets.add(text);

  @override
  Future<void> copyPlain(String label, String text) async => plain.add(text);
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([AppSettings initial = const AppSettings()]) : state = BehaviorSubject.seeded(initial);

  final BehaviorSubject<AppSettings> state;
  final savedOptions = <PasswordOptions>[];

  @override
  Stream<AppSettings> get settings => state.stream;

  @override
  Future<void> setAutoLock(AutoLockTimeout timeout) async => state.add(state.value.copyWith(autoLock: timeout));

  @override
  Future<void> setDynamicColor(bool enabled) async => state.add(state.value.copyWith(dynamicColor: enabled));

  @override
  Future<void> setGeneratorOptions(PasswordOptions options) async {
    savedOptions.add(options);
    state.add(state.value.copyWith(generatorOptions: options));
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([User? user]) : user = BehaviorSubject.seeded(user);

  final BehaviorSubject<User?> user;

  @override
  Stream<User?> get currentUser => user.stream;

  @override
  Future<void> signIn(String email, String password) async {
    if (password != 'cuenta-correcta') throw const AppException(AppError.invalidCredentials);
    user.add(User(id: 'u1', email: email));
  }

  @override
  Future<void> register(String email, String password) async => user.add(User(id: 'u1', email: email));

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => user.add(null);
}

/// An in-memory vault; unlocked from the start unless told otherwise.
class FakeVaultRepository implements VaultRepository {
  FakeVaultRepository({
    List<VaultEntry> entries = const [],
    VaultStatus status = const VaultPresent(),
    String? unlockedFor = 'u1',
    this.masterPassword = 'correcto-caballo-bateria',
  })  : entries = BehaviorSubject.seeded(entries),
        status = BehaviorSubject.seeded(status),
        _unlocked = BehaviorSubject.seeded(unlockedFor);

  final BehaviorSubject<List<VaultEntry>> entries;
  final BehaviorSubject<VaultStatus> status;
  final BehaviorSubject<String?> _unlocked;
  final String masterPassword;
  var syncs = 0;
  var _nextId = 100;

  @override
  Stream<VaultStatus> observeStatus(String userId) => status.stream;

  @override
  Stream<String?> get unlockedUserId => _unlocked.stream;

  @override
  Future<void> create(String userId, String masterPassword) async {
    status.add(const VaultPresent());
    _unlocked.add(userId);
  }

  @override
  Future<void> unlock(String userId, String masterPassword) async {
    if (masterPassword != this.masterPassword) throw const AppException(AppError.wrongMasterPassword);
    _unlocked.add(userId);
  }

  @override
  void lock() => _unlocked.add(null);

  @override
  Stream<List<VaultEntry>> observeEntries() =>
      Rx.combineLatest2(entries, _unlocked, (all, id) => id == null ? const <VaultEntry>[] : all);

  @override
  List<VaultEntry>? get lastKnownEntries => _unlocked.value == null ? null : entries.value;

  @override
  Future<VaultEntry> save(VaultEntry entry) async {
    final saved = entry.isNew ? entry.copyWith(id: 'e${_nextId++}') : entry;
    entries.add([...entries.value.where((e) => e.id != saved.id), saved]);
    return saved;
  }

  @override
  Future<void> delete(String id) async => entries.add(entries.value.where((e) => e.id != id).toList());

  @override
  Future<void> sync() async => syncs++;
}

class NoBiometrics implements BiometricRepository {
  @override
  Future<BiometricStatus> status(String userId) async => BiometricStatus.unavailable;

  @override
  Future<bool> enable(String userId, BiometricPrompt prompt) async => false;

  @override
  Future<bool> unlock(String userId, BiometricPrompt prompt) async => false;

  @override
  Future<void> disable(String userId) async {}
}

Dependencies fakeDependencies({
  AuthRepository? auth,
  VaultRepository? vault,
  SettingsRepository? settings,
  SecretClipboard? clipboard,
}) =>
    Dependencies(
      auth: auth ?? FakeAuthRepository(const User(id: 'u1', email: 'ana@correo.es')),
      vault: vault ?? FakeVaultRepository(),
      biometrics: NoBiometrics(),
      settings: settings ?? FakeSettingsRepository(),
      clipboard: clipboard ?? FakeClipboard(),
    );
