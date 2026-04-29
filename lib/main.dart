import 'package:flutter/material.dart';
import 'auth_screen.dart'; // یہاں ہم آپ کی نئی فائل کو امپورٹ کر رہے ہیں

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PremiumChatApp());
}

class PremiumChatApp extends StatelessWidget {
  const PremiumChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // ایپ کھلتے ہی سب سے پہلے AuthScreen نظر آئے گی
      home: const AuthScreen(), 
    );
  }
}
