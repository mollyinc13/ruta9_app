// lib/views/profile/profile_placeholder_view.dart
import 'package:flutter/material.dart';

class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adding an AppBar to placeholders for a more complete look within the shell
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false, // No back button if it's a main tab view
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4)
            ),
            const SizedBox(height: 20),
            Text(
              'Contenido del Perfil',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '(Próximamente disponible)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
