final class PasswordOptions {
  const PasswordOptions({
    this.length = defaultLength,
    this.uppercase = true,
    this.lowercase = true,
    this.digits = true,
    this.symbols = true,
    this.avoidAmbiguous = false,
  });

  static const minLength = 8;
  static const maxLength = 64;
  static const defaultLength = 20;

  final int length;
  final bool uppercase;
  final bool lowercase;
  final bool digits;
  final bool symbols;

  /// Leaves out characters that are easy to misread or mistype, such as O/0 and l/1.
  final bool avoidAmbiguous;

  int get enabledSetCount => [uppercase, lowercase, digits, symbols].where((enabled) => enabled).length;

  PasswordOptions copyWith({
    int? length,
    bool? uppercase,
    bool? lowercase,
    bool? digits,
    bool? symbols,
    bool? avoidAmbiguous,
  }) =>
      PasswordOptions(
        length: length ?? this.length,
        uppercase: uppercase ?? this.uppercase,
        lowercase: lowercase ?? this.lowercase,
        digits: digits ?? this.digits,
        symbols: symbols ?? this.symbols,
        avoidAmbiguous: avoidAmbiguous ?? this.avoidAmbiguous,
      );

  @override
  bool operator ==(Object other) =>
      other is PasswordOptions &&
      other.length == length &&
      other.uppercase == uppercase &&
      other.lowercase == lowercase &&
      other.digits == digits &&
      other.symbols == symbols &&
      other.avoidAmbiguous == avoidAmbiguous;

  @override
  int get hashCode => Object.hash(length, uppercase, lowercase, digits, symbols, avoidAmbiguous);

  @override
  String toString() =>
      'PasswordOptions(length: $length, upper: $uppercase, lower: $lowercase, digits: $digits, symbols: $symbols, avoidAmbiguous: $avoidAmbiguous)';
}
