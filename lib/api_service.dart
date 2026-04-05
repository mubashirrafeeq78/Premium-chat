import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // آپ کی ڈومین کا بنیادی یو آر ایل
  static const String baseUrl = "https://paxochat.com";
  
  // ماسٹر سیکیورٹی کی
  static const String apiKey = "PixoChat_Master_Secure_2026";

  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    // مکمل یو آر ایل بنانا
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-api-key": apiKey,
          // ویب براؤزر کے لیے اضافی ہیڈر
          "Access-Control-Allow-Origin": "*",
        },
        body: jsonEncode(body),
      );

      // اگر سرور 200 (OK) جواب دے
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } 
      // اگر سرور کوئی اور ایرر کوڈ بھیجے
      else {
        return {
          'status': 'error', 
          'message': 'سرور ایرر کوڈ: ${response.statusCode}'
        };
      }
    } catch (e) {
      // اگر نیٹ ورک یا CORS کی وجہ سے ریکویسٹ فیل ہو جائے
      return {
        'status': 'error', 
        'message': 'کنکشن بلاک ہو رہا ہے: $e'
      };
    }
  }
}
