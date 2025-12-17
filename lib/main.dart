import 'package:flutter/material.dart';
import 'mobile_number_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const MobileNumberScreen(),

        '/otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            final phone = (args['phone'] ?? '').toString();
            final demoOtp = (args['demoOtp'] ?? '').toString();
            if (phone.isNotEmpty) {
              return OTPVerificationScreen(
                phone: phone,
                demoOtp: demoOtp.isEmpty ? null : demoOtp,
              );
            }
          }
          return const MobileNumberScreen();
        },

        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            final phone = (args['phone'] ?? '').toString();
            if (phone.isNotEmpty) return ProfileSetupScreen(phone: phone);
          }
          return const MobileNumberScreen();
        },

        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            final phone = (args['phone'] ?? '').toString();
            if (phone.isNotEmpty) return HomeScreen(phone: phone);
          }
          return const MobileNumberScreen();
        },
      },
    );
  }
}