import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String _error = "";

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      setState(() => _error = "Please enter a valid 11-digit number");
      return;
    }

    setState(() {
      _loading = true;
      _error = "";
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    // یہاں ابھی ہم نے صرف پرنٹ کروایا ہے تاکہ ایرر نہ آئے
    print("Go to OTP Screen"); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Welcome!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                decoration: const InputDecoration(hintText: "03XXXXXXXXX", border: OutlineInputBorder()),
              ),
              if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading ? const CircularProgressIndicator() : const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
