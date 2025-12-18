import 'package:flutter/material.dart';

import 'routes.dart';
import 'auth_screen.dart';
import 'otp_screen.dart';
import 'profile_setup_screen.dart';
import 'home_buyer_screen.dart';
import 'home_provider_screen.dart';

class PremiumChatApp extends StatelessWidget {
  const PremiumChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Premium Chat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00C853),
      ),

      // 🔹 App start point
      initialRoute: AppRoutes.auth,

      // 🔹 All routes defined in ONE place
      routes: {
        // Auth flow
        AppRoutes.auth: (_) => const AuthScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.profile: (_) => const ProfileSetupScreen(),

        // Buyer & Provider homes
        AppRoutes.homeBuyer: (_) => const BuyerHomeScreen(),
        AppRoutes.homeProvider: (_) => const ProviderHomeScreen(),
      },
    );
  }
}
