import 'dart:convert';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/foundation.dart';

import 'vault_crypto.dart';

/// Turns entries into the ciphertext stored on the server and back. The plaintext is a small JSON
/// object whose field names match what the Android app wrote, so its vaults keep decrypting. The
/// entry id is authenticated data: ciphertexts can't be swapped between entries.
class EntryCodec {
  const EntryCodec(this._crypto);

  final VaultCrypto _crypto;

  Future<Uint8List> encode(VaultEntry entry, List<int> key) {
    final json = jsonEncode({
      'title': entry.title,
      'username': entry.username,
      'password': entry.password,
      'url': entry.url,
      'notes': entry.notes,
      'updatedAt': entry.updatedAt,
    });
    return _crypto.encrypt(key, utf8.encode(json), aad: utf8.encode(entry.id));
  }

  /// Null (and logged) when the entry can't be decrypted, so one bad row doesn't hide the rest.
  Future<VaultEntry?> decode(String id, List<int> data, List<int> key) async {
    try {
      final plaintext = await _crypto.decrypt(key, data, aad: utf8.encode(id));
      final json = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
      String text(String field) => json[field] is String ? json[field] as String : '';
      final updatedAt = json['updatedAt'];
      return VaultEntry(
        id: id,
        title: text('title'),
        username: text('username'),
        password: text('password'),
        url: text('url'),
        notes: text('notes'),
        updatedAt: updatedAt is num ? updatedAt.toInt() : 0,
      );
    } catch (e) {
      debugPrint('Entry $id could not be decrypted: $e');
      return null;
    }
  }
}
