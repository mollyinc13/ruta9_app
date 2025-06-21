// lib/views/profile/profile_placeholder_view.dart
import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart'; // Import the LoginScreen
import '../../core/constants/colors.dart'; // For button styling if needed

class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding( // Added padding around the content
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined, // Changed icon to reflect "not logged in"
                size: 80,
                color: textTheme.bodyLarge?.color?.withOpacity(0.4)
              ),
              const SizedBox(height: 20),
              Text(
                'Accede a tu Cuenta', // Changed title
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión o regístrate para ver tu perfil, favoritos y más.', // Changed subtitle
                style: textTheme.titleMedium?.copyWith(
                  color: textTheme.bodyLarge?.color?.withOpacity(0.6)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // Added more space before button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: AppColors.primaryRed, // From theme
                  // foregroundColor: Colors.white, // From theme
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Iniciar Sesión / Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
