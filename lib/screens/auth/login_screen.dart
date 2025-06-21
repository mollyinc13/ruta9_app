// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/colors.dart'; // For AppColors if needed for specific styling

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Potentially an AppBar if needed, or keep it minimal
      // appBar: AppBar(
      //   title: const Text('Iniciar Sesión'),
      //   elevation: 0,
      //   backgroundColor: Colors.transparent, // Or from theme
      // ),
      backgroundColor: AppColors.primaryDark, // Match the app's dark theme background
      body: Center(
        child: SingleChildScrollView( // In case content overflows on small screens
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // App Logo
              Image.asset(
                'assets/images/logos/R9.png',
                height: 100, // Adjust size as needed
                // width: 100,
              ),
              const SizedBox(height: 24.0),

              // Welcome Message
              Text(
                'Bienvenido a Ruta9',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 48.0),

              // Sign in with Google Button
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
                label: Text(
                  'Iniciar Sesión con Google',
                  style: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed, // Or a Google-like blue: Color(0xFF4285F4)
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  // Placeholder action for Google Sign-In
                  print('Google Sign-In button pressed (Not Implemented)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad de inicio de sesión con Google (pendiente).'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // In a real app, this would trigger the Google Sign-In flow
                  // and on success, navigate to the main app or profile screen.
                  // For now, maybe pop back if shown as a dialog/modal, or do nothing.
                  // If LoginScreen is a full page, it might navigate on success.
                  // Navigator.of(context).pop(); // Example if presented modally
                },
              ),
              const SizedBox(height: 24.0),

              // Optional: "Or sign in with email" or other methods
              // Text(
              //   'O',
              //   textAlign: TextAlign.center,
              //   style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              // ),
              // const SizedBox(height: 16.0),
              // Placeholder for email/password login if ever needed

              // Optional: Skip login / Continue as guest
              // TextButton(
              //   onPressed: () {
              //     // Navigate to main app as guest or pop
              //     print('Skip login pressed');
              //     Navigator.of(context).pop(); // Example
              //   },
              //   child: Text(
              //     'Continuar como invitado',
              //     style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryRed),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
