// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants/colors.dart';
// Import for OrderConfirmationScreen (will be created later)
// For now, this import is commented out, navigation will be placeholder.
import 'order_confirmation_screen.dart';
import '../main_app_shell.dart'; // For navigating back to home

// --- Eliminamos DeliveryOption y variables relacionadas ---

class PaymentMethod {
  final String id;
  final String title;
  final IconData icon;

  const PaymentMethod({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Eliminamos todos los controladores relacionados a dirección ---
  // final _streetController = TextEditingController();
  // final _apartmentController = TextEditingController();
  // final _cityController = TextEditingController();
  // final _postalCodeController = TextEditingController();
  // final _instructionsController = TextEditingController();

  // --- Eliminamos opciones de envío ---
  // final List<DeliveryOption> _deliveryOptions = const [ ... ];
  // DeliveryOption? _selectedDeliveryOption;

  final List<PaymentMethod> _paymentMethods = const [
    PaymentMethod(id: 'cash', title: 'Efectivo al Entregar', icon: Icons.money_outlined),
    PaymentMethod(id: 'card_mock', title: 'Tarjeta de Crédito/Débito (Simulado)', icon: Icons.credit_card_outlined),
  ];
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // if (_deliveryOptions.isNotEmpty) {
    //   _selectedDeliveryOption = _deliveryOptions.first;
    // }
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _paymentMethods.first;
    }
  }
  @override
  void dispose() {
    // Eliminados disposes de controladores de dirección
    // _streetController.dispose();
    // _apartmentController.dispose();
    // _cityController.dispose();
    // _postalCodeController.dispose();
    // _instructionsController.dispose();
    super.dispose();
  }

  // Helper to calculate grand total (quitamos delivery fee)
  double _calculateGrandTotal(CartProvider cart) {
    // double deliveryFee = _selectedDeliveryOption?.price ?? 0.0;
    return cart.totalPrice; // solo total del carrito
  }

  void _handleConfirmOrder(CartProvider cart) {
    if (_formKey.currentState!.validate()) { // Basic form validation
      print('Order Confirmed!');
      // Quitamos datos de dirección y envío de la impresión
      print('Payment: ${_selectedPaymentMethod?.title}');
      print('Grand Total: ${_calculateGrandTotal(cart)}');

      cart.clearCart();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogCtx) {
            return AlertDialog(
              title: const Text('¡Pedido Confirmado!'),
              content: const Text('Gracias por tu compra. Tu pedido está siendo procesado.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa los campos requeridos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double grandTotal = _calculateGrandTotal(cart);

    return Scaffold(
      appBar: AppBar( title: const Text('Confirmar Pedido'), ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Order Summary
              Text('Resumen del Pedido', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total a Pagar (Productos):', style: textTheme.titleMedium),
                      Text( '\$${cart.totalPrice.toStringAsFixed(0)}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Eliminamos sección Dirección de Envío ---

              // --- Eliminamos sección Opciones de Envío ---

              // 2. Payment Methods Section (ahora segunda sección visible)
              Text('Método de Pago', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Card(
                child: Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile<PaymentMethod>(
                      title: Text(method.title, style: textTheme.titleMedium),
                      secondary: Icon(method.icon, color: AppColors.textMuted, size: 28),
                      value: method,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() { _selectedPaymentMethod = value; });
                      },
                      activeColor: colorScheme.primary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24.0),

              // --- 3. Final Order Review (sin costo de envío) ---
              Text('Revisión Final', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(context, 'Subtotal Productos:', '\$${cart.totalPrice.toStringAsFixed(0)}'),
                      // Quitamos costo envío
                      // const SizedBox(height: 8),
                      // _buildSummaryRow(context, 'Costo de Envío:', '+\$0'),
                      // const Divider(height: 20, thickness: 1),
                      const Divider(height: 20, thickness: 1),
                      _buildSummaryRow(
                        context,
                        'Total General:',
                        '\$${grandTotal.toStringAsFixed(0)}',
                        isTotal: true
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),

              // --- 4. Confirm and Pay Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: cart.itemsList.isEmpty ? null : () => _handleConfirmOrder(cart),
                  child: const Text('CONFIRMAR Y PAGAR (SIMULADO)'),
                ),
              ),
              // --- End Confirm and Pay Button ---
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) : textTheme.titleMedium),
        Text(
          value,
          style: isTotal
            ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary)
            : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}
