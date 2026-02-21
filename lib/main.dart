import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'providers/library_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/Onboarding.dart';
import 'screens/HomePage.dart';
import 'screens/RegisterScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/OnboardingFlow.dart';
import 'screens/LibraryScreen.dart';
import 'screens/HistoryScreen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/AppearancePage.dart';
import 'screens/ExtensionsScreen.dart';
import 'screens/SettingsScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keihatsu',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: themeProvider.brandColor,
        scaffoldBackgroundColor: themeProvider.bgColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.brandColor,
          primary: themeProvider.brandColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.getTextTheme('Delius'),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: themeProvider.brandColor,
        scaffoldBackgroundColor: themeProvider.pureBlackDarkMode ? Colors.black : null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.brandColor,
          primary: themeProvider.brandColor,
          brightness: Brightness.dark,
          surface: themeProvider.pureBlackDarkMode ? Colors.black : null,
        ),
        textTheme: GoogleFonts.getTextTheme('Delius').apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      initialRoute: authProvider.isAuthenticated ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (context) => const Onboarding(),
        '/onboardingFlow': (context) => const OnboardingFlow(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/library': (context) => const LibraryScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/appearance': (context) => const AppearancePage(),
        '/home': (context) => const HomePage(),
        '/extensions': (context) => const ExtensionsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
