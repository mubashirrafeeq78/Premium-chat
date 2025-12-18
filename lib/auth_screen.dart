import 'package:flutter/material.dart';
import 'api_client.dart';
import 'config.dart';
import 'routes.dart';
import 'storage.dart';
import 'widgets.dart';
import 'utils.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phone = TextEditingController();
  final _api = ApiClient(baseUrl: AppConfig.baseUrl);

  bool _loading = false;
  String _error = "";

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final phone = _phone.text.trim();
      if (phone.isEmpty) {
        setState(() => _error = "Please enter mobile number");
        return;
      }

      await AppStorage.savePhone(phone);

      final j = await _api.postJson("/auth/request-otp", body: {"phone": phone});
      // demo otp (backend returns it if ALLOW_DEMO_OTP=1)
      final otp = (j["otp"] ?? "").toString();
      if (otp.isNotEmpty) {
        showSnack(context, "Demo OTP: $otp");
      }

      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.otp);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple UI – آپ اپنا exact ڈیزائن اسی screen میں replace کر سکتے ہیں
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat, size: 56),
                  const SizedBox(height: 10),
                  const Text("Premium Chat", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ErrorBox(message: _error),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: _loading ? "Please wait..." : "Continue",
                    onPressed: _loading ? null : _sendOtp,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}