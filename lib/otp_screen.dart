import 'package:flutter/material.dart';
import 'api_client.dart';
import 'config.dart';
import 'routes.dart';
import 'storage.dart';
import 'widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();
  final _api = ApiClient(baseUrl: AppConfig.baseUrl);

  bool _loading = false;
  String _error = "";

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final phone = await AppStorage.getPhone();
      if (phone == null || phone.isEmpty) {
        setState(() => _error = "Phone missing. Go back.");
        return;
      }
      final otp = _otp.text.trim();
      if (otp.isEmpty) {
        setState(() => _error = "Enter OTP");
        return;
      }

      final j = await _api.postJson("/auth/verify-otp", body: {"phone": phone, "otp": otp});
      final token = (j["token"] ?? "").toString();
      if (token.isEmpty) throw Exception("Token missing in response");

      await AppStorage.saveToken(token);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.lock, size: 56),
                  const SizedBox(height: 10),
                  const Text("OTP Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Enter OTP",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ErrorBox(message: _error),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: _loading ? "Verifying..." : "Verify",
                    onPressed: _loading ? null : _verify,
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