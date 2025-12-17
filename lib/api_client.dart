// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  const ApiClient();

  String get _baseUrl => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse('$_baseUrl/auth/request-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    final data = _decodeMap(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Request OTP failed');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    final data = _decodeMap(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Verify OTP failed');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String phone,
    required String name,
    required String role, // buyer/provider
  }) async {
    final uri = Uri.parse('$_baseUrl/users/update-profile');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'name': name, 'role': role}),
    );

    final data = _decodeMap(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Update profile failed');
  }

  Map<String, dynamic> _decodeMap(http.Response res) {
    try {
      final body = res.body.trim();
      if (body.isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }

      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'message': 'Invalid server response'};
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}