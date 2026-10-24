import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../remote/boveda_api.dart';

/// This device's copy of a vault: what the server holds (ciphertext only) plus the writes not yet
/// sent. It lets the vault open, list and change offline; the next sync reconciles it.
class CachedVault {
  CachedVault({this.meta, this.revision = 0, Map<String, String>? rows, List<ChangeDto>? pending})
      : rows = rows ?? {},
        pending = pending ?? [];

  factory CachedVault.fromJson(Map<String, dynamic> json) => CachedVault(
        meta: json['meta'] == null ? null : VaultMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
        revision: (json['revision'] as num?)?.toInt() ?? 0,
        rows: (json['rows'] as Map<String, dynamic>? ?? const {}).map((id, data) => MapEntry(id, data as String)),
        pending: [
          for (final change in json['pending'] as List<dynamic>? ?? const [])
            ChangeDto.fromJson(change as Map<String, dynamic>),
        ],
      );

  VaultMetaDto? meta;

  /// The last server revision folded into [rows].
  int revision;

  /// Entry id → base64 ciphertext, local writes applied.
  final Map<String, String> rows;

  /// Writes made here that the server hasn't acknowledged, oldest first, one per entry.
  final List<ChangeDto> pending;

  Map<String, dynamic> toJson() => {
        'meta': meta?.toJson(),
        'revision': revision,
        'rows': rows,
        'pending': [for (final change in pending) change.toJson()],
      };
}

class VaultCache {
  VaultCache([SharedPreferencesAsync? preferences]) : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  String _key(String userId) => 'vault_cache_$userId';

  Future<CachedVault> load(String userId) async {
    try {
      final raw = await _preferences.getString(_key(userId));
      if (raw != null) return CachedVault.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A damaged copy is rebuilt from the server on the next sync.
    }
    return CachedVault();
  }

  Future<void> save(String userId, CachedVault vault) =>
      _preferences.setString(_key(userId), jsonEncode(vault.toJson()));
}
