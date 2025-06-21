// lib/views/profile/favorites_screen_placeholder.dart
import 'package:flutter/material.dart';

class FavoritesScreenPlaceholder extends StatelessWidget {
  const FavoritesScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        // leading: IconButton( // Enable if direct back navigation is desired
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: Center(
        child: Text(
          'Contenido de Favoritos (Próximamente)',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
