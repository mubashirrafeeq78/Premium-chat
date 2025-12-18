import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Uri _u(String path, [Map<String, String>? q]) {
    final uri = Uri.parse("$baseUrl$path");
    return q == null ? uri : uri.replace(queryParameters: q);
  }

  Map<String, dynamic> _safeJson(http.Response r) {
    final ct = (r.headers["content-type"] ?? "").toLowerCase();
    if (!ct.contains("application/json")) {
      final body = r.body;
      final preview = body.length > 200 ? body.substring(0, 200) : body;
      throw Exception("API not JSON (status ${r.statusCode}). Body: $preview");
    }
    final decoded = jsonDecode(r.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Invalid JSON shape");
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? token,
  }) async {
    final h = <String, String>{
      "Content-Type": "application/json",
      ...(headers ?? {}),
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };

    final r = await http
        .post(_u(path), headers: h, body: jsonEncode(body ?? {}))
        .timeout(AppConfig.timeout);

    final j = _safeJson(r);
    if (r.statusCode >= 400) {
      throw Exception(j["message"]?.toString() ?? "Request failed");
    }
    return j;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    String? token,
  }) async {
    final h = <String, String>{
      ...(headers ?? {}),
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };

    final r = await http.get(_u(path, query), headers: h).timeout(AppConfig.timeout);

    final j = _safeJson(r);
    if (r.statusCode >= 400) {
      throw Exception(j["message"]?.toString() ?? "Request failed");
    }
    return j;
  }
}