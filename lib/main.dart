import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/Onboarding.dart';
import 'screens/HomePage.dart';

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
        primaryColor: const Color(0xFF0db14c),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0db14c),
          primary: const Color(0xFF0db14c),
        ),
        // Using the dynamic method to set Comic Relief as the default global font
        textTheme: GoogleFonts.getTextTheme(
          'Comic Relief',
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const Onboarding(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
