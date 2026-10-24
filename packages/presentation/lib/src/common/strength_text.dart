import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/widgets.dart';

import 'strings.dart';

const _minute = 60.0;
const _hour = 60 * _minute;
const _day = 24 * _hour;
const _month = 30 * _day;
const _year = 365 * _day;

String verdictOf(StrengthLevel level) => switch (level) {
      StrengthLevel.veryWeak => S.strengthVeryWeak,
      StrengthLevel.weak => S.strengthWeak,
      StrengthLevel.fair => S.strengthFair,
      StrengthLevel.strong => S.strengthStrong,
      StrengthLevel.veryStrong => S.strengthVeryStrong,
    };

/// "Adivinarla llevaría 3 días", rounded to the largest unit that reads naturally.
String crackTime(double seconds) {
  if (seconds < 1) return S.strengthInstant;
  final duration = switch (seconds) {
    < _minute => S.durationSeconds(seconds.round()),
    < _hour => S.durationMinutes((seconds / _minute).round()),
    < _day => S.durationHours((seconds / _hour).round()),
    < _month => S.durationDays((seconds / _day).round()),
    < _year => S.durationMonths((seconds / _month).round().clamp(1, 11)),
    < 100 * _year => S.durationYears((seconds / _year).round()),
    < 1e6 * _year => S.durationCenturies,
    _ => S.durationMillionsOfYears,
  };
  return S.strengthCrackTime(duration);
}

/// The one pattern most worth fixing, if any.
String? topWarning(PasswordStrength strength) {
  const ordered = [
    (StrengthWarning.commonPassword, S.warningCommonPassword),
    (StrengthWarning.commonWord, S.warningCommonWord),
    (StrengthWarning.keyboardPattern, S.warningKeyboard),
    (StrengthWarning.sequence, S.warningSequence),
    (StrengthWarning.repeats, S.warningRepeats),
    (StrengthWarning.date, S.warningDate),
    (StrengthWarning.singleCharacterType, S.warningSingleType),
    (StrengthWarning.tooShort, S.warningTooShort),
  ];
  for (final (warning, text) in ordered) {
    if (strength.warnings.contains(warning)) return text;
  }
  return null;
}

/// The design-system meter fed from a domain strength. Hand-typed passwords show their worst
/// pattern instead of the crack time, because that's what the user can act on; at the top rating
/// the crack time stands alone, so "very strong" never comes with a reason to doubt it.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.strength, this.showWarning = true});

  final PasswordStrength strength;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    final warning = showWarning && strength.level != StrengthLevel.veryStrong ? topWarning(strength) : null;
    return StrengthIndicator(
      level: strength.level.index,
      verdict: verdictOf(strength.level),
      measurement: S.strengthBits(strength.entropyBits.round()),
      detail: warning ?? crackTime(strength.crackTimeSeconds),
    );
  }
}
