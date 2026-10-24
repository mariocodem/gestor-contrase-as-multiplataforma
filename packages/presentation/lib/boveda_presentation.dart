/// Bóveda's screens: sign-in, create and unlock the vault, the vault list, an entry's detail and
/// editor, the generator and settings, each with its cubit. Depends on the domain and the design
/// system only; the app's composition root hands it a [Dependencies].
library;

export 'src/common/dependencies.dart';
export 'src/common/secret_clipboard.dart';
export 'src/common/strings.dart' show S;
export 'src/root/boveda_app.dart';
