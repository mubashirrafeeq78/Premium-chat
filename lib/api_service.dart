import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ApiService {
  // مشترکہ پوسٹ ریکویسٹ فنکشن
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("${AppConfig.baseUrl}$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": AppConfig.apiKey, // آپ کی سیکیورٹی کی یہاں سے جائے گی
        },
        body: jsonEncode(body),
      );

      // سرور سے آنے والے جواب کو ڈی کوڈ کرنا
      return jsonDecode(response.body);
    } catch (e) {
      // اگر انٹرنیٹ یا سرور کا مسئلہ ہو
      return {
        "status": "error",
        "message": "کنکشن کا مسئلہ: ${e.toString()}"
      };
    }
  }
}
