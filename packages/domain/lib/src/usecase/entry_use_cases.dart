import '../error/app_error.dart';
import '../error/result.dart';
import '../model/vault_entry.dart';
import '../repository/vault_repository.dart';
import '../text/characters.dart';

/// Entries sorted the way people read them: alphabetical, ignoring case and accents.
class ObserveEntriesUseCase {
  const ObserveEntriesUseCase(this._vault);

  final VaultRepository _vault;

  Stream<List<VaultEntry>> call() => _vault.observeEntries().map(sortForReading);

  static List<VaultEntry> sortForReading(List<VaultEntry> entries) => [...entries]..sort((a, b) {
        final byTitle = compareForReading(a.title, b.title);
        return byTitle != 0 ? byTitle : compareForReading(a.username, b.username);
      });
}

/// A single entry, or null once it's gone (deleted here or on another device).
class ObserveEntryUseCase {
  const ObserveEntryUseCase(this._vault);

  final VaultRepository _vault;

  Stream<VaultEntry?> call(String id) =>
      _vault.observeEntries().map((entries) => _find(entries, id)).distinct();

  /// The entry as already decrypted in this session, to show while [call] connects; null if unknown.
  VaultEntry? current(String id) {
    final entries = _vault.lastKnownEntries;
    return entries == null ? null : _find(entries, id);
  }

  static VaultEntry? _find(List<VaultEntry> entries, String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

/// Matches title, username and site, so "telefonica" finds "Telefónica".
class SearchEntriesUseCase {
  const SearchEntriesUseCase();

  List<VaultEntry> call(List<VaultEntry> entries, String query) {
    final needle = foldForSearch(query);
    if (needle.isEmpty) return entries;
    return entries
        .where((entry) => [entry.title, entry.username, entry.url].any((field) => foldForSearch(field).contains(needle)))
        .toList();
  }
}

class SaveEntryUseCase {
  const SaveEntryUseCase(this._vault);

  final VaultRepository _vault;

  /// Trims the free-text fields (never the password) and rejects an entry without a name.
  Future<Result<VaultEntry>> call(VaultEntry entry) => resultOf(() async {
        final cleaned = entry.copyWith(title: entry.title.trim(), username: entry.username.trim(), url: entry.url.trim());
        if (cleaned.title.isEmpty) throw const AppException(AppError.emptyTitle);
        return _vault.save(cleaned);
      });
}

class DeleteEntryUseCase {
  const DeleteEntryUseCase(this._vault);

  final VaultRepository _vault;

  Future<Result<void>> call(String id) => resultOf(() => _vault.delete(id));
}
