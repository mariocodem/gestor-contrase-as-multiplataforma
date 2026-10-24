/// A decrypted vault item. Only ever lives in memory while the vault is unlocked.
final class VaultEntry {
  const VaultEntry({
    this.id = '',
    this.title = '',
    this.username = '',
    this.password = '',
    this.url = '',
    this.notes = '',
    this.updatedAt = 0,
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;

  /// Milliseconds since the epoch, set when the entry is saved.
  final int updatedAt;

  bool get isNew => id.isEmpty;

  VaultEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    int? updatedAt,
  }) =>
      VaultEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        username: username ?? this.username,
        password: password ?? this.password,
        url: url ?? this.url,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is VaultEntry &&
      other.id == id &&
      other.title == title &&
      other.username == username &&
      other.password == password &&
      other.url == url &&
      other.notes == notes &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, title, username, password, url, notes, updatedAt);

  // Never prints the password or notes.
  @override
  String toString() => 'VaultEntry($id, $title)';
}
