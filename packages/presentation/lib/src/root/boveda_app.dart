import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../common/dependencies.dart';
import '../common/messages.dart';
import '../common/strings.dart';
import '../navigation/app_router.dart';
import '../navigation/page_transitions.dart';
import 'root_cubit.dart';

/// Bóveda: the themed app, showing whichever part the current app state allows.
class BovedaApp extends StatefulWidget {
  const BovedaApp({super.key, required this.dependencies, this.overlay});

  final Dependencies dependencies;

  /// Drawn above every screen (the app switcher privacy cover).
  final Widget? overlay;

  @override
  State<BovedaApp> createState() => _BovedaAppState();
}

class _BovedaAppState extends State<BovedaApp> {
  late final RootCubit _root = RootCubit(widget.dependencies);
  late final GoRouter _router = createAppRouter(_root);

  @override
  void dispose() {
    _router.dispose();
    _root.close();
    super.dispose();
  }

  static ThemeData _withTransitions(ThemeData theme) => theme.copyWith(pageTransitionsTheme: bovedaPageTransitions);

  @override
  Widget build(BuildContext context) => RepositoryProvider.value(
        value: widget.dependencies,
        child: BlocProvider.value(
          value: _root,
          child: DynamicColorBuilder(
            builder: (light, dark) => BlocSelector<RootCubit, RootState, bool>(
              selector: (state) => state.dynamicColor,
              builder: (context, dynamicColor) {
                final useDynamic = dynamicColor && light != null;
                return DynamicColorAvailability(
                  available: light != null,
                  child: MaterialApp.router(
                    title: S.appTitle,
                    debugShowCheckedModeBanner: false,
                    locale: const Locale('es'),
                    supportedLocales: const [Locale('es')],
                    localizationsDelegates: GlobalMaterialLocalizations.delegates,
                    themeMode: ThemeMode.system,
                    theme: _withTransitions(
                      bovedaTheme(brightness: Brightness.light, dynamicScheme: useDynamic ? light.harmonized() : null),
                    ),
                    darkTheme: _withTransitions(
                      bovedaTheme(brightness: Brightness.dark, dynamicScheme: useDynamic ? dark?.harmonized() : null),
                    ),
                    routerConfig: _router,
                    builder: (context, child) =>
                        widget.overlay == null ? child! : Stack(children: [child!, widget.overlay!]),
                  ),
                );
              },
            ),
          ),
        ),
      );
}
