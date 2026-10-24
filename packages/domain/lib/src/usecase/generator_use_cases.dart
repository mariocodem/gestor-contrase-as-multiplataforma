import '../generator/password_generator.dart';
import '../generator/password_strength_estimator.dart';
import '../model/password_options.dart';
import '../model/password_strength.dart';

class GeneratePasswordUseCase {
  const GeneratePasswordUseCase(this._generator, this._estimator);

  final PasswordGenerator _generator;
  final PasswordStrengthEstimator _estimator;

  /// The strength describes the settings, not this string: that is what an attacker faces.
  GeneratedPassword call(PasswordOptions options) =>
      GeneratedPassword(value: _generator.generate(options), strength: _estimator.estimateOptions(options));
}

class EvaluatePasswordStrengthUseCase {
  const EvaluatePasswordStrengthUseCase(this._estimator);

  final PasswordStrengthEstimator _estimator;

  PasswordStrength call(String password) => _estimator.estimate(password);
}
