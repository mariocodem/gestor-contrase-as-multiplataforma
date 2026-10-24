import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/dependencies.dart';
import '../../common/error_messages.dart';
import '../../common/secret_clipboard.dart';
import '../../common/strings.dart';

sealed class EntryDetailState {
  const EntryDetailState();
}

final class DetailLoading extends EntryDetailState {
  const DetailLoading();
}

final class DetailMissing extends EntryDetailState {
  const DetailMissing();
}

final class DetailLoaded extends EntryDetailState {
  const DetailLoaded({required this.entry, required this.strength, required this.passwordVisible});

  final VaultEntry entry;
  final PasswordStrength strength;
  final bool passwordVisible;
}

sealed class EntryDetailEvent {
  const EntryDetailEvent();
}

final class DetailMessage extends EntryDetailEvent {
  const DetailMessage(this.text);

  final String text;
}

final class DetailDeleted extends EntryDetailEvent {
  const DetailDeleted(this.title);

  final String title;
}

class EntryDetailCubit extends Cubit<EntryDetailState> {
  /// Opened from the list, the entry is already decrypted: showing it on the first frame skips a
  /// blank page, and gives the key cap flying in from the list a place to land.
  EntryDetailCubit(this._deps, this._id) : super(_initial(_deps, _id)) {
    _lastEntry = _deps.observeEntry.current(_id);
    _subscription = _deps.observeEntry(_id).listen((entry) {
      if (entry != null) _lastEntry = entry;
      _current = entry;
      _publish();
    });
  }

  static EntryDetailState _initial(Dependencies deps, String id) {
    final current = deps.observeEntry.current(id);
    return current == null
        ? const DetailLoading()
        : DetailLoaded(entry: current, strength: deps.evaluateStrength(current.password), passwordVisible: false);
  }

  final Dependencies _deps;
  final String _id;
  final _events = StreamController<EntryDetailEvent>();
  late final StreamSubscription<VaultEntry?> _subscription;
  VaultEntry? _lastEntry;
  VaultEntry? _current;
  var _visible = false;
  var _deleting = false;

  Stream<EntryDetailEvent> get events => _events.stream;

  VaultEntry? get _entry => switch (state) {
        DetailLoaded(:final entry) => entry,
        _ => null,
      };

  void _publish() {
    if (isClosed) return;
    // While leaving after a delete, keep showing the entry instead of flashing "missing".
    final shown = _current ?? (_deleting ? _lastEntry : null);
    emit(
      shown == null
          ? const DetailMissing()
          : DetailLoaded(entry: shown, strength: _deps.evaluateStrength(shown.password), passwordVisible: _visible),
    );
  }

  void togglePasswordVisible() {
    _visible = !_visible;
    if (state is DetailLoaded) {
      final loaded = state as DetailLoaded;
      emit(DetailLoaded(entry: loaded.entry, strength: loaded.strength, passwordVisible: _visible));
    }
  }

  Future<void> copyPassword() async {
    final password = _entry?.password ?? '';
    if (password.isEmpty) return;
    await _deps.clipboard.copySecret(S.clipboardLabelPassword, password);
    _events.add(DetailMessage(secretCopiedMessage(_deps.clipboard)));
  }

  Future<void> copyUsername() async {
    final username = _entry?.username ?? '';
    if (username.isEmpty) return;
    await _deps.clipboard.copyPlain(S.clipboardLabelUsername, username);
    if (!_deps.clipboard.systemConfirmsCopies) _events.add(const DetailMessage(S.copiedUsername));
  }

  Future<void> delete() async {
    final current = _entry;
    if (current == null) return;
    _deleting = true;
    final result = await _deps.deleteEntry(current.id);
    switch (result) {
      case Success():
        _events.add(DetailDeleted(current.title));
      case Failure(:final error):
        _deleting = false;
        _events.add(DetailMessage(errorMessage(error)));
        _publish();
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    // Not awaited: a stream nobody listened to never reports done.
    unawaited(_events.close());
    return super.close();
  }
}
