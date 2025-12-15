import 'dart:async';
import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  static const List<int> _resendScheduleSeconds = [60, 120, 300, 600];
  int _resendCount = 0;
  int _secondsLeft = _resendScheduleSeconds[0];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown(_secondsLeft);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  bool get _canResend => _secondsLeft == 0;

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _otpComplete =>
      _otp.length == 4 && !_otp.contains(RegExp(r'[^0-9]'));

  void _onDigitChanged(int index, String value) {
    final v = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (v.isEmpty) {
      _controllers[index].clear();
      setState(() {});
      return;
    }

    _controllers[index].text = v.characters.last;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    setState(() {});
  }

  void _onDigitSubmitted(int index) {
    if (_controllers[index].text.isEmpty) return;
    if (index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _verifyOtp() {
    if (!_otpComplete) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }

  void _resendOtp() {
    if (!_canResend) return;

    _resendCount = (_resendCount + 1).clamp(1, 4);
    final nextIndex =
        (_resendCount).clamp(0, _resendScheduleSeconds.length - 1);
    final nextCooldown = _resendScheduleSeconds[nextIndex];

    _startCooldown(nextCooldown);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6FFFA),
              Color(0xFFF7FFE6),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'OTP Verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 4-digit code sent to your mobile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) => _otpBox(i)),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code?",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _canResend ? _resendOtp : null,
                child: Text(
                  _canResend ? 'Resend OTP' : 'Resend in $_secondsLeft s',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _canResend
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _otpComplete ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                disabledBackgroundColor: const Color(0xFFBDBDBD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (v) => _onDigitChanged(index, v),
        onSubmitted: (_) => _onDigitSubmitted(index),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF00C853), width: 2),
          ),
        ),
      ),
    );
  }
}
