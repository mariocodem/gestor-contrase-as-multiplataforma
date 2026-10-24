import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';

class RootState {
  const RootState({this.appState = const AppLoading(), this.previousAppState, this.dynamicColor = false});

  final AppState appState;

  /// The part of the app shown before this one, to tell a fresh lock screen from one the vault
  /// just closed into, and a lock screen leaving because the vault opened.
  final AppState? previousAppState;
  final bool dynamicColor;

  /// The vault is opening from a lock screen right now.
  bool get opening => appState is Unlocked && (previousAppState is Locked || previousAppState is NeedsSetup);

  RootState copyWith({AppState? appState, bool? dynamicColor}) {
    final changed = appState != null && appState.runtimeType != this.appState.runtimeType;
    return RootState(
      appState: appState ?? this.appState,
      previousAppState: changed ? this.appState : previousAppState,
      dynamicColor: dynamicColor ?? this.dynamicColor,
    );
  }
}

/// Which part of the app the user may see, and the colour choice that themes all of it.
class RootCubit extends Cubit<RootState> {
  RootCubit(this._deps) : super(const RootState()) {
    _settings = _deps.observeSettings().listen((settings) => emit(state.copyWith(dynamicColor: settings.dynamicColor)));
    _observe();
  }

  final Dependencies _deps;
  StreamSubscription<AppState>? _appState;
  late final StreamSubscription<AppSettings> _settings;

  void _observe() {
    unawaited(_appState?.cancel());
    _appState = _deps.observeAppState().listen((appState) => emit(state.copyWith(appState: appState)));
  }

  void retry() {
    emit(state.copyWith(appState: const AppLoading()));
    _observe();
  }

  Future<void> signOut() => _deps.signOut();

  @override
  Future<void> close() async {
    await _appState?.cancel();
    await _settings.cancel();
    return super.close();
  }
}
