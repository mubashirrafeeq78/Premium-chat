import 'package:flutter/material.dart';
import 'mobile_number_screen.dart';

void main() {
  runApp(const PremiumChatApp());
}

class PremiumChatApp extends StatelessWidget {
  const PremiumChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Chat',
      debugShowCheckedModeBanner: false,
      home: const MobileNumberScreen(), // ✅ first screen
    );
  }
}