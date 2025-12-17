// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient();

  // ✅ صرف یہ لائن بدلیں اگر بعد میں سرور/ڈومین چینج کریں
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://premiumchatbackend-production.up.railway.app',
  );

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse('$baseUrl/auth/request-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    final data = _decodeMap(res);
    _throwIfError(res, data, fallback: 'Request OTP failed');
    return data;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    final data = _decodeMap(res);
    _throwIfError(res, data, fallback: 'Verify OTP failed');
    return data;
  }

  Future<Map<String, dynamic>> saveProfile({
    required String phone,
    required String role, // buyer | provider
    required String name,
    String? about,
    String? city,
  }) async {
    final uri = Uri.parse('$baseUrl/profile/setup');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'role': role,
        'name': name,
        'about': about,
        'city': city,
      }),
    );
    final data = _decodeMap(res);
    _throwIfError(res, data, fallback: 'Save profile failed');
    return data;
  }

  Future<Map<String, dynamic>> fetchHome({required String phone}) async {
    final uri = Uri.parse('$baseUrl/home?phone=${Uri.encodeComponent(phone)}');
    final res = await http.get(uri);
    final data = _decodeMap(res);
    _throwIfError(res, data, fallback: 'Load home failed');
    return data;
  }

  Map<String, dynamic> _decodeMap(http.Response res) {
    try {
      final body = res.body.trim();
      if (body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'message': 'Invalid server response'};
    }
  }

  void _throwIfError(
    http.Response res,
    Map<String, dynamic> data, {
    required String fallback,
  }) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final msg = (data['message'] ?? data['error'] ?? fallback).toString();
    throw ApiException(msg);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}