/// Bóveda's data layer: it implements the domain's repositories on top of the Cloudflare Worker
/// and D1 (backend/), with every secret encrypted on the device first.
library;

import 'package:boveda_domain/boveda_domain.dart';

import 'src/crypto/vault_crypto.dart';
import 'src/local/session_store.dart';
import 'src/local/vault_cache.dart';
import 'src/remote/boveda_api.dart';
import 'src/repository/auth_repository_impl.dart';
import 'src/repository/biometric_repository_impl.dart';
import 'src/repository/settings_repository_impl.dart';
import 'src/repository/vault_repository_impl.dart';
import 'src/session/auto_locker.dart';
import 'src/session/vault_session.dart';

export 'src/crypto/entry_codec.dart';
export 'src/crypto/vault_crypto.dart';
export 'src/local/session_store.dart';
export 'src/local/vault_cache.dart';
export 'src/remote/boveda_api.dart';
export 'src/repository/auth_repository_impl.dart';
export 'src/repository/biometric_repository_impl.dart';
export 'src/repository/settings_repository_impl.dart';
export 'src/repository/vault_repository_impl.dart';
export 'src/session/auto_locker.dart';
export 'src/session/vault_session.dart';

/// Every repository wired to one API endpoint; the app's composition root builds it once.
class DataLayer {
  DataLayer._({
    required this.auth,
    required this.vault,
    required this.biometrics,
    required this.settings,
    required this.autoLocker,
  });

  factory DataLayer.create({required Uri apiUrl}) {
    // package:cryptography_flutter registers itself: native AES-GCM on Android and Apple
    // platforms, and PBKDF2 on Android.
    final crypto = VaultCrypto();
    final sessionStore = SessionStore();
    final api = BovedaApi(baseUrl: apiUrl, token: () => sessionStore.token);
    final session = VaultSession();
    final settings = SettingsRepositoryImpl();
    return DataLayer._(
      auth: AuthRepositoryImpl(api: api, store: sessionStore, crypto: crypto),
      vault: VaultRepositoryImpl(api: api, cache: VaultCache(), session: session, crypto: crypto),
      biometrics: BiometricRepositoryImpl(session: session),
      settings: settings,
      autoLocker: AutoLocker(session: session, settings: settings),
    );
  }

  final AuthRepository auth;
  final VaultRepository vault;
  final BiometricRepository biometrics;
  final SettingsRepository settings;
  final AutoLocker autoLocker;
}
