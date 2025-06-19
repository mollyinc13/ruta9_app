// lib/views/cart/cart_placeholder_view.dart
import 'package:flutter/material.dart';

class CartPlaceholderView extends StatelessWidget {
  const CartPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        automaticallyImplyLeading: false, // No back button if it's a main tab view
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_checkout,
              size: 80,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4)
            ),
            const SizedBox(height: 20),
            Text(
              'Contenido del Carrito',
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
