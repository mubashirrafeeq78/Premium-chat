import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'api_service.dart';
// اپنی OTP اسکرین فائل کو یہاں امپورٹ کریں
// import 'otp_verification.dart'; 

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendOtp() async {
    // بنیادی تصدیق
    if (_phoneController.text.length < 10) {
      _showStatusMessage("Please enter a valid phone number", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest(
        AppConfig.auth, 
        {"mobile": _phoneController.text}
      );

      if (response['status'] == 'success') {
        _showStatusMessage("Verification code sent successfully!", isError: false);
        
        // 2 سیکنڈ بعد اگلی اسکرین پر بھیج دیں
        Future.delayed(Duration(seconds: 2), () {
          // Navigator.push(
          //   context, 
          //   MaterialPageRoute(builder: (context) => OtpVerifyScreen(phone: _phoneController.text))
          // );
          print("Navigating to OTP Screen..."); // ابھی کے لیے صرف پرنٹ
        });
      } else {
        // سیکیورٹی کے لیے صرف سادہ ایرر دکھائیں
        _showStatusMessage(response['message'] ?? "Authentication failed. Please try again.", isError: true);
      }
    } catch (e) {
      // ہیکرز کو تکنیکی معلومات دینے کے بجائے عام میسج دکھائیں
      _showStatusMessage("Connection error. Please check your internet.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // خوبصورت اور مختصر میسج دکھانے کا فنکشن
  void _showStatusMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // پرانے میسجز ہٹائیں
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isError ? Color(0xFFFFEBEE) : Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError ? Colors.redAccent : Colors.green,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, 
                   color: isError ? Colors.red : Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // اسکرین کی چوڑائی معلوم کریں تاکہ ریسپونسیو ڈیزائن بن سکے
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 450 : screenWidth * 0.9;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFF1F8E9)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // لوگو یا آئیکن کے لیے جگہ
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF3F51B5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_person_rounded, size: 40, color: Color(0xFF3F51B5)),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Secure Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Global Authentication System",
                    style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                  ),
                  SizedBox(height: 35),
                  
                  // ان پٹ فیلڈ
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15), // عالمی نمبرز کے لیے حد بڑھا دی
                    ],
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      hintText: "Enter with country code",
                      prefixIcon: Icon(Icons.phone_android_rounded, color: Color(0xFF3F51B5)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // بٹن
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "GET OTP",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "By proceeding, you agree to our Terms",
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
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
