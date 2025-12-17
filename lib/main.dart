import 'package:flutter/material.dart';
import 'mobile_number_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const MobileNumberScreen(),

        // OTP screen کو direct route سے نہ کھولیں کیونکہ phone required ہے
        // اگر پھر بھی کھولنا ہو تو arguments کے ساتھ Navigator.pushNamed استعمال کریں
        '/otp': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final phone = (args?['phone'] ?? '').toString();
          final demoOtp = (args?['demoOtp'] as String?);

          return OTPVerificationScreen(
            phone: phone,
            demoOtp: demoOtp,
          );
        },

        '/profile': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
