import 'package:boveda_domain/boveda_domain.dart';
import 'package:rxdart/rxdart.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([User? user]) : user = BehaviorSubject.seeded(user);

  final BehaviorSubject<User?> user;

  @override
  Stream<User?> get currentUser => user.stream;

  @override
  Future<void> signIn(String email, String password) async => user.add(User(id: 'uid-$email', email: email));

  @override
  Future<void> register(String email, String password) => signIn(email, password);

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => user.add(null);
}

class FakeVaultRepository implements VaultRepository {
  FakeVaultRepository([this.masterPassword = 'correct horse battery']);

  final String masterPassword;
  final status = BehaviorSubject<VaultStatus>.seeded(const VaultMissing());
  final entries = BehaviorSubject<List<VaultEntry>>.seeded(const []);
  final _unlocked = BehaviorSubject<String?>.seeded(null);
  String? createdWith;
  var _nextId = 1;

  @override
  Stream<VaultStatus> observeStatus(String userId) => status.stream;

  @override
  Stream<String?> get unlockedUserId => _unlocked.stream;

  @override
  Future<void> create(String userId, String masterPassword) async {
    createdWith = masterPassword;
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
  Future<void> sync() async {}
}
