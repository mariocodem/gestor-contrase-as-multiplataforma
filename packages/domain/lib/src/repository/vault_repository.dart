import '../model/app_state.dart';
import '../model/vault_entry.dart';

/// The encrypted vault. Implementations encrypt on the device; nothing readable leaves it.
/// Failures are thrown as [AppException].
abstract interface class VaultRepository {
  Stream<VaultStatus> observeStatus(String userId);

  /// Id of the user whose vault is unlocked in memory, or null while locked. Emits the current
  /// value on listen.
  Stream<String?> get unlockedUserId;

  /// Creates the vault protected by [masterPassword] and leaves it unlocked.
  Future<void> create(String userId, String masterPassword);

  Future<void> unlock(String userId, String masterPassword);

  /// Forgets the decrypted vault key.
  void lock();

  /// Decrypted entries of the unlocked vault, unordered; empty while locked.
  Stream<List<VaultEntry>> observeEntries();

  /// The entries most recently decrypted in this session, so a screen can draw at once instead of
  /// waiting for [observeEntries]; null before the first decryption and while locked.
  List<VaultEntry>? get lastKnownEntries;

  /// Encrypts and stores [entry], assigning an id when it's new. Returns what was stored.
  Future<VaultEntry> save(VaultEntry entry);

  Future<void> delete(String id);

  /// Sends queued changes and fetches what other devices changed, now.
  Future<void> sync();
}
