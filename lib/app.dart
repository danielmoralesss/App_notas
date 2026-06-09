import 'package:flutter/material.dart';

import 'screens/notes_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniNotas Carpetas',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azulUnison,
          primary: AppColors.azulUnison,
          secondary: AppColors.doradoUnison,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.azulOscuroUnison,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.doradoUnison,
          foregroundColor: AppColors.ink,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/notes': (_) => const NotesScreen(),
      },
    );
  }
}
