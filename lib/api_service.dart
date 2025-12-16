// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final uri = Uri.parse(ApiConfig.requestOtp);
    final res = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': phone}),
    );

    return _handle(res, fallbackMessage: 'Request failed');
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConfig.verifyOtp);
    final res = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    return _handle(res, fallbackMessage: 'Verify failed');
  }

  static Map<String, dynamic> _handle(http.Response res, {required String fallbackMessage}) {
    Map<String, dynamic> data;
    try {
      data = (res.body.trim().isEmpty) ? {} : (jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      data = {'message': 'Invalid server response'};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw Exception((data['message'] ?? data['error'] ?? fallbackMessage).toString());
  }
}