import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/dependencies.dart';
import '../../common/error_messages.dart';
import '../../common/secret_clipboard.dart';
import '../../common/sites.dart';
import '../../common/strings.dart';

/// A row of the list. No secrets: the password is looked up only when the user copies it.
class EntryListItem {
  const EntryListItem({required this.id, required this.title, required this.subtitle, required this.hasPassword});

  final String id;
  final String title;
  final String subtitle;
  final bool hasPassword;

  @override
  bool operator ==(Object other) =>
      other is EntryListItem &&
      other.id == id &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.hasPassword == hasPassword;

  @override
  int get hashCode => Object.hash(id, title, subtitle, hasPassword);

  @override
  String toString() => 'EntryListItem($id, $title, $subtitle, $hasPassword)';
}

class VaultListState {
  const VaultListState({
    this.isLoading = true,
    this.items = const [],
    this.totalCount = 0,
    this.query = '',
    this.error,
  });

  final bool isLoading;
  final List<EntryListItem> items;
  final int totalCount;
  final String query;
  final AppError? error;
}

class VaultListCubit extends Cubit<VaultListState> {
  VaultListCubit(this._deps) : super(const VaultListState()) {
    _subscribe();
  }

  final Dependencies _deps;
  final _messages = StreamController<String>();
  StreamSubscription<List<VaultEntry>>? _subscription;
  List<VaultEntry>? _entries;
  AppError? _error;
  var _query = '';

  /// One-off messages for the snackbar.
  Stream<String> get messages => _messages.stream;

  // Lives as long as the unlocked app: coming back from an entry shows the list as it is now (a
  // new or deleted entry included) on the very first frame.
  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _deps.observeEntries().listen(
      (entries) {
        _entries = entries;
        _error = null;
        _publish();
      },
      onError: (Object error) {
        _error = toAppError(error);
        _publish();
      },
    );
  }

  void _publish() {
    if (isClosed) return;
    final all = _entries ?? const <VaultEntry>[];
    emit(
      VaultListState(
        isLoading: _entries == null && _error == null,
        items: _deps.searchEntries(all, _query).map(_toListItem).toList(),
        totalCount: all.length,
        query: _query,
        error: _entries == null ? _error : null,
      ),
    );
  }

  void onQueryChange(String value) {
    _query = value;
    _publish();
  }

  Future<void> retry() async {
    _error = null;
    _publish();
    final result = await _deps.syncVault();
    if (result case Failure(:final error) when _entries == null) {
      _error = error;
      _publish();
    }
  }

  /// Pull to refresh: what other devices changed, now.
  Future<void> refresh() async {
    final result = await _deps.syncVault();
    if (result case Failure(:final error)) _messages.add(errorMessage(error));
  }

  void lock() => _deps.lockVault();

  Future<void> copyPassword(String id) async {
    final entry = _entries?.where((e) => e.id == id).firstOrNull;
    if (entry == null || entry.password.isEmpty) return;
    await _deps.clipboard.copySecret(S.clipboardLabelPassword, entry.password);
    _messages.add(secretCopiedMessage(_deps.clipboard));
  }

  EntryListItem _toListItem(VaultEntry entry) => EntryListItem(
        id: entry.id,
        title: entry.title,
        subtitle: entry.username.trim().isEmpty ? siteHost(entry.url) ?? '' : entry.username,
        hasPassword: entry.password.isNotEmpty,
      );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    // Not awaited: a stream nobody listened to never reports done.
    unawaited(_messages.close());
    return super.close();
  }
}
