import 'dart:math';

import '../model/password_options.dart';
import '../model/password_strength.dart';
import '../text/characters.dart';
import 'password_generator.dart';

/// Entropy-based strength. Generated passwords are rated by their generator settings (what an
/// attacker who knows them faces); hand-picked ones get a rough estimate that charges almost
/// nothing for the patterns guessers try first: common passwords and words, dates, repeats,
/// sequences and keyboard runs.
class PasswordStrengthEstimator {
  const PasswordStrengthEstimator();

  /// A GPU rig against a fast, unsalted hash: the worst realistic case for a leaked password.
  static const guessesPerSecond = 1e10;

  static const recommendedLength = 12;
  static const _longEnough = 20;
  static const _commonPasswordBits = 10.0;
  static const _wordBits = 9.0;
  static const _dateBits = 7.0;
  static const _patternBits = 1.0;

  PasswordStrength estimateOptions(PasswordOptions options) {
    final pool = PasswordGenerator.poolSize(options);
    if (pool == 0) return PasswordStrength.empty;
    final length = options.length.clamp(PasswordOptions.minLength, PasswordOptions.maxLength);
    return _strengthOf(length * _log2(pool.toDouble()), const {});
  }

  PasswordStrength estimate(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    final lower = password.toLowerCase();
    final unleet = String.fromCharCodes(lower.codeUnits.map((c) => _leet[c] ?? c));
    final pool = _characterPool(password);
    final warnings = <StrengthWarning>{};
    if (password.length < recommendedLength) warnings.add(StrengthWarning.tooShort);
    if (pool.classes == 1 && password.length < _longEnough) warnings.add(StrengthWarning.singleCharacterType);

    final variants = [lower, unleet].expand((text) => [text, _trimTrailingNonLetters(text)]);
    if (variants.any((variant) => variant.isNotEmpty && _commonPasswords.contains(variant))) {
      warnings.add(StrengthWarning.commonPassword);
      return _strengthOf(_commonPasswordBits, warnings);
    }

    final cost = List<double>.filled(lower.length, _log2(pool.size.toDouble()));
    if (_chargeWords(lower, unleet, cost)) warnings.add(StrengthWarning.commonWord);
    if (_chargeDates(lower, cost)) warnings.add(StrengthWarning.date);
    if (_chargeRuns(lower, cost, (a, b, _) => a == b)) warnings.add(StrengthWarning.repeats);
    if (_chargeRuns(lower, cost, _continuesSequence)) warnings.add(StrengthWarning.sequence);
    if (_chargeKeyboardRuns(lower, cost)) warnings.add(StrengthWarning.keyboardPattern);
    return _strengthOf(cost.fold(0.0, (sum, bits) => sum + bits), warnings);
  }

  PasswordStrength _strengthOf(double bits, Set<StrengthWarning> warnings) {
    final level = switch (bits) {
      _ when warnings.contains(StrengthWarning.commonPassword) => StrengthLevel.veryWeak,
      < 28 => StrengthLevel.veryWeak,
      < 36 => StrengthLevel.weak,
      < 60 => StrengthLevel.fair,
      < 80 => StrengthLevel.strong,
      _ => StrengthLevel.veryStrong,
    };
    // On average the attacker finds it after trying half of the possibilities.
    final seconds = pow(2, bits - 1) / guessesPerSecond;
    return PasswordStrength(entropyBits: bits, level: level, crackTimeSeconds: seconds.toDouble(), warnings: warnings);
  }

  static double _log2(double x) => log(x) / ln2;

  static ({int size, int classes}) _characterPool(String password) {
    final units = password.codeUnits;
    final sizes = [
      if (units.any((c) => c >= 0x61 && c <= 0x7A)) 26,
      if (units.any((c) => c >= 0x41 && c <= 0x5A)) 26,
      if (units.any((c) => c >= 0x30 && c <= 0x39)) 10,
      if (units.any((c) => c >= 32 && c <= 126 && !isLetterOrDigitUnit(c))) 33,
      // Accented letters, ñ, emoji: a rough allowance, attackers try the common ones first.
      if (units.any((c) => c > 126)) 40,
    ];
    return (size: sizes.fold(0, (total, size) => total + size), classes: sizes.length);
  }

  static String _trimTrailingNonLetters(String text) {
    var end = text.length;
    while (end > 0 && !isLetterUnit(text.codeUnitAt(end - 1))) {
      end--;
    }
    return text.substring(0, end);
  }

  /// Each common word costs [_wordBits] in total instead of per character.
  static bool _chargeWords(String lower, String unleet, List<double> cost) {
    final covered = List<bool>.filled(cost.length, false);
    var found = false;
    for (final word in _commonWords) {
      for (final text in [lower, unleet]) {
        var start = text.indexOf(word);
        while (start >= 0) {
          final end = start + word.length;
          var free = true;
          for (var i = start; i < end; i++) {
            if (covered[i]) free = false;
          }
          if (free) {
            for (var i = start; i < end; i++) {
              covered[i] = true;
              cost[i] = 0;
            }
            cost[start] = _wordBits;
            found = true;
          }
          start = text.indexOf(word, start + 1);
        }
      }
    }
    return found;
  }

