// lib/views/profile/order_history_screen_placeholder.dart
import 'package:flutter/material.dart';

class OrderHistoryScreenPlaceholder extends StatelessWidget {
  const OrderHistoryScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: Center(
        child: Text(
          'Contenido de Historial de Pedidos (Próximamente)',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
