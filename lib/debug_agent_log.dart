import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Debug-mode NDJSON ingest (session `69acfb`). Do not log secrets/PII.
const _endpoint =
    'http://127.0.0.1:7841/ingest/cfefe8f4-056a-47f7-8e85-4ae9fdc023d8';
const _sessionId = '69acfb';

void agentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'pre-fix',
}) {
  final payload = <String, Object?>{
    'sessionId': _sessionId,
    'runId': runId,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  unawaited(
    http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': _sessionId,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 2))
        .then((_) {}, onError: (_, __) {}),
  );
}
