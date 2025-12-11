import 'package:flutter/material.dart';

// Local screens
import 'mobile_number_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';

// Temporary Home Screen (You will replace this later)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome to Premium Chat!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

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

      // Starting Screen
      initialRoute: '/mobile',

      routes: {
        '/mobile': (context) => MobileNumberScreen(),
        '/otp': (context) => OTPVerificationScreen(),
        '/profile_setup': (context) => ProfileSetupScreen(),

        // Home route for redirect after profile setup
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
