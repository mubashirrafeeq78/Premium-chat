import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  const ApiClient();

  String get baseUrl => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse('$baseUrl/auth/request-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Request OTP failed');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Verify OTP failed');
  }

  Future<Map<String, dynamic>> upsertProfile({
    required String phone,
    required String role, // buyer | provider
    required String name,
    String? avatarUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/users/profile');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'role': role,
        'name': name,
        'avatarUrl': avatarUrl,
      }),
    );
    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Profile save failed');
  }

  Future<Map<String, dynamic>> getUserByPhone({required String phone}) async {
    final uri = Uri.parse('$baseUrl/users/by-phone?phone=${Uri.encodeComponent(phone)}');
    final res = await http.get(uri);
    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Load user failed');
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = res.body.trim();
      if (body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(body);
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