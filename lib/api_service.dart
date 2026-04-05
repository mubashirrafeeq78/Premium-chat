import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    // 1. یو آر ایل کی تصدیق کریں کہ اس میں https:// لازمی ہو
    final url = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': 'PixoChat_Master_Secure_2026', // براہ راست کی دیں یا Config سے لیں
        },
        body: jsonEncode(body),
      );

      // ویب پر 200 کے علاوہ 201 یا 204 بھی کامیاب ہو سکتے ہیں
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'سرور کا جواب: ${response.statusCode}'};
      }
    } catch (e) {
      // اگر یہاں 'Failed to fetch' آ رہا ہے تو یہ سرور کی طرف سے بلاک ہو رہا ہے
      return {'status': 'error', 'message': 'رابطہ منقطع: $e'};
    }
  }
}
