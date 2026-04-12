import 'dart:convert';
import 'package:http/http.dart' as http;

class Config {
  // اگر لائیو سرور پر CORS کا مسئلہ ہو تو پراکسی استعمال کریں، ورنہ براہ راست یو آر ایل کافی ہے
  static const String _baseUrl = "https://paxochat.com"; 

  // صرف ضروری فائلز کی لسٹ
  static const String _LIST = """
    {save_msg > /save_Message}
    {load_msg > /load_message}
    {delete_msg > /delete_massege}
  """;

  static Future<Map<String, dynamic>> send(String screenName, Map<String, dynamic> data) async {
    try {
      final RegExp regExp = RegExp('\{' + screenName + r'\s*>\s*([^}]+)\}');
      final match = regExp.firstMatch(_LIST);

      if (match != null) {
        String endpoint = match.group(1)!.trim();
        String finalUrl = _baseUrl + endpoint;
        return await _ApiService.directPost(finalUrl, data);
      } else {
        return {"status": "error", "message": "Mapping missing for: $screenName"};
      }
    } catch (e) {
      return {"status": "error", "message": "Gateway Error: $e"};
    }
  }
}

class _ApiService {
  static Future<Map<String, dynamic>> directPost(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          // سیکیورٹی کیز ہٹا دی گئی ہیں تاکہ کنکشن فوری اور سادہ ہو
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error", 
          "message": "Server Error ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection Failed: $e"};
    }
  }
}
