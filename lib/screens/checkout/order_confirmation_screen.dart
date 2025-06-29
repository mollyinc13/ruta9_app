// lib/screens/checkout/order_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../main_app_shell.dart'; // To navigate back to home
import '../../core/constants/colors.dart'; // For AppColors if needed

class OrderConfirmationScreen extends StatelessWidget {
  // Optional: Could accept an order ID or details to display
  // final String orderId;
  // const OrderConfirmationScreen({super.key, required this.orderId});

  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // No AppBar, to make it feel like a final confirmation/modal-like page over everything
      backgroundColor: AppColors.primaryDark, // Or use theme.scaffoldBackgroundColor
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success, // Or colorScheme.primary
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Tu pedido fue recibido!', // Updated Title
                style: textTheme.headlineMedium?.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Te esperamos en el local para retirarlo.', // Updated Subtitle
                style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Opcional: Añadir botón "Ver mis pedidos" si esa pantalla existiera.
              // Por ahora, solo "Volver al Inicio".
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainAppShell()),
                    (Route<dynamic> route) => false, // Clear all routes before it
                  );
                },
                child: Text('VOLVER AL INICIO', style: textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
