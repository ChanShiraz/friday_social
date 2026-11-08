import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiClient {
  final http.Client _client;
  final Duration timeoutDuration;

  DateTime lastBatchSync = DateTime.now().subtract(const Duration(minutes: 12));

  ApiClient({http.Client? client, this.timeoutDuration = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  Future<dynamic> get(String url, {Map<String, String>? headers, Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    ).timeout(timeoutDuration);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      lastBatchSync = DateTime.now();
      return json.decode(response.body);
    } else {
      throw ApiException('Server returned ${response.statusCode}', response.statusCode);
    }
  }

  Future<dynamic> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse(url);
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: body != null ? json.encode(body) : null,
    ).timeout(timeoutDuration);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? json.decode(response.body) : null;
    } else if (response.statusCode == 409) {
      throw ApiException("This event is full. You couldn't join.", 409);
    } else {
      throw ApiException('Server returned ${response.statusCode}', response.statusCode);
    }
  }

  void close() {
    _client.close();
  }
}
