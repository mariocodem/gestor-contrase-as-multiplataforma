import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_screen.dart';
import '../generator/generator_screen.dart';
import '../lock/lock_screen.dart';
import '../root/root_cubit.dart';
import '../root/status_screens.dart';
import '../settings/settings_screen.dart';
import '../vault/detail/entry_detail_screen.dart';
import '../vault/editor/entry_editor_screen.dart';
import '../vault/list/vault_list_screen.dart';
import 'unlocked_shell.dart';

/// Where each part of the app lives. The [AppState] decides which of them may show: every
/// navigation is redirected to the part the current state allows.
abstract final class Paths {
  static const loading = '/loading';
  static const auth = '/auth';
  static const setup = '/setup';
  static const lock = '/lock';
  static const failed = '/failed';
  static const vault = '/vault';
  static const newEntry = '/vault/new';
  static String entry(String id) => '/vault/entry/$id';
  static String editEntry(String id) => '/vault/entry/$id/edit';
  static const generator = '/generator';
  static const settings = '/settings';
}

GoRouter createAppRouter(RootCubit root) {
  // The settings page may still be building while it leaves after a lock; it keeps the last user.
  var lastUser = const User(id: '', email: null);
  User unlockedUser() {
    final appState = root.state.appState;
    if (appState is Unlocked) lastUser = appState.user;
    return lastUser;
  }

  return GoRouter(
    initialLocation: Paths.loading,
    refreshListenable: _CubitListenable(root),
    redirect: (context, state) {
      final appState = root.state.appState;
      final path = state.uri.path;
      final target = switch (appState) {
        AppLoading() => Paths.loading,
        SignedOut() => Paths.auth,
        NeedsSetup() => Paths.setup,
        Locked() => Paths.lock,
        AppFailed() => Paths.failed,
        Unlocked() => null,
      };
      if (target != null) return path == target ? null : target;
      // Unlocked: anything outside the vault's places goes to the vault.
      final unlockedPlace = path.startsWith(Paths.vault) || path == Paths.generator || path == Paths.settings;
      return unlockedPlace ? null : Paths.vault;
    },
    routes: [
      GoRoute(path: Paths.loading, pageBuilder: (context, state) => _statePage(state, root, const LoadingScreen())),
      GoRoute(path: Paths.auth, pageBuilder: (context, state) => _statePage(state, root, const AuthScreen())),
      GoRoute(
        path: Paths.setup,
        pageBuilder: (context, state) => _statePage(state, root, _LockPlace(root: root, isSetup: true)),
      ),
      GoRoute(
        path: Paths.lock,
        pageBuilder: (context, state) => _statePage(state, root, _LockPlace(root: root, isSetup: false)),
      ),
      GoRoute(
        path: Paths.failed,
        pageBuilder: (context, state) => _statePage(
          state,
          root,
          BlocAppError(
            root: root,
            builder: (error) => FailureScreen(error: error, onRetry: root.retry, onSignOut: root.signOut),
          ),
        ),
      ),
      StatefulShellRoute(
        pageBuilder: (context, state, shell) => _statePage(
          state,
          root,
          UnlockedShell(shell: shell, location: state.uri.path),
        ),
        navigatorContainerBuilder: (context, shell, children) =>
            FadeThroughBranches(currentIndex: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Paths.vault,
                builder: (context, state) => const VaultListScreen(),
                routes: [
                  GoRoute(path: 'new', builder: (context, state) => const EntryEditorScreen(id: null)),
                  GoRoute(
                    path: 'entry/:id',
                    builder: (context, state) => EntryDetailScreen(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => EntryEditorScreen(id: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Paths.generator, builder: (context, state) => const GeneratorScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Paths.settings,
                builder: (context, state) => SettingsScreen(user: unlockedUser()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The parts of the app cross-fade. Leaving a lock screen for the vault is special: the shackle
/// lifts first, then the vault comes up through the lock screen, already usable while it fades.
///
/// Every state page runs 460 ms, the longest of these choreographies, because a page's duration is
/// fixed when it is created and a lock screen doesn't know yet how it will leave.
Page<void> _statePage(GoRouterState state, RootCubit root, Widget child) => CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 460),
      reverseTransitionDuration: const Duration(milliseconds: 460),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (!BovedaMotion.enabled(context)) return child;
        final opening = root.state.opening;
        final leaving = animation.status == AnimationStatus.reverse;
        // Arriving: the vault from 120 ms to 340 ms, growing from 97 %; anything else from 60 ms
        // for 220 ms. Leaving (the animation runs backwards): the lock screen from 140 ms to
        // 300 ms, anything else within the first 120 ms.
        final fade = CurvedAnimation(
          parent: animation,
          curve: opening ? const Interval(120 / 460, 340 / 460) : const Interval(60 / 460, 280 / 460),
          reverseCurve: opening ? const Interval(160 / 460, 320 / 460) : const Interval(340 / 460, 1),
        );
        final grow = opening && !leaving
            ? Tween(begin: 0.97, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(120 / 460, 1, curve: BovedaMotion.emphasizedDecelerate)),
              )
            : const AlwaysStoppedAnimation(1.0);
        // The same shape every frame, so the page keeps its state whichever way it moves.
        return ScaleTransition(
          scale: grow,
          child: FadeTransition(opacity: fade, child: RouteLeaving(leaving: leaving, child: child)),
        );
      },
    );

/// Tells a screen its page is on the way out, so the lock screen can lift its shackle as it goes.
class RouteLeaving extends InheritedWidget {
  const RouteLeaving({super.key, required this.leaving, required super.child});

  final bool leaving;

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<RouteLeaving>()?.leaving ?? false;

  @override
  bool updateShouldNotify(RouteLeaving old) => old.leaving != leaving;
}

class _LockPlace extends StatelessWidget {
  const _LockPlace({required this.root, required this.isSetup});

  final RootCubit root;
  final bool isSetup;

  @override
  Widget build(BuildContext context) {
    final state = root.state;
    final user = switch (state.appState) {
      NeedsSetup(:final user) || Locked(:final user) => user,
      // Already leaving towards the vault (or out of the account): keep the last user shown.
      Unlocked(:final user) => user,
      _ => switch (state.previousAppState) {
          NeedsSetup(:final user) || Locked(:final user) => user,
          _ => const User(id: '', email: null),
        },
    };
    return LockScreen(
      key: ValueKey('${isSetup ? 'setup' : 'lock'}-${user.id}'),
      user: user,
      isSetup: isSetup,
      onSignOut: root.signOut,
      opening: RouteLeaving.of(context) && state.appState is Unlocked,
      arrivedFromUnlocked: state.previousAppState is Unlocked,
    );
  }
}

/// The failure screen with the error of the moment it showed.
class BlocAppError extends StatelessWidget {
  const BlocAppError({super.key, required this.root, required this.builder});

  final RootCubit root;
  final Widget Function(AppError error) builder;

  @override
  Widget build(BuildContext context) {
    final appState = root.state.appState;
    return builder(appState is AppFailed ? appState.error : const AppError.unexpected(null));
  }
}

/// Lets go_router re-run its redirect whenever the app state changes.
class _CubitListenable extends ChangeNotifier {
  _CubitListenable(RootCubit cubit) {
    _subscription = cubit.stream
        .map((state) => state.appState.runtimeType)
        .distinct()
        .listen((_) => notifyListeners());
  }

  late final StreamSubscription<Type> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
