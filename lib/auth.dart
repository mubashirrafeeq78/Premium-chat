import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';
import 'otp_verification.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // مخصوص ریڈ ایرر پاپ اپ کا فنکشن
  void _showError(String message) {
    setState(() { _errorMessage = message; });
    Timer(Duration(seconds: 3), () {
      if (mounted) setState(() { _errorMessage = null; });
    });
  }

  void _sendOTP() async {
    if (_phoneController.text.length < 10) {
      _showError("براہ کرم درست موبائل نمبر درج کریں۔");
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.postRequest('auth', {
      'mobile': _phoneController.text,
    });

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(mobile: _phoneController.text),
        ),
      );
    } else {
      _showError(response['message'] ?? "سرور سے رابطہ نہیں ہو سکا۔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3FDF5), Color(0xFFFFE6FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, 20))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Welcome Back", style: TextStyle(color: Color(0xFF4A55A2), fontSize: 28, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text("Enter your mobile number to continue", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 35),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "03xxxxxxxxx",
                        filled: true,
                        fillColor: Color(0xFFF9F9F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Send OTP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            
            // مخصوص ریڈ ایرر پاپ اپ
            if (_errorMessage != null)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
