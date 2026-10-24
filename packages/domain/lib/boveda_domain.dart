/// Bóveda's business rules: models, repository contracts, use cases, the password generator and
/// the strength estimator. Pure Dart; nothing here knows about Flutter, HTTP or storage.
library;

export 'src/error/app_error.dart';
export 'src/error/result.dart';
export 'src/generator/password_generator.dart';
export 'src/generator/password_strength_estimator.dart';
export 'src/model/app_settings.dart';
export 'src/model/app_state.dart';
export 'src/model/password_options.dart';
export 'src/model/password_strength.dart';
export 'src/model/user.dart';
export 'src/model/vault_entry.dart';
export 'src/repository/auth_repository.dart';
export 'src/repository/biometric_repository.dart';
export 'src/repository/settings_repository.dart';
export 'src/repository/vault_repository.dart';
export 'src/text/characters.dart' show foldForSearch, foldPerUnit, compareForReading, isLetterOrDigitUnit, isDigitUnit, isWhitespaceUnit;
export 'src/usecase/auth_use_cases.dart';
export 'src/usecase/biometric_use_cases.dart';
export 'src/usecase/entry_use_cases.dart';
export 'src/usecase/generator_use_cases.dart';
export 'src/usecase/settings_use_cases.dart';
export 'src/usecase/vault_use_cases.dart';
