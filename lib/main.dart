import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/Onboarding.dart';
import 'screens/HomePage.dart';
import 'screens/RegisterScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/OnboardingFlow.dart';
import 'screens/LibraryScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keihatsu',
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          primary: const Color(0xFFF97316),
        ),
        // Using the dynamic method to set Comic Relief as the default global font
        textTheme: GoogleFonts.getTextTheme(
          'Delius',
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const Onboarding(),
        '/onboardingFlow': (context) => const OnboardingFlow(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/library': (context) => const LibraryScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
