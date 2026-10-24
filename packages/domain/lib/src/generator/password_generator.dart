import 'dart:math';

import '../model/password_options.dart';

/// Uniformly distributed random indexes below `bound`: [Random.secure] in the app, seeded in tests.
typedef RandomSource = int Function(int bound);

class PasswordGenerator {
  PasswordGenerator([RandomSource? random]) : _random = random ?? Random.secure().nextInt;

  final RandomSource _random;

  static const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const digits = '0123456789';
  static const symbols = r'!@#$%^&*()-_=+[]{};:,.?/';

  /// Easy to confuse with each other in many fonts, or to miss when typing by hand.
  static const ambiguous = 'IlOo01;:,.';

  /// A password with at least one character from every enabled set.
  String generate(PasswordOptions options) {
    final sets = characterSets(options);
    if (sets.isEmpty) throw ArgumentError('At least one character set must be enabled');
    final length = options.length.clamp(PasswordOptions.minLength, PasswordOptions.maxLength);
    final pool = sets.join();

    final chars = List.filled(length, '');
    for (var i = 0; i < sets.length; i++) {
      chars[i] = sets[i][_random(sets[i].length)];
    }
    for (var i = sets.length; i < length; i++) {
      chars[i] = pool[_random(pool.length)];
    }
    // Fisher-Yates, so the guaranteed characters don't always sit at the start.
    for (var i = length - 1; i >= 1; i--) {
      final j = _random(i + 1);
      final swap = chars[i];
      chars[i] = chars[j];
      chars[j] = swap;
    }
    return chars.join();
  }

  static List<String> characterSets(PasswordOptions options) => [
        if (options.uppercase) uppercase,
        if (options.lowercase) lowercase,
        if (options.digits) digits,
        if (options.symbols) symbols,
      ].map((set) => options.avoidAmbiguous ? set.split('').where((c) => !ambiguous.contains(c)).join() : set).toList();

  static int poolSize(PasswordOptions options) =>
      characterSets(options).fold(0, (total, set) => total + set.length);
}
