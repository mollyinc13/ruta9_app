// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart'; // Import CartProvider
import 'screens/welcome_screen.dart';
// Import MainAppShell if it's the direct home after providing CartProvider at a higher level
// For example, if WelcomeScreen will navigate to a Provider-wrapped MainAppShell.
// Or, if MainAppShell itself is wrapped, WelcomeScreen navigates to it as before.
// The common pattern is to provide it above the widgets that need to access it.
// Wrapping MaterialApp's home (or MaterialApp itself) is common.

void main() {
  runApp(
    ChangeNotifierProvider( // Provide CartProvider at the root
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruta9 App',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const WelcomeScreen(), // WelcomeScreen will lead to MainAppShell, which can then access CartProvider
      debugShowCheckedModeBanner: false,
    );
  }
}
