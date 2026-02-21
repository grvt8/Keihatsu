import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'theme_provider.dart';
import 'providers/library_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/offline_library_provider.dart';

import 'models/local_models.dart';
import 'services/sources_api.dart';
import 'services/library_api.dart';
import 'services/auth_api.dart';
import 'services/file_service.dart';
import 'services/sync_manager.dart';
import 'services/sources_repository.dart';
import 'services/manga_repository.dart';
import 'services/library_repository.dart';
import 'services/user_repository.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      LocalSourceSchema,
      LocalMangaSchema,
      LocalChapterSchema,
      LocalPageSchema,
      LocalLibraryEntrySchema,
      LocalCategorySchema,
      LocalCategoryAssignmentSchema,
      SyncOperationSchema,
      LocalUserPreferencesSchema,
    ],
    directory: dir.path,
  );

  final fileService = FileService();
  final sourcesApi = SourcesApi();
  final libraryApi = LibraryApi();
  final authApi = AuthApi();

  // We need a way to get the token. 
  // For now, we'll use a placeholder or let the AuthProvider handle it.
  String? getToken() => null; // This will be updated once AuthProvider is ready

  final syncManager = SyncManager(
    isar: isar,
    libraryApi: libraryApi,
    getToken: getToken,
  );

  final sourcesRepo = SourcesRepository(isar: isar, api: sourcesApi, fileService: fileService);
  final mangaRepo = MangaRepository(isar: isar, api: sourcesApi, fileService: fileService, libraryApi: libraryApi);
  final libraryRepo = LibraryRepository(isar: isar, api: libraryApi, syncManager: syncManager);
  final userRepo = UserRepository(isar: isar, api: authApi, fileService: fileService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Repositories
        Provider.value(value: sourcesRepo),
        Provider.value(value: mangaRepo),
        Provider.value(value: libraryRepo),
        Provider.value(value: userRepo),
        // Providers using Repositories
        ChangeNotifierProxyProvider<AuthProvider, OfflineLibraryProvider>(
          create: (context) => OfflineLibraryProvider(
            libraryRepo: libraryRepo,
            mangaRepo: mangaRepo,
            getToken: () => Provider.of<AuthProvider>(context, listen: false).token,
          ),
          update: (context, auth, previous) => previous!..refresh(false),
        ),
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
