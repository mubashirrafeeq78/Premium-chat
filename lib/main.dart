// lib/main.dart
import 'package:flutter/material.dart';
import 'mobile_number_screen.dart';

void main() {
  runApp(const QuickChatApp());
}

class QuickChatApp extends StatelessWidget {
  const QuickChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MobileNumberScreen(),
    );
  }
}