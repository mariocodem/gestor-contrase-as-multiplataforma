import 'package:flutter/foundation.dart';

/// Every string the user reads. The product speaks Spanish only (PRODUCT.md), so these are plain
/// constants; anything with a number or a name is a function.
abstract final class S {
  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // General
  static const appTitle = 'Bóveda';
  static const back = 'Volver';
  static const cancel = 'Cancelar';
  static const retry = 'Reintentar';
  static const signOut = 'Cerrar sesión';
  static const lock = 'Bloquear';
  static const more = 'Más opciones';
  static const loadingVault = 'Conectando con tu bóveda…';
  static const showPassword = 'Mostrar contraseña';
  static const hidePassword = 'Ocultar contraseña';

  // Navigation
  static const navVault = 'Bóveda';
  static const navGenerator = 'Generador';
  static const navSettings = 'Ajustes';

  // Account
  static const authSubtitleSignIn = 'Inicia sesión para sincronizar tu bóveda cifrada.';
  static const authSubtitleRegister = 'Crea la cuenta con la que se sincronizarán tus contraseñas cifradas.';
  static const authEmail = 'Correo';
  static const authPassword = 'Contraseña de la cuenta';
  static const authPasswordHint = 'Al menos 8 caracteres. No uses la misma que tu contraseña maestra.';
  static const authSignIn = 'Iniciar sesión';
  static const authRegister = 'Crear cuenta';
  static const authSwitchToRegister = '¿Primera vez? Crear cuenta';
  static const authSwitchToSignIn = 'Ya tengo cuenta';
  static const authForgot = 'Olvidé la contraseña de la cuenta';
  static const authResetSent = 'Si la cuenta existe, te enviamos un correo para restablecer la contraseña.';

  // Lock
  static const lockTitleSetup = 'Crea tu contraseña maestra';
  static const lockTitleLocked = 'Bóveda bloqueada';
  static const lockBodySetup =
      'Con ella se cifran tus contraseñas en este dispositivo antes de subirlas. Nadie más puede leerlas, ni siquiera con acceso a la base de datos.';
  static const lockBodyLocked = 'Escribe tu contraseña maestra para continuar.';
  static const lockWarning = 'No se puede recuperar. Si la olvidas, perderás el acceso a todas tus contraseñas.';
  static const lockMasterPassword = 'Contraseña maestra';
  static const lockRepeatMasterPassword = 'Repite la contraseña maestra';
  static const lockCreate = 'Crear bóveda';
  static const lockCreating = 'Creando bóveda…';
  static const lockUnlock = 'Desbloquear';
  static const lockUnlocking = 'Descifrando…';
  static String get lockUseBiometrics => _android ? 'Usar huella' : 'Usar biometría';
  static const lockBiometricPrompt = 'Desbloquear Bóveda';
  static String lockSignedInAs(String email) => 'Cuenta: $email';
  static const errorScreenTitle = 'No se pudo abrir la bóveda';

  // Vault list
  static const vaultSearch = 'Buscar';
  static String vaultSearchCount(int count) => count == 1 ? 'Buscar en 1 contraseña' : 'Buscar en $count contraseñas';
  static const vaultClearSearch = 'Borrar búsqueda';
  static const vaultNew = 'Nueva';
  static const vaultNewDescription = 'Nueva contraseña';
  static String vaultCopyPasswordOf(String title) => 'Copiar contraseña de $title';
  static const vaultEmptyTitle = 'Tu bóveda está vacía';
  static const vaultEmptyBody =
      'Guarda tu primera contraseña con el botón Nueva. Se cifra en este dispositivo antes de sincronizarse.';
  static const vaultNoResultsTitle = 'Sin resultados';
  static String vaultNoResultsBody(String query) => 'Nada coincide con «$query». Se busca por nombre, usuario y sitio web.';
  static const vaultErrorTitle = 'No se pudieron cargar las contraseñas';

  // Clipboard
  static String copiedPassword(int seconds) => 'Contraseña copiada. Se borrará del portapapeles en $seconds s.';
  static String copiedPasswordShort(int seconds) => 'Se borrará del portapapeles en $seconds s.';
  static const copiedUsername = 'Usuario copiado';
  static const clipboardLabelPassword = 'Contraseña';
  static const clipboardLabelUsername = 'Usuario';

  // Entry detail
  static const detailUsername = 'Usuario';
  static const detailPassword = 'Contraseña';
  static const detailWebsite = 'Sitio web';
  static const detailNotes = 'Notas';
  static const detailCopyPassword = 'Copiar contraseña';
  static const detailCopyUsername = 'Copiar usuario';
  static const detailPasswordCopied = 'Contraseña copiada';
  static const detailHiddenPassword = 'Contraseña oculta';
  static const detailOpenWebsite = 'Abrir sitio web';
  static const detailEdit = 'Editar';
  static const detailDelete = 'Eliminar';
  static String detailUpdated(String date) => 'Modificada el $date';
  static const detailNoPassword = 'Sin contraseña guardada';
  static const detailMissingTitle = 'Esta contraseña ya no existe';
  static const detailMissingBody = 'Se eliminó, quizá desde otro dispositivo.';
  static String detailDeleteTitle(String title) => '¿Eliminar «$title»?';
  static const detailDeleteBody = 'Se borrará de todos tus dispositivos. No se puede deshacer.';
  static String detailDeleted(String title) => '«$title» eliminada';

  // Entry editor
  static const editorNewTitle = 'Nueva contraseña';
  static const editorEditTitle = 'Editar';
  static const editorClose = 'Cerrar';
  static const editorSave = 'Guardar';
  static const editorName = 'Nombre';
  static const editorNamePlaceholder = 'Banco, correo, Netflix…';
  static const editorUsername = 'Usuario o correo';
  static const editorPassword = 'Contraseña';
  static const editorGenerate = 'Generar';
  static const editorWebsite = 'Sitio web';
  static const editorWebsitePlaceholder = 'ejemplo.com';
  static const editorNotes = 'Notas';
  static const editorSaved = 'Contraseña guardada';
  static const editorUpdated = 'Cambios guardados';
  static const editorDiscardTitle = '¿Descartar cambios?';
  static const editorDiscardBody = 'Los cambios que no hayas guardado se perderán.';
  static const editorDiscard = 'Descartar';
  static const editorKeepEditing = 'Seguir editando';

  // Generator
  static const generatorTitle = 'Generador';
  static const generatorSheetTitle = 'Generar contraseña';
  static const generatorCopy = 'Copiar';
  static const generatorCopied = 'Copiada';
  static const generatorRegenerate = 'Generar otra';
  static const generatorUse = 'Usar esta contraseña';
  static const generatorLength = 'Longitud';
  static String generatorLengthValue(int length) => '$length caracteres';
  static const generatorCharacters = 'Caracteres';
  static const generatorUppercase = 'Mayúsculas';
  static const generatorUppercaseSample = 'A–Z';
  static const generatorLowercase = 'Minúsculas';
  static const generatorLowercaseSample = 'a–z';
  static const generatorDigits = 'Números';
  static const generatorDigitsSample = '0–9';
  static const generatorSymbols = 'Símbolos';
  static const generatorSymbolsSample = r'! @ # $ % & *';
  static const generatorAvoidAmbiguous = 'Evitar caracteres confusos';
  static const generatorAvoidAmbiguousSample = 'Sin O 0 l 1 I ; : , .';
  static const generatorLastSet = 'Al menos un tipo de carácter debe quedar activo.';
  static const generatorAssumption =
      'Estimación para estos ajustes, con un atacante que prueba 10 000 millones de contraseñas por segundo.';

  // Strength
  static const strengthVeryWeak = 'Muy débil';
  static const strengthWeak = 'Débil';
  static const strengthFair = 'Aceptable';
  static const strengthStrong = 'Fuerte';
  static const strengthVeryStrong = 'Muy fuerte';
  static String strengthBits(int bits) => '$bits bits';
  static const strengthInstant = 'Se adivina al instante';
  static String strengthCrackTime(String duration) => 'Adivinarla llevaría $duration';
  static String durationSeconds(int n) => n == 1 ? '1 segundo' : '$n segundos';
  static String durationMinutes(int n) => n == 1 ? '1 minuto' : '$n minutos';
  static String durationHours(int n) => n == 1 ? '1 hora' : '$n horas';
  static String durationDays(int n) => n == 1 ? '1 día' : '$n días';
  static String durationMonths(int n) => n == 1 ? '1 mes' : '$n meses';
  static String durationYears(int n) => n == 1 ? '1 año' : '$n años';
  static const durationCenturies = 'siglos';
  static const durationMillionsOfYears = 'más de un millón de años';
  static const warningTooShort = 'Usa al menos 12 caracteres.';
  static const warningCommonPassword = 'Es una de las contraseñas más usadas.';
  static const warningCommonWord = 'Contiene una palabra muy común.';
  static const warningDate = 'Los años y las fechas son fáciles de adivinar.';
  static const warningRepeats = 'Evita repetir el mismo carácter.';
  static const warningSequence = 'Evita secuencias como abc o 123.';
  static const warningKeyboard = 'Evita patrones del teclado como qwerty.';
  static const warningSingleType = 'Mezcla letras, números y símbolos.';

