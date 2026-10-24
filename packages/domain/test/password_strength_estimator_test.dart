import 'dart:math';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:test/test.dart';

void main() {
  const estimator = PasswordStrengthEstimator();

  test('generator settings are rated by length times pool entropy', () {
    final strength = estimator.estimateOptions(const PasswordOptions(length: 20));

    expect(strength.entropyBits, closeTo(20 * log(86) / ln2, 1e-9));
    expect(strength.level, StrengthLevel.veryStrong);
  });

  test('short digits-only settings are weak', () {
    const options = PasswordOptions(length: 8, uppercase: false, lowercase: false, symbols: false);

    expect(estimator.estimateOptions(options).level, StrengthLevel.veryWeak);
  });

  test('common passwords are very weak even with leet or suffixes', () {
    for (final password in ['password', 'P@ssw0rd', 'qwerty123', 'Contraseña2024!', '123456']) {
      final strength = estimator.estimate(password);

      expect(strength.level, StrengthLevel.veryWeak, reason: password);
      expect(strength.warnings, contains(StrengthWarning.commonPassword), reason: password);
    }
  });

  test('patterns cost much less than random characters', () {
    final patterned = estimator.estimate('abcdefgh12345678');
    final random = estimator.estimate('q7Rk2mZp9xLw4nVb');

    expect(patterned.warnings, contains(StrengthWarning.sequence));
    expect(patterned.entropyBits, lessThan(random.entropyBits / 3));
    expect(random.level, StrengthLevel.veryStrong);
  });

  test('repeats, dates and keyboard runs are flagged', () {
    expect(estimator.estimate('zzzzzzzzT!').warnings, contains(StrengthWarning.repeats));
    expect(estimator.estimate('Lucia1987!').warnings, contains(StrengthWarning.date));
    expect(estimator.estimate('Kasdfgh!9').warnings, contains(StrengthWarning.keyboardPattern));
  });

  test('common words are charged as a whole, accents and ñ included', () {
    final strength = estimator.estimate('xQ9!españa');

    expect(strength.warnings, contains(StrengthWarning.commonWord));
  });

  test('crack time doubles with every extra bit', () {
    final shorter = estimator.estimateOptions(const PasswordOptions(length: 10));
    final longer = estimator.estimateOptions(const PasswordOptions(length: 11));
    final bitsAdded = longer.entropyBits - shorter.entropyBits;

    expect(longer.crackTimeSeconds / shorter.crackTimeSeconds, closeTo(pow(2, bitsAdded), 1e-6));
  });

  test('an empty password has no strength', () {
    expect(estimator.estimate('').entropyBits, 0);
  });
}
