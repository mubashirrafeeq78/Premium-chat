import 'package:flutter/material.dart';

// Local screens
import 'mobile_number_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart'; // ✅ new home screen

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

      // Starting screen
      initialRoute: '/mobile',

      routes: {
        '/mobile': (context) => MobileNumberScreen(),
        '/otp': (context) => OTPVerificationScreen(),
        '/profile_setup': (context) => ProfileSetupScreen(),

        // Home route after profile setup
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
