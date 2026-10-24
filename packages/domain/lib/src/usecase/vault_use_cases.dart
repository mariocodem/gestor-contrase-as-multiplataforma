import 'package:rxdart/rxdart.dart';

import '../error/app_error.dart';
import '../error/result.dart';
import '../model/app_state.dart';
import '../repository/auth_repository.dart';
import '../repository/vault_repository.dart';

class CreateVaultUseCase {
  const CreateVaultUseCase(this._vault);

  final VaultRepository _vault;

  static const minMasterPasswordLength = 10;

  Future<Result<void>> call(String userId, String masterPassword, String confirmation) => resultOf(() async {
        if (masterPassword.length < minMasterPasswordLength) throw const AppException(AppError.masterPasswordTooShort);
        if (masterPassword != confirmation) throw const AppException(AppError.masterPasswordMismatch);
        await _vault.create(userId, masterPassword);
      });
}

class UnlockVaultUseCase {
  const UnlockVaultUseCase(this._vault);

  final VaultRepository _vault;

  Future<Result<void>> call(String userId, String masterPassword) => resultOf(() async {
        if (masterPassword.isEmpty) throw const AppException(AppError.emptyMasterPassword);
        await _vault.unlock(userId, masterPassword);
      });
}

class LockVaultUseCase {
  const LockVaultUseCase(this._vault);

  final VaultRepository _vault;

  void call() => _vault.lock();
}

class SyncVaultUseCase {
  const SyncVaultUseCase(this._vault);

  final VaultRepository _vault;

  Future<Result<void>> call() => resultOf(_vault.sync);
}

/// Combines the account, the vault's existence and the in-memory key into the screen the user may see.
class ObserveAppStateUseCase {
  const ObserveAppStateUseCase(this._auth, this._vault);

  final AuthRepository _auth;
  final VaultRepository _vault;

  Stream<AppState> call() => _auth.currentUser
      .distinct()
      .switchMap<AppState>((user) {
        if (user == null) return Stream.value(const SignedOut());
        return Rx.combineLatest2(_vault.observeStatus(user.id), _vault.unlockedUserId, (status, unlockedId) {
          final unlocked = unlockedId == user.id;
          return switch (status) {
            VaultStatusLoading() => const AppLoading(),
            // Right after creating the vault the key is ready before the backend confirms it.
            VaultMissing() => unlocked ? Unlocked(user) : NeedsSetup(user),
            VaultPresent() => unlocked ? Unlocked(user) : Locked(user),
            VaultStatusFailed(:final error) => AppFailed(error),
          };
        });
      })
      .distinct();
}
