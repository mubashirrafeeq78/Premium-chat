import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static Uri _u(String path, [Map<String, String>? q]) {
    final base = ApiConfig.baseUrl;
    final uri = Uri.parse('$base$path');
    return q == null ? uri : uri.replace(queryParameters: q);
  }

  static Future<Map<String, dynamic>> requestOtp(String phone) async {
    final r = await http.post(
      _u('/auth/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final r = await http.post(
      _u('/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> saveProfile({
    required String phone,
    required String role, // buyer/provider
    String? name,
    String? avatarBase64,
    String? cnicFrontBase64,
    String? cnicBackBase64,
    String? selfieBase64,
  }) async {
    final r = await http.post(
      _u('/profile/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'role': role,
        'name': name,
        'avatar_base64': avatarBase64,
        'cnic_front_base64': cnicFrontBase64,
        'cnic_back_base64': cnicBackBase64,
        'selfie_base64': selfieBase64,
      }),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getMe(String phone) async {
    final r = await http.get(_u('/me', {'phone': phone}));
    return jsonDecode(r.body);
  }
}