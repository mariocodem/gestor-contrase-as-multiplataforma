import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/dependencies.dart';
import '../../common/error_messages.dart';

class EntryEditorState {
  const EntryEditorState({
    this.isNew = true,
    this.isLoading = false,
    this.draft = const VaultEntry(),
    this.hasChanges = false,
    this.strength = PasswordStrength.empty,
    this.isSaving = false,
    this.error,
  });

  final bool isNew;
  final bool isLoading;
  final VaultEntry draft;
  final bool hasChanges;
  final PasswordStrength strength;
  final bool isSaving;
  final String? error;

  bool get canSave => hasChanges && draft.title.trim().isNotEmpty && !isSaving && !isLoading;

  EntryEditorState copyWith({
    bool? isLoading,
    VaultEntry? draft,
    bool? hasChanges,
    PasswordStrength? strength,
    bool? isSaving,
    String? Function()? error,
  }) =>
      EntryEditorState(
        isNew: isNew,
        isLoading: isLoading ?? this.isLoading,
        draft: draft ?? this.draft,
        hasChanges: hasChanges ?? this.hasChanges,
        strength: strength ?? this.strength,
        isSaving: isSaving ?? this.isSaving,
        error: error == null ? this.error : error(),
      );
}

sealed class EntryEditorEvent {
  const EntryEditorEvent();
}

final class EditorSaved extends EntryEditorEvent {
  const EditorSaved(this.id, {required this.wasNew});

  final String id;
  final bool wasNew;
}

final class EditorGone extends EntryEditorEvent {
  const EditorGone();
}

class EntryEditorCubit extends Cubit<EntryEditorState> {
  EntryEditorCubit(this._deps, this._id) : super(EntryEditorState(isNew: _id == null, isLoading: _id != null)) {
    final id = _id;
    if (id != null) unawaited(_load(id));
  }

  final Dependencies _deps;
  final String? _id;
  final _events = StreamController<EntryEditorEvent>();
  VaultEntry _original = const VaultEntry();

  Stream<EntryEditorEvent> get events => _events.stream;

  Future<void> _load(String id) async {
    final entry = _deps.observeEntry.current(id) ?? await _deps.observeEntry(id).first;
    if (isClosed) return;
    if (entry == null) {
      _events.add(const EditorGone());
      return;
    }
    _original = entry;
    emit(state.copyWith(isLoading: false, draft: entry, strength: _deps.evaluateStrength(entry.password)));
  }

  void onTitleChange(String value) => _edit((draft) => draft.copyWith(title: value));

  void onUsernameChange(String value) => _edit((draft) => draft.copyWith(username: value));

  void onPasswordChange(String value) => _edit((draft) => draft.copyWith(password: value));

  void onUrlChange(String value) => _edit((draft) => draft.copyWith(url: value));

  void onNotesChange(String value) => _edit((draft) => draft.copyWith(notes: value));

  Future<void> save() async {
    final current = state;
    if (!current.canSave) return;
    emit(state.copyWith(isSaving: true, error: () => null));
    final result = await _deps.saveEntry(current.draft);
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        _events.add(EditorSaved(value.id, wasNew: current.isNew));
      case Failure(:final error):
        emit(state.copyWith(isSaving: false, error: () => errorMessage(error)));
    }
  }

  void _edit(VaultEntry Function(VaultEntry draft) transform) {
    final draft = transform(state.draft);
    emit(
      state.copyWith(
        draft: draft,
        hasChanges: draft != _original,
        strength: draft.password != state.draft.password ? _deps.evaluateStrength(draft.password) : state.strength,
        error: () => null,
      ),
    );
  }

  @override
  Future<void> close() async {
    // Not awaited: a stream nobody listened to never reports done.
    unawaited(_events.close());
    return super.close();
  }
}
