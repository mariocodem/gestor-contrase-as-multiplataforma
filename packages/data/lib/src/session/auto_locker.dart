import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';

import 'vault_session.dart';

/// Drops the vault key once the app has spent the configured time in the background. The app
/// forwards lifecycle changes here.
class AutoLocker {
  AutoLocker({required this._session, required SettingsRepository settings, DateTime Function()? now})
      : _now = now ?? DateTime.now {
    settings.settings.listen((value) => _timeout = value.autoLock.duration);
  }

  final VaultSession _session;
  final DateTime Function() _now;
  Duration _timeout = const AppSettings().autoLock.duration;
  Timer? _timer;
  final _away = Stopwatch();
  DateTime? _backgroundedAt;

  void onAppBackgrounded() {
    if (_backgroundedAt != null) return;
    _backgroundedAt = _now();
    _away
      ..reset()
      ..start();
    if (_timeout == Duration.zero) {
      _session.close();
    } else {
      _timer = Timer(_timeout, _session.close);
    }
  }

  void onAppForegrounded() {
    _timer?.cancel();
    _timer = null;
    final since = _backgroundedAt;
    if (since == null) return;
    // Timers and the monotonic clock can stop while the device sleeps; the wall clock can be
    // moved back. Whichever says more time passed decides.
    final wall = _now().difference(since);
    final away = wall > _away.elapsed ? wall : _away.elapsed;
    if (away >= _timeout) _session.close();
    _away.stop();
    _backgroundedAt = null;
  }
}
