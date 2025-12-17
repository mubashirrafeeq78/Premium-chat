// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Local testing (Termux) کیلئے:
  // Browser/Emulator پر: http://127.0.0.1:3000
  // Note: Flutter Web پر "localhost" آپ کے PC والا ہوتا ہے، موبائل والا نہیں۔
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse('$baseUrl/auth/request-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Request failed');
    }
    return data;
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Verify failed');
    }
    return data;
  }
}
