// Relevant parts of menuruta9central.dart
import 'package:flutter/material.dart';
import '../widgets/floating_cart_button.dart'; // Import the button

class MenuRuta9CentralScreen extends StatefulWidget {
  const MenuRuta9CentralScreen({super.key});
  @override
  State<MenuRuta9CentralScreen> createState() => _MenuRuta9CentralScreenState();
}

class _MenuRuta9CentralScreenState extends State<MenuRuta9CentralScreen> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta 9 - Local Central'),
      ),
      body: Center( // Body remains the "Coming Soon" message
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront, size: 80, color: textTheme.headlineMedium?.color?.withOpacity(0.7),),
              const SizedBox(height: 24),
              Text('Próximamente Disponible', style: textTheme.headlineMedium, textAlign: TextAlign.center,),
              const SizedBox(height: 12),
              Text('El menú para nuestro Local Central estará disponible aquí muy pronto. ¡Gracias por tu paciencia!',
                style: textTheme.titleMedium?.copyWith(color: textTheme.titleMedium?.color?.withOpacity(0.8),),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingCartButton(
        itemCount: 0, // No cart interaction on this screen yet
        onPressed: () {
          print('Floating Cart Button Tapped on Central Menu!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navegar a la pantalla del carrito (pendiente).')),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Example location
    );
  }
}
