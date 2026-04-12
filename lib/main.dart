import 'package:flutter/material.dart';
import 'chat_group.dart'; // اس فائل میں آپ کا چیٹ اور لاک اسکرین کا کوڈ ہے

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسائل شرعیہ',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // واٹس ایپ جیسا پروفیشنل رنگ (Primary Green)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075E54)),
        useMaterial3: true,
        fontFamily: 'NotoNaskhArabic', // اگر آپ نے اردو فانٹ ایڈ کیا ہے
      ),
      // اب ایپ کھلتے ہی سیدھا پن لاک اسکرین (ChatGroupPage) دکھائے گی
      home: ChatGroupPage(), 
    );
  }
}
