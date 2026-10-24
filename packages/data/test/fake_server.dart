import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An in-memory stand-in for the Worker in backend/: the same routes, revisions and error codes.
class FakeServer {
  Map<String, dynamic>? vault;
  final Map<String, ({String? data, bool deleted, int revision})> rows = {};
  int revision = 0;
  bool offline = false;
  bool revoked = false;
  final List<List<Map<String, dynamic>>> receivedChanges = [];

  late final http.Client client = MockClient((request) async {
    if (offline) throw http.ClientException('Network is unreachable');
    if (request.headers['Authorization'] != 'Bearer token-1' || revoked) {
      return _json(401, {'error': 'unauthorized'});
    }
    final body = request.body.isEmpty ? <String, dynamic>{} : jsonDecode(request.body) as Map<String, dynamic>;
    switch ((request.method, request.url.path)) {
      case ('GET', '/v1/vault'):
        return vault == null ? _json(404, {'error': 'vault_missing'}) : _json(200, {...vault!, 'revision': revision});
      case ('POST', '/v1/vault'):
        if (vault != null) return _json(409, {'error': 'vault_exists'});
        vault = body;
        return _json(201, {'revision': 0});
      case ('POST', '/v1/vault/sync'):
        final changes = (body['changes'] as List<dynamic>).cast<Map<String, dynamic>>();
        receivedChanges.add(changes);
        for (final change in changes) {
          write(change['id'] as String, change['op'] == 'delete' ? null : change['data'] as String);
        }
        final since = body['since'] as int;
        final reset = since > revision;
        final changed = rows.entries.where((e) => e.value.revision > (reset ? 0 : since)).toList()
          ..sort((a, b) => a.value.revision.compareTo(b.value.revision));
        return _json(200, {
          'revision': revision,
          'reset': reset,
          'entries': [
            for (final e in changed)
              {'id': e.key, 'v': 1, 'data': e.value.data, 'deleted': e.value.deleted, 'revision': e.value.revision},
          ],
        });
    }
    return _json(404, {'error': 'not_found'});
  });

  /// A write as another device would make it.
  void write(String id, String? data) {
    revision++;
    rows[id] = (data: data, deleted: data == null, revision: revision);
  }

  static http.Response _json(int status, Object body) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
}
