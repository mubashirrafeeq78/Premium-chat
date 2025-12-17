import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  const ApiClient();

  // 🔹 API base URL ایک ہی جگہ سے آ رہا ہے
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse('$baseUrl/auth/request-otp');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    return _handleResponse(res);
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

    return _handleResponse(res);
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      final body = res.body.trim();
      final data =
          body.isEmpty ? {} : jsonDecode(body) as Map<String, dynamic>;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return data;
      }

      throw ApiException(data['message'] ?? 'Server error');
    } catch (e) {
      throw ApiException('Invalid server response');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
