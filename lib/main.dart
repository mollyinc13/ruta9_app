import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Added import
import 'package:ruta9_app/screens/welcome_screen.dart'; // Asegúrate que esta ruta esté bien

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruta9 App',
      theme: AppTheme.darkTheme, // Use the new dark theme
      darkTheme: AppTheme.darkTheme, // Optionally, if you want to support system theme changes
      themeMode: ThemeMode.dark, // Force dark theme for now
      home: const WelcomeScreen(), // <<<<< Cambia esto
      debugShowCheckedModeBanner: false,
    );
  }
}
