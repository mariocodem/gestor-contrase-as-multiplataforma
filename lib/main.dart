import 'dart:async';

import 'package:boveda_data/boveda_data.dart';
import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_presentation/boveda_presentation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config.dart';

/// Composition root: the only place that knows every layer. It builds the data layer, hands the
/// screens their dependencies, and forwards app lifecycle changes to the auto-lock.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  final config = AppConfig.resolve();
  if (config == null) {
    runApp(const _MissingServerApp());
    return;
  }
  final data = DataLayer.create(apiUrl: config.apiUrl);
  runApp(BovedaRoot(data: data));
}

class BovedaRoot extends StatefulWidget {
  const BovedaRoot({super.key, required this.data});

  final DataLayer data;

  @override
  State<BovedaRoot> createState() => _BovedaRootState();
}

class _BovedaRootState extends State<BovedaRoot> {
  late final Dependencies _dependencies = Dependencies(
    auth: widget.data.auth,
    vault: widget.data.vault,
    biometrics: widget.data.biometrics,
    settings: widget.data.settings,
    clipboard: PlatformSecretClipboard(),
  );
  late final AppLifecycleListener _lifecycle;

  /// iOS snapshots the screen for the app switcher as soon as the app goes inactive; Android
  /// keeps the vault out of it with FLAG_SECURE (MainActivity.kt).
  var _covered = false;
  static bool get _coverForSwitcher => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      // The whole app leaving the screen (not one page) starts the auto-lock countdown.
      onHide: widget.data.autoLocker.onAppBackgrounded,
      onShow: widget.data.autoLocker.onAppForegrounded,
      // Back in front: fetch what other devices changed meanwhile.
      onResume: () => unawaited(widget.data.vault.sync().catchError((Object _) {})),
      onStateChange: (state) {
        if (!_coverForSwitcher) return;
        final cover = state != AppLifecycleState.resumed;
        if (cover != _covered) setState(() => _covered = cover);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BovedaApp(
        dependencies: _dependencies,
        overlay: _covered ? const _PrivacyCover() : null,
      );
}

/// What the app switcher shows instead of the vault.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: const Center(child: AppEmblem()),
        ),
      );
}

/// A release build made without BOVEDA_API_URL: say what's missing rather than failing on every request.
class _MissingServerApp extends StatelessWidget {
  const _MissingServerApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: bovedaTheme(brightness: Brightness.light),
        darkTheme: bovedaTheme(brightness: Brightness.dark),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Scaffold(
              body: CenteredForm(
                children: [
                  const AppEmblem(),
                  const SizedBox(height: 24),
                  Text('Falta la dirección del servidor', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Esta versión se compiló sin BOVEDA_API_URL. Vuelve a compilarla con '
                    '--dart-define-from-file=config/prod.json (ver SETUP.md).',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );
}
