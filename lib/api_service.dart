import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ApiService {
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    // 1. مکمل یو آر ایل بنانا
    final String fullUrl = "${AppConfig.baseUrl}$endpoint";
    
    // ڈیبگنگ کے لیے: یہ لائن بتائے گی کہ کال کہاں جا رہی ہے
    print("🚀 Sending Request to: $fullUrl");
    print("📦 Data: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": AppConfig.apiKey,
        },
        body: jsonEncode(body),
      );

      // سرور سے جو بھی جواب آئے گا، اسے کنسول میں پرنٹ کریں تاکہ سچائی سامنے آئے
      print("📡 Server Response Code: ${response.statusCode}");
      print("📝 Server Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("❌ Connection Error: $e");
      return {"status": "error", "message": "کنکشن کا مسئلہ: $e"};
    }
  }
}