  // Settings
  static const settingsTitle = 'Ajustes';
  static const settingsAccount = 'Cuenta';
  static const settingsSignedIn = 'Sesión iniciada';
  static const settingsSecurity = 'Seguridad';
  static String get settingsBiometric => _android ? 'Desbloqueo con huella' : 'Desbloqueo biométrico';
  static String get settingsBiometricBody => _android
      ? 'Usa la biometría del teléfono en lugar de la contraseña maestra.'
      : 'Usa Face ID o Touch ID en lugar de la contraseña maestra.';
  static String get settingsBiometricUnavailable => _android
      ? 'Configura una huella en los ajustes del teléfono para usarla aquí.'
      : 'No disponible en este dispositivo.';
  static String get settingsBiometricPrompt => _android ? 'Activar desbloqueo con huella' : 'Activar desbloqueo biométrico';
  static String get settingsBiometricOn => _android ? 'Desbloqueo con huella activado' : 'Desbloqueo biométrico activado';
  static String get settingsBiometricOff => _android ? 'Desbloqueo con huella desactivado' : 'Desbloqueo biométrico desactivado';
  static const settingsAutoLock = 'Bloqueo automático';
  static const settingsLockNow = 'Bloquear ahora';
  static String get settingsLockNowBody =>
      _android ? 'Vuelve a pedir la contraseña maestra o la huella.' : 'Vuelve a pedir la contraseña maestra.';
  static const settingsAppearance = 'Apariencia';
  static String get settingsDynamicColor => _android ? 'Colores del fondo de pantalla' : 'Colores del sistema';
  static String get settingsDynamicColorBody => _android
      ? 'Usa la paleta Material You en lugar del acero y latón.'
      : 'Usa el color de acento del sistema en lugar del acero y latón.';
  static const settingsAbout = 'Cómo se protegen tus datos';
  static const settingsAboutBody =
      'Cada contraseña se cifra en este dispositivo con AES-256-GCM. La clave se deriva de tu contraseña maestra con PBKDF2 (600 000 iteraciones). Tu servidor en Cloudflare solo guarda texto cifrado.';
  static const autoLockImmediately = 'Inmediatamente';
  static const autoLock30Seconds = 'Tras 30 segundos';
  static const autoLock1Minute = 'Tras 1 minuto';
  static const autoLock5Minutes = 'Tras 5 minutos';
  static const autoLock15Minutes = 'Tras 15 minutos';
  static const autoLockDialogBody = 'Tiempo en segundo plano antes de volver a pedir el desbloqueo.';

  // Errors
  static const errorNetwork = 'Sin conexión a internet.';
  static const errorTooManyRequests = 'Demasiados intentos. Espera un momento y vuelve a probar.';
  static const errorSessionExpired = 'Tu sesión caducó. Vuelve a iniciar sesión.';
  static const errorServiceUnavailable = 'El servidor no responde. Comprueba la conexión e inténtalo de nuevo.';
  static const errorMissingCredentials = 'Escribe tu correo y contraseña.';
  static const errorMissingEmail = 'Escribe tu correo para enviarte el enlace.';
  static const errorInvalidEmail = 'El correo no es válido.';
  static const errorInvalidCredentials = 'Correo o contraseña incorrectos.';
  static const errorEmailInUse = 'Ya existe una cuenta con ese correo.';
  static const errorWeakAccountPassword = 'La contraseña de la cuenta debe tener al menos 8 caracteres.';
  static const errorRegistrationClosed = 'Este servidor no admite cuentas nuevas con ese correo.';
  static const errorResetUnavailable =
      'Tu servidor no tiene configurado el envío de correos para restablecer la contraseña.';
  static const errorEmptyMasterPassword = 'Escribe tu contraseña maestra.';
  static String errorMasterPasswordTooShort(int min) =>
      'Usa al menos $min caracteres. Una frase larga es más fácil de recordar.';
  static const errorMasterPasswordMismatch = 'Las contraseñas no coinciden.';
  static const errorWrongMasterPassword = 'Contraseña maestra incorrecta.';
  static const errorVaultExists = 'Ya existe una bóveda para esta cuenta.';
  static const errorVaultCorrupted = 'Los datos de la bóveda en el servidor están incompletos.';
  static const errorVaultLocked = 'La bóveda está bloqueada. Desbloquéala para continuar.';
  static const errorEmptyTitle = 'Ponle un nombre.';
  static String get errorBiometricInvalidated => _android
      ? 'Las huellas del teléfono cambiaron y el desbloqueo con huella se desactivó. Usa la contraseña maestra y vuelve a activarlo.'
      : 'La biometría del dispositivo cambió y el desbloqueo biométrico se desactivó. Usa la contraseña maestra y vuelve a activarlo.';
  static String get errorBiometricFailed => _android
      ? 'No se pudo desbloquear con la huella. Usa la contraseña maestra.'
      : 'No se pudo desbloquear con biometría. Usa la contraseña maestra.';
  static String errorUnexpected(String detail) => 'Algo salió mal: $detail';
  static const errorUnexpectedGeneric = 'Algo salió mal. Inténtalo de nuevo.';
}
