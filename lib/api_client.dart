import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  const ApiClient();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> health() async {
    final res = await http.get(_uri('/health'));
    return _decodeOrThrow(res, fallbackError: 'Health check failed');
  }

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final res = await http.post(
      _uri('/auth/request-otp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return _decodeOrThrow(res, fallbackError: 'Request OTP failed');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await http.post(
      _uri('/auth/verify-otp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return _decodeOrThrow(res, fallbackError: 'Verify OTP failed');
  }

  Map<String, dynamic> _decodeOrThrow(
    http.Response res, {
    required String fallbackError,
  }) {
    final body = res.body.trim();
    dynamic decoded;

    if (body.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = <String, dynamic>{'message': 'Invalid server response'};
      }
    }

    Map<String, dynamic> map;
    if (decoded is Map) {
      map = Map<String, dynamic>.from(decoded);
    } else {
      map = <String, dynamic>{'data': decoded};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return map;

    final msg = (map['message'] ?? fallbackError).toString();
    throw ApiException(msg);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}