import 'dart:convert';
import 'package:http/http.dart' as http;

class Config {
  // آپ کی وہی پرانی پراکسی جو پہلے کام کر رہی تھی
  static const String _proxy = "https://corsproxy.io/?"; 
  static const String _baseUrl = "${_proxy}https://paxochat.com"; 
  static const String _apiKey = "PixoChat_Master_Secure_2026";

  // میپنگ لسٹ (auth_screen کے ساتھ)
  static const String _LIST = """
    {auth_screen > /auth}
    {otp_verification > /verify-otp}
    {profile_setup > /register-new-user}
    {security_gateway > /security_getway} 
  """;

  static Future<Map<String, dynamic>> send(String screenName, Map<String, dynamic> data) async {
    try {
      final RegExp regExp = RegExp('\{' + screenName + r'\s*>\s*([^}]+)\}');
      final match = regExp.firstMatch(_LIST);

      if (match != null) {
        String endpoint = match.group(1)!.trim();
        String finalUrl = _baseUrl + endpoint;

        return await _ApiService.directPost(finalUrl, data, _apiKey);
      } else {
        return {"status": "error", "message": "Mapping missing for: $screenName"};
      }
    } catch (e) {
      return {"status": "error", "message": "Gateway Error: $e"};
    }
  }
}

class _ApiService {
  static Future<Map<String, dynamic>> directPost(String url, Map<String, dynamic> data, String key) async {
    try {
      // اہم تبدیلی: سیکیورٹی کی کو براہ راست ڈیٹا باڈی میں شامل کیا گیا ہے
      // تاکہ پراکسی اسے ڈراپ نہ کر سکے
      data['api_key'] = key;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          // یہاں کوئی کسٹم ہیڈر نہیں ہے تاکہ CORS کا مسئلہ نہ آئے
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // یہاں ہم سرور کا اصل جواب دکھائیں گے تاکہ پتہ چلے مسئلہ کیا ہے
        return {
          "status": "error", 
          "message": "Server Error ${response.statusCode}: ${response.body}"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Network Connection Failed: $e"};
    }
  }
}
