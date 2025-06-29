// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart'; // Import LoginScreen
import 'firebase_options.dart'; // Import generated firebase_options.dart

void main() async { // main_app_shell ahora es async
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para Firebase.initializeApp()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Usa firebase_options.dart
  );
  runApp(
    ChangeNotifierProvider(
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
      home: StreamBuilder<User?>( // Escucha cambios en el estado de autenticación
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un loader mientras se verifica el estado de auth
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // Usuario está logueado, va a WelcomeScreen (que luego lleva a MainAppShell)
            return const WelcomeScreen();
          }
          // Usuario no está logueado, va a LoginScreen
          return const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
