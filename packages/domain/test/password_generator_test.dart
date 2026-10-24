import 'dart:math';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:test/test.dart';

bool _isUpper(String c) => c.toUpperCase() == c && c.toLowerCase() != c;
bool _isLower(String c) => c.toLowerCase() == c && c.toUpperCase() != c;
bool _isDigit(String c) => '0123456789'.contains(c);
bool _isLetterOrDigit(String c) => _isUpper(c) || _isLower(c) || _isDigit(c);

void main() {
  final generator = PasswordGenerator();

  test('respects the length and includes every enabled set', () {
    for (var i = 0; i < 200; i++) {
      final password = generator.generate(const PasswordOptions(length: 8)).split('');

      expect(password, hasLength(8));
      expect(password.any(_isUpper), isTrue);
      expect(password.any(_isLower), isTrue);
      expect(password.any(_isDigit), isTrue);
      expect(password.any((c) => !_isLetterOrDigit(c)), isTrue);
    }
  });

  test('only uses enabled sets', () {
    final password = generator.generate(const PasswordOptions(length: 64, uppercase: false, symbols: false));

    expect(password.split('').every((c) => _isLower(c) || _isDigit(c)), isTrue);
  });

  test('avoids ambiguous characters when asked', () {
    for (var i = 0; i < 100; i++) {
      final password = generator.generate(const PasswordOptions(length: 64, avoidAmbiguous: true));

      expect(password.split('').any(PasswordGenerator.ambiguous.contains), isFalse);
    }
  });

  test('clamps the length to the supported range', () {
    expect(generator.generate(const PasswordOptions(length: 2)), hasLength(PasswordOptions.minLength));
    expect(generator.generate(const PasswordOptions(length: 500)), hasLength(PasswordOptions.maxLength));
  });

  test('is deterministic for a given random source', () {
    final first = PasswordGenerator(Random(42).nextInt).generate(const PasswordOptions());
    final second = PasswordGenerator(Random(42).nextInt).generate(const PasswordOptions());

    expect(first, second);
  });

  test('pool shrinks when ambiguous characters are excluded', () {
    expect(PasswordGenerator.poolSize(const PasswordOptions()), 26 + 26 + 10 + 24);
    expect(PasswordGenerator.poolSize(const PasswordOptions(avoidAmbiguous: true)), 24 + 24 + 8 + 20);
  });
}
