import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'strings.dart';

/// Clipboard access behind an interface, so cubits copy without a context and tests can fake it.
abstract interface class SecretClipboard {
  static const clearAfterSeconds = 45;

  /// Copies [text] marked as sensitive and wipes it after [clearAfterSeconds].
  Future<void> copySecret(String label, String text);

  Future<void> copyPlain(String label, String text);

  /// Android 13+ shows its own "copied" confirmation; the app then only adds what the system doesn't say.
  bool get systemConfirmsCopies;
}

/// What to show after copying a secret, without repeating the system's own confirmation.
String secretCopiedMessage(SecretClipboard clipboard) => clipboard.systemConfirmsCopies
    ? S.copiedPasswordShort(SecretClipboard.clearAfterSeconds)
    : S.copiedPassword(SecretClipboard.clearAfterSeconds);

/// Android goes through the app's own channel (MainActivity.kt), which marks secrets as sensitive
/// (hidden from the clipboard preview and keyboard suggestions) and clears them natively. Other
/// platforms use Flutter's clipboard and clear it from a timer.
class PlatformSecretClipboard implements SecretClipboard {
  PlatformSecretClipboard() {
    if (_android) {
      _channel.invokeMethod<bool>('systemConfirmsCopies').then((value) => _confirms = value ?? false, onError: (_) {});
    }
  }

  static const _channel = MethodChannel('boveda/platform');
  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  var _confirms = false;
  Timer? _pendingClear;

  @override
  bool get systemConfirmsCopies => _confirms;

  @override
  Future<void> copySecret(String label, String text) => _copy(label, text, sensitive: true);

  @override
  Future<void> copyPlain(String label, String text) => _copy(label, text, sensitive: false);

  Future<void> _copy(String label, String text, {required bool sensitive}) async {
    _pendingClear?.cancel();
    _pendingClear = null;
    if (_android) {
      try {
        await _channel.invokeMethod<void>('copy', {
          'label': label,
          'text': text,
          'sensitive': sensitive,
          'clearAfterSeconds': SecretClipboard.clearAfterSeconds,
        });
        return;
      } on MissingPluginException {
        // Fall through to Flutter's clipboard.
      }
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (sensitive) {
      _pendingClear = Timer(const Duration(seconds: SecretClipboard.clearAfterSeconds), () => _clearIfStill(text));
    }
  }

  Future<void> _clearIfStill(String text) async {
    try {
      // iOS asks the user before an app reads the clipboard, so there it's cleared unconditionally;
      // elsewhere only if it still holds the secret.
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        final current = await Clipboard.getData(Clipboard.kTextPlain);
        if (current?.text != text) return;
      }
      await Clipboard.setData(const ClipboardData(text: ''));
    } catch (_) {
      // A browser may refuse clipboard access without focus; nothing else to do.
    }
  }
}
