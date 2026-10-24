enum StrengthLevel { veryWeak, weak, fair, strong, veryStrong }

/// Patterns that make a hand-picked password easier to guess than its length suggests.
enum StrengthWarning {
  tooShort,
  commonPassword,
  commonWord,
  date,
  repeats,
  sequence,
  keyboardPattern,
  singleCharacterType,
}

final class PasswordStrength {
  const PasswordStrength({
    required this.entropyBits,
    required this.level,
    required this.crackTimeSeconds,
    this.warnings = const {},
  });

  static const empty = PasswordStrength(entropyBits: 0, level: StrengthLevel.veryWeak, crackTimeSeconds: 0);

  final double entropyBits;
  final StrengthLevel level;

  /// Average time an offline attacker needs to guess it, in seconds.
  final double crackTimeSeconds;
  final Set<StrengthWarning> warnings;

  @override
  bool operator ==(Object other) =>
      other is PasswordStrength &&
      other.entropyBits == entropyBits &&
      other.level == level &&
      other.crackTimeSeconds == crackTimeSeconds &&
      other.warnings.length == warnings.length &&
      other.warnings.containsAll(warnings);

  @override
  int get hashCode => Object.hash(entropyBits, level, crackTimeSeconds, Object.hashAllUnordered(warnings));

  @override
  String toString() => 'PasswordStrength(${entropyBits.toStringAsFixed(1)} bits, $level, $warnings)';
}

final class GeneratedPassword {
  const GeneratedPassword({required this.value, required this.strength});

  final String value;
  final PasswordStrength strength;

  @override
  bool operator ==(Object other) => other is GeneratedPassword && other.value == value && other.strength == strength;

  @override
  int get hashCode => Object.hash(value, strength);
}
