import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'api_service.dart';
import 'config.dart';
// یہاں اپنی گیٹ وے فائل امپورٹ کریں
// import 'getaway.dart'; 

class OTPVerificationScreen extends StatefulWidget {
  final String mobile;
  OTPVerificationScreen({required this.mobile});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // 6 ہندسوں کے لیے کنٹرولرز اور فوکس نوڈس
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  int _timeLeft = 120; // 2 منٹ (120 سیکنڈ)
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 120);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // خوبصورت اسٹیٹس میسج (3 سیکنڈ کے لیے)
  void _showStatus(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isError ? Color(0xFFFFEBEE) : Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isError ? Colors.redAccent : Colors.green, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, 
                   color: isError ? Colors.red : Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: isError ? Colors.red[900] : Colors.green[900], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      _showStatus("Please enter the complete 6-digit code", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest(AppConfig.verifyOtp, {
        'mobile': widget.mobile,
        'otp': otp,
      });

      if (response['status'] == 'success') {
        _showStatus("Account verified successfully!", isError: false);
        
        // 2 سیکنڈ بعد Gateway اسکرین پر منتقلی
        Future.delayed(Duration(seconds: 2), () {
          // Navigator.pushAndRemoveUntil(
          //   context, 
          //   MaterialPageRoute(builder: (context) => GetawayScreen()),
          //   (route) => false
          // );
          print("Navigating to Gateway Screen..."); 
        });
      } else {
        _showStatus(response['message'] ?? "Invalid code. Please try again.", isError: true);
      }
    } catch (e) {
      _showStatus("Connection error. Verification failed.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 450 : screenWidth * 0.9;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFF1F8E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 50, color: Color(0xFF3F51B5)),
                  SizedBox(height: 24),
                  Text("Verification", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  SizedBox(height: 12),
                  Text("Enter the 6-digit code sent to\n${widget.mobile}", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[400], fontSize: 14)),
                  SizedBox(height: 35),
                  
                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => SizedBox(
                      width: (containerWidth - 100) / 6,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey[50],
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF00C853), width: 2)),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
                          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                          if (index == 5 && value.length == 1) _verifyOTP(); // آخری ہندسہ پر خودکار تصدیق
                        },
                      ),
                    )),
                  ),
                  
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                        ? SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("VERIFY ACCOUNT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Timer & Resend Logic
                  _timeLeft > 0 
                    ? Text("Resend code in ${_timeLeft}s", style: TextStyle(color: Colors.blueGrey[300], fontWeight: FontWeight.w500))
                    : TextButton(
                        onPressed: () {
                          Navigator.pop(context); // واپس جا کر دوبارہ نمبر بھیجیں
                        },
                        child: Text("Didn't receive? Resend Code", style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
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
