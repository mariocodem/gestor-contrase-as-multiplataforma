/// The signed-in account. It decides *whose* vault can be read; it never sees the master password.
final class User {
  const User({required this.id, required this.email});

  final String id;
  final String? email;

  @override
  bool operator ==(Object other) => other is User && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'User($id, $email)';
}
