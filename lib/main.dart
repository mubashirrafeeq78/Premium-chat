import 'package:flutter/material.dart';

// یہ لوکل فائلوں کو سیدھا امپورٹ کر رہے ہیں
import 'mobile_number_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Chat',

      // ایپ شروع ہوتے ہی موبائل نمبر والی سکرین کھلے گی
      initialRoute: '/mobile',

      routes: {
        // یہاں سے const ہٹا دیئے ہیں
        '/mobile': (context) => MobileNumberScreen(),
        '/otp': (context) => OTPVerificationScreen(),
        '/profile_setup': (context) => ProfileSetupScreen(),
      },
    );
  }
}
