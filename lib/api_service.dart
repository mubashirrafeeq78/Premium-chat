import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ApiService {
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    // یو آر ایل بنانا
    final url = Uri.parse("${AppConfig.baseUrl}$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": AppConfig.apiKey,
          // ویب کے لیے یہ ہیڈرز ضروری ہو سکتے ہیں
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      // جواب کو چیک کریں
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "سرور کا جواب: ${response.statusCode}\n${response.body}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "کنکشن کا مسئلہ: $e"
      };
    }
  }
}
