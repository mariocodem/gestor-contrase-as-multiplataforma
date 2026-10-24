import 'dart:convert';

import 'package:boveda_data/boveda_data.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Far below the real cost; the tests only care about correctness.
  const iterations = 1000;
  final crypto = VaultCrypto(pbkdf2: dartPbkdf2);

  test('a wrapped key unwraps with the same password', () async {
    final salt = crypto.newSalt();
    final vaultKey = crypto.newVaultKey();
    final wrapped = await crypto.wrapKey(await crypto.deriveKey('correct horse', salt, iterations), vaultKey);

    final unwrapped = await crypto.unwrapKey(await crypto.deriveKey('correct horse', salt, iterations), wrapped);

    expect(unwrapped, vaultKey);
  });

  test('a wrapped key rejects a wrong password', () async {
    final salt = crypto.newSalt();
    final wrapped = await crypto.wrapKey(await crypto.deriveKey('correct horse', salt, iterations), crypto.newVaultKey());
    final wrong = await crypto.deriveKey('battery staple', salt, iterations);

    expect(() => crypto.unwrapKey(wrong, wrapped), throwsA(isA<CiphertextRejected>()));
  });

  test('encryption round-trips and uses a fresh iv each time', () async {
    final key = crypto.newVaultKey();
    final plaintext = utf8.encode('contraseña-secreta');

    final first = await crypto.encrypt(key, plaintext, aad: utf8.encode('entry-1'));
    final second = await crypto.encrypt(key, plaintext, aad: utf8.encode('entry-1'));

    expect(first, isNot(second));
    expect(await crypto.decrypt(key, first, aad: utf8.encode('entry-1')), plaintext);
  });

  test('ciphertext moved to another entry or tampered with is rejected', () async {
    final key = crypto.newVaultKey();
    final ciphertext = await crypto.encrypt(key, utf8.encode('secret'), aad: utf8.encode('entry-1'));

    expect(() => crypto.decrypt(key, ciphertext, aad: utf8.encode('entry-2')), throwsA(isA<CiphertextRejected>()));
    final tampered = [...ciphertext]..last ^= 1;
    expect(() => crypto.decrypt(key, tampered, aad: utf8.encode('entry-1')), throwsA(isA<CiphertextRejected>()));
  });

  test('reads what the Android app wrote with javax.crypto, byte for byte', () async {
    // Produced by PBKDF2WithHmacSHA256 + AES/GCM/NoPadding on the JDK, as VaultCrypto.kt did.
    final salt = base64.decode('AAECAwQFBgcICQoLDA0ODw==');
    final passwordKey = await crypto.deriveKey('contraseña maestra', salt, iterations);
    expect(base64.encode(passwordKey), '2Rm7TPJr1XWQ4ZVLf4Qfi+lcNgwm2OB4i/wOnCO3SZ4=');

    final vaultKey = await crypto.unwrapKey(
      passwordKey,
      base64.decode('AQIDBAUGBwgJCgsMjr07eN+Puz6ydU50S1fBatLflt8mfkZK2vcOD/mrdXHBNA0tXCuG188rB5pQkxZu'),
    );
    expect(vaultKey, [for (var i = 0; i < 32; i++) 200 - i]);

    final entry = await EntryCodec(crypto).decode(
      'AbCdEfGhIjKlMnOpQrSt',
      base64.decode(
        'ZGVmZ2hpamtsbW5v28hpQ2cs/KC6hPU4sL4eCRyRd+JBMiAtH5FoWzjI2YpkkY0ayF6aRn06pBX+Ivnbj82h0YIv2lnW6qvPZXDxE91wgFyZLWvQLHWah1D4VsLEU/vUpxyhzOWizDU4oe80tyO/6DoZ9fno/RZrEQ5zEWm3/O8V/nQ2IeY0yNxC+C8S',
      ),
      vaultKey,
    );
    expect(
      entry,
      const VaultEntry(
        id: 'AbCdEfGhIjKlMnOpQrSt',
        title: 'Banco',
        username: 'ana',
        password: 'p4ss!',
        url: 'banco.es',
        notes: 'línea',
        updatedAt: 1700000000000,
      ),
    );
  });

  test('the tuned PBKDF2 matches the RFC 7914 test vectors', () async {
    String hex(List<int> bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(
      hex(await dartPbkdf2('password', utf8.encode('salt'), 1)),
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    );
    expect(
      hex(await dartPbkdf2('password', utf8.encode('salt'), 4096)),
      'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
    );
  });

  group('entry codec', () {
    final codec = EntryCodec(crypto);
    final key = crypto.newVaultKey();

    test('round-trips every field', () async {
      const entry = VaultEntry(
        id: 'abc',
        title: 'Banco',
        username: 'ana',
        password: 'pä55"wörd/\\',
        url: 'https://banco.es',
        notes: 'PIN: 1234\nsegunda línea',
        updatedAt: 1700000000000,
      );

      expect(await codec.decode('abc', await codec.encode(entry, key), key), entry);
    });

    test('reads the original org.json format with escaped slashes', () async {
      const legacy = '{"title":"Correo","username":"ana@correo.es","password":"a\\/b","url":"","notes":"","updatedAt":42}';
      final data = await crypto.encrypt(key, utf8.encode(legacy), aad: utf8.encode('doc-1'));

      expect(
        await codec.decode('doc-1', data, key),
        const VaultEntry(id: 'doc-1', title: 'Correo', username: 'ana@correo.es', password: 'a/b', updatedAt: 42),
      );
    });

    test('refuses ciphertext copied from another entry', () async {
      final data = await codec.encode(const VaultEntry(id: 'doc-1', title: 'Banco'), key);

      expect(await codec.decode('doc-2', data, key), isNull);
    });
  });
}
