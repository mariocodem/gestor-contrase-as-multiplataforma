/// A row of the list. No secrets: the password is looked up only when the user copies it.
class EntryListItem {
  const EntryListItem({required this.id, required this.title, required this.subtitle, required this.hasPassword});

  final String id;
  final String title;
  final String subtitle;
  final bool hasPassword;

  @override
  bool operator ==(Object other) =>
      other is EntryListItem &&
      other.id == id &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.hasPassword == hasPassword;

  @override
  int get hashCode => Object.hash(id, title, subtitle, hasPassword);

  @override
  String toString() => 'EntryListItem($id, $title, $subtitle, $hasPassword)';
}
