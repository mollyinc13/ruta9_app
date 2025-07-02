// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/totem_kiosk_screen.dart'; // Import TotemKioskScreen
import 'firebase_options.dart';
import 'core/app_mode.dart'; // Import AppMode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    AppMode( // Envolver con AppMode
      isTotemMode: isTotemModeFromEnv, // Usar el valor de compilación
      child: ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: const MyApp(),
      ),
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
      home: Builder( // Usar Builder para acceder a AppMode dentro de la construcción de home
        builder: (context) {
          final bool totemMode = AppMode.of(context).isTotemMode;
          if (totemMode) {
            // Si es modo tótem, va directamente a TotemKioskScreen
            // Aquí se podría añadir una pantalla intermedia "Presione para comenzar" si se desea para el tótem.
            // Por ahora, directo a TotemKioskScreen.
            // TotemKioskScreen se encarga de su propia lógica de UI inmersiva.
            return const TotemKioskScreen(); // Asegúrate que TotemKioskScreen esté importado
          } else {
            // Modo cliente: verifica autenticación
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasData) {
                  return const WelcomeScreen(); // Usuario logueado, va a Welcome
                }
                return const LoginScreen(); // No logueado, va a Login
              },
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
