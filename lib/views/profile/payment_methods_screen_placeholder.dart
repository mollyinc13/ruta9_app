// lib/views/profile/payment_methods_screen_placeholder.dart
import 'package:flutter/material.dart';

class PaymentMethodsScreenPlaceholder extends StatelessWidget {
  const PaymentMethodsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
      ),
      body: Center(
        child: Text(
          'Contenido de Métodos de Pago (Próximamente)',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
