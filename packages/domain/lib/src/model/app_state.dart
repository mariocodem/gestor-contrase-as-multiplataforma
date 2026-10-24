import '../error/app_error.dart';
import 'user.dart';

/// Which part of the app the user can reach right now.
sealed class AppState {
  const AppState();
}

final class AppLoading extends AppState {
  const AppLoading();

  @override
  bool operator ==(Object other) => other is AppLoading;

  @override
  int get hashCode => (AppLoading).hashCode;
}

final class SignedOut extends AppState {
  const SignedOut();

  @override
  bool operator ==(Object other) => other is SignedOut;

  @override
  int get hashCode => (SignedOut).hashCode;
}

final class NeedsSetup extends AppState {
  const NeedsSetup(this.user);

  final User user;

  @override
  bool operator ==(Object other) => other is NeedsSetup && other.user == user;

  @override
  int get hashCode => Object.hash(NeedsSetup, user);
}

final class Locked extends AppState {
  const Locked(this.user);

  final User user;

  @override
  bool operator ==(Object other) => other is Locked && other.user == user;

  @override
  int get hashCode => Object.hash(Locked, user);
}

final class Unlocked extends AppState {
  const Unlocked(this.user);

  final User user;

  @override
  bool operator ==(Object other) => other is Unlocked && other.user == user;

  @override
  int get hashCode => Object.hash(Unlocked, user);
}

final class AppFailed extends AppState {
  const AppFailed(this.error);

  final AppError error;

  @override
  bool operator ==(Object other) => other is AppFailed && other.error == error;

  @override
  int get hashCode => Object.hash(AppFailed, error);
}

/// Whether a user's vault exists in the backend (or in this device's copy of it).
sealed class VaultStatus {
  const VaultStatus();
}

final class VaultStatusLoading extends VaultStatus {
  const VaultStatusLoading();

  @override
  bool operator ==(Object other) => other is VaultStatusLoading;

  @override
  int get hashCode => (VaultStatusLoading).hashCode;
}

final class VaultMissing extends VaultStatus {
  const VaultMissing();

  @override
  bool operator ==(Object other) => other is VaultMissing;

  @override
  int get hashCode => (VaultMissing).hashCode;
}

final class VaultPresent extends VaultStatus {
  const VaultPresent();

  @override
  bool operator ==(Object other) => other is VaultPresent;

  @override
  int get hashCode => (VaultPresent).hashCode;
}

final class VaultStatusFailed extends VaultStatus {
  const VaultStatusFailed(this.error);

  final AppError error;

  @override
  bool operator ==(Object other) => other is VaultStatusFailed && other.error == error;

  @override
  int get hashCode => Object.hash(VaultStatusFailed, error);
}

final class BiometricStatus {
  const BiometricStatus({required this.available, required this.enabled});

  static const unavailable = BiometricStatus(available: false, enabled: false);

  final bool available;
  final bool enabled;

  @override
  bool operator ==(Object other) => other is BiometricStatus && other.available == available && other.enabled == enabled;

  @override
  int get hashCode => Object.hash(available, enabled);
}

/// Text for the system biometric sheet; the UI supplies it in the user's language.
final class BiometricPrompt {
  const BiometricPrompt({required this.title, required this.cancel});

  final String title;
  final String cancel;
}