  static bool _chargeDates(String lower, List<double> cost) {
    var found = false;
    for (final match in _year.allMatches(lower)) {
      for (var i = match.start; i < match.end; i++) {
        cost[i] = 0;
      }
      cost[match.start] = _dateBits;
      found = true;
    }
    return found;
  }

  /// Runs of 3+ characters where each continues the previous: the run costs about one character.
  static bool _chargeRuns(String text, List<double> cost, bool Function(int current, int previous, int delta) continues) {
    var found = false;
    var start = 0;
    var step = 0;
    for (var i = 1; i <= text.length; i++) {
      final delta = i < text.length ? text.codeUnitAt(i) - text.codeUnitAt(i - 1) : 0;
      final pairContinues = i < text.length && continues(text.codeUnitAt(i), text.codeUnitAt(i - 1), delta);
      if (pairContinues && (i - start == 1 || delta == step)) {
        if (i - start == 1) step = delta;
        continue;
      }
      if (i - start >= 3) {
        for (var j = start + 1; j < i; j++) {
          cost[j] = min(cost[j], _patternBits);
        }
        found = true;
      }
      // A pair that breaks the step ("abcb") can still open the next run.
      if (pairContinues) {
        start = i - 1;
        step = delta;
      } else {
        start = i;
      }
    }
    return found;
  }

  static bool _continuesSequence(int current, int previous, int delta) =>
      (delta == 1 || delta == -1) &&
      ((isLetterUnit(current) && isLetterUnit(previous)) || (isDigitUnit(current) && isDigitUnit(previous)));

  static bool _chargeKeyboardRuns(String lower, List<double> cost) {
    var found = false;
    for (final row in _keyboardRows) {
      for (var i = 0; i < lower.length; i++) {
        final at = row.indexOf(lower[i]);
        if (at < 0) continue;
        var length = 1;
        while (i + length < lower.length && at + length < row.length && row[at + length] == lower[i + length]) {
          length++;
        }
        if (length >= 4) {
          for (var j = i + 1; j < i + length; j++) {
            cost[j] = min(cost[j], _patternBits);
          }
          found = true;
        }
      }
    }
    return found;
  }

  static final _year = RegExp(r'(?<!\d)(19|20)\d\d(?!\d)');

  static final Map<int, int> _leet = {
    for (final pair in const ['0o', '1i', '3e', '4a', '5s', '7t', '@a', r'$s'])
      pair.codeUnitAt(0): pair.codeUnitAt(1),
  };

  static final List<String> _keyboardRows = [
    for (final row in const ['qwertyuiop', 'asdfghjklñ', 'zxcvbnm', '1234567890']) ...[
      row,
      row.split('').reversed.join(),
    ],
  ];

  static const _commonPasswords = {
    '123456', '123456789', '12345678', '12345', '1234567', '1234567890', '111111', '000000', //
    '123123', '654321', '666666', '121212', '112233', 'abc123', '123abc', 'qwerty', 'qwerty123',
    'qwertyuiop', 'asdfgh', 'asdfghjkl', 'zxcvbnm', 'password', 'password1', 'password123',
    'iloveyou', 'admin', 'welcome', 'monkey', 'dragon', 'letmein', 'football', 'baseball',
    'sunshine', 'princess', 'master', 'shadow', 'superman', 'batman', 'starwars', 'trustno1',
    'login', 'secret', 'contraseña', 'contrasena', 'clave', 'secreto', 'teamo', 'tequiero',
    'hola', 'amor', 'españa', 'espana', 'barcelona', 'madrid', 'realmadrid', 'futbol', 'mexico',
    'argentina', 'colombia', 'chile', 'peru', 'pokemon', 'minecraft',
  };

  // Longest first, ties in list order (a stable sort), so long words claim their characters first.
  static final List<String> _commonWords = () {
    const words = [
      'contraseña', 'contrasena', 'password', 'barcelona', 'realmadrid', 'princess', 'football', //
      'sunshine', 'superman', 'starwars', 'iloveyou', 'argentina', 'colombia', 'pokemon',
      'minecraft', 'familia', 'invierno', 'welcome', 'letmein', 'secreto', 'tequiero', 'monkey',
      'dragon', 'master', 'shadow', 'batman', 'futbol', 'madrid', 'españa', 'espana', 'mexico',
      'verano', 'summer', 'winter', 'secret', 'google', 'admin', 'teamo', 'qwerty', 'clave',
      'login', 'hola', 'amor', 'love', 'casa', 'perro', 'gato', 'dios',
    ];
    final indexed = [for (var i = 0; i < words.length; i++) (i, words[i])];
    indexed.sort((a, b) {
      final byLength = b.$2.length.compareTo(a.$2.length);
      return byLength != 0 ? byLength : a.$1.compareTo(b.$1);
    });
    return [for (final (_, word) in indexed) word];
  }();
}
