import 'package:flutter/material.dart';

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
      title: 'Quick Chat',

      // ایپ سب سے پہلے MobileNumberScreen سے شروع ہو گی
      initialRoute: '/mobile',

      routes: {
        '/mobile': (_) => const MobileNumberScreen(),
        '/otp': (_) => const OTPVerificationScreen(),
        '/profile_setup': (_) => const ProfileSetupScreen(),
      },
    );
  }
}
```0
