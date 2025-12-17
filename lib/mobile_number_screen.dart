import 'package:flutter/material.dart';
import 'api_client.dart';
import 'otp_verification_screen.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final _api = ApiClient();
  final TextEditingController _phoneController = TextEditingController();

  String? _phoneError;
  bool _loading = false;

  String _normalizePhone(String input) {
    final p = input.trim().replaceAll(RegExp(r'\s+'), '');
    // اگر user 03.. دے تو ہم +92 لگا دیں (simple demo)
    if (p.startsWith('03')) return '+92${p.substring(1)}';
    return p;
  }

  Future<void> _onContinue() async {
    setState(() {
      _phoneError = null;
      final raw = _phoneController.text.trim();
      if (raw.isEmpty) {
        _phoneError = 'Mobile number ضروری ہے';
      } else if (raw.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
        _phoneError = 'درست موبائل نمبر درج کریں';
      }
    });

    if (_phoneError != null) return;

    final phone = _normalizePhone(_phoneController.text);

    setState(() => _loading = true);
    try {
      final res = await _api.requestOtp(phone: phone);
      final demoOtp = (res['demoOtp'] ?? '').toString();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            phone: phone,
            demoOtp: demoOtp.isEmpty ? null : demoOtp,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFC8E6C9),
              Color(0xFFFFF9C4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '📱 Premium Chat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F51B5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اپنا موبائل نمبر درج کریں تاکہ ہم آپ کو OTP بھیج سکیں۔',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF90A4AE),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '03xx xxxxxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _phoneError,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        _loading ? 'Please wait...' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}