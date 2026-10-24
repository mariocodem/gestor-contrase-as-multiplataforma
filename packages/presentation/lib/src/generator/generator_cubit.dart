import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/secret_clipboard.dart';
import '../common/strings.dart';

class GeneratorState {
  const GeneratorState({this.options = const PasswordOptions(), this.password});

  final PasswordOptions options;

  /// Null until the saved options have loaded.
  final GeneratedPassword? password;
}

/// Every change to the options produces a fresh password at once; the options are remembered.
class GeneratorCubit extends Cubit<GeneratorState> {
  GeneratorCubit(this._deps) : super(const GeneratorState()) {
    unawaited(_load());
  }

  final Dependencies _deps;
  final _messages = StreamController<String>();

  Stream<String> get messages => _messages.stream;

  Future<void> _load() async {
    final options = (await _deps.observeSettings().first).generatorOptions;
    if (!isClosed) emit(GeneratorState(options: options, password: _deps.generatePassword(options)));
  }

  /// Called continuously while dragging; saved once the drag ends.
  void onLengthChange(int length) {
    if (length != state.options.length) _apply((options) => options.copyWith(length: length), persist: false);
  }

  void onLengthChangeFinished() => _persist(state.options);

  void onUppercaseChange(bool enabled) => _apply((options) => options.copyWith(uppercase: enabled));

  void onLowercaseChange(bool enabled) => _apply((options) => options.copyWith(lowercase: enabled));

  void onDigitsChange(bool enabled) => _apply((options) => options.copyWith(digits: enabled));

  void onSymbolsChange(bool enabled) => _apply((options) => options.copyWith(symbols: enabled));

  void onAvoidAmbiguousChange(bool enabled) => _apply((options) => options.copyWith(avoidAmbiguous: enabled));

  void regenerate() => emit(GeneratorState(options: state.options, password: _deps.generatePassword(state.options)));

  Future<void> copy() async {
    final value = state.password?.value;
    if (value == null) return;
    await _deps.clipboard.copySecret(S.clipboardLabelPassword, value);
    _messages.add(secretCopiedMessage(_deps.clipboard));
  }

  void _apply(PasswordOptions Function(PasswordOptions options) transform, {bool persist = true}) {
    final options = transform(state.options);
    // A password needs characters from somewhere; the UI also disables the last switch.
    if (options.enabledSetCount == 0) return;
    emit(GeneratorState(options: options, password: _deps.generatePassword(options)));
    if (persist) _persist(options);
  }

  void _persist(PasswordOptions options) => unawaited(_deps.saveGeneratorOptions(options));

  @override
  Future<void> close() async {
    // Not awaited: a stream nobody listened to never reports done.
    unawaited(_messages.close());
    return super.close();
  }
}
