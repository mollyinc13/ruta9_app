// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants/colors.dart';
// Import for OrderConfirmationScreen (will be created later)
// For now, this import is commented out, navigation will be placeholder.
import 'order_confirmation_screen.dart';
import '../main_app_shell.dart'; // For navigating back to home

// DeliveryOption and PaymentMethod classes remain the same
class DeliveryOption {
  final String id;
  final String title;
  final String subtitle;
  final double price;

  const DeliveryOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
  });
}
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
  final _streetController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  final List<DeliveryOption> _deliveryOptions = const [
    DeliveryOption(id: 'standard', title: 'Envío Standard', subtitle: 'Entrega en 3-5 días hábiles', price: 3500),
    DeliveryOption(id: 'express', title: 'Envío Express', subtitle: 'Entrega en 1-2 días hábiles', price: 7000),
  ];
  DeliveryOption? _selectedDeliveryOption;

  final List<PaymentMethod> _paymentMethods = const [
    PaymentMethod(id: 'cash', title: 'Efectivo al Entregar', icon: Icons.money_outlined),
    PaymentMethod(id: 'card_mock', title: 'Tarjeta de Crédito/Débito (Simulado)', icon: Icons.credit_card_outlined),
  ];
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    if (_deliveryOptions.isNotEmpty) {
      _selectedDeliveryOption = _deliveryOptions.first;
    }
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _paymentMethods.first;
    }
  }
  @override
  void dispose() {
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  // Helper to calculate grand total
  double _calculateGrandTotal(CartProvider cart) {
    double deliveryFee = _selectedDeliveryOption?.price ?? 0.0;
    return cart.totalPrice + deliveryFee;
  }

  void _handleConfirmOrder(CartProvider cart) {
    if (_formKey.currentState!.validate()) { // Basic form validation
      // In a real app: process payment, save order to backend
      print('Order Confirmed!');
      print('Address: ${_streetController.text}, ${_cityController.text}');
      print('Delivery: ${_selectedDeliveryOption?.title}');
      print('Payment: ${_selectedPaymentMethod?.title}');
      print('Grand Total: ${_calculateGrandTotal(cart)}');

      // Clear cart
      // Use context.read<CartProvider>() if you need to call methods on a provider
      // from within a callback where the context might be tricky,
      // or pass the cart provider instance directly as done here.
      cart.clearCart();

      // Show dialog first, then navigate.
      // Capture the context before showDialog if it's inside an async gap
      // For this case, it's synchronous before the navigation so current context is fine.
      // Remove the direct navigation to MainAppShell.
      // The AlertDialog's OK button will handle navigation.

      showDialog(
          context: context, // Use the CheckoutScreen's context
          barrierDismissible: false,
          builder: (BuildContext dialogCtx) {
            return AlertDialog(
              title: const Text('¡Pedido Confirmado!'),
              content: const Text('Gracias por tu compra. Tu pedido está siendo procesado.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop(); // Dismiss dialog
                    // NOW navigate to OrderConfirmationScreen, clearing stack
                    Navigator.of(context).pushAndRemoveUntil( // Use CheckoutScreen's context for navigation
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

              // 2. Delivery Address
              Text('Dirección de Envío', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              _buildTextFormField(controller: _streetController, labelText: 'Calle y Número', hintText: 'Ej: Av. Siempreviva 742'),
              _buildTextFormField(controller: _apartmentController, labelText: 'Departamento, Casa, etc. (Opcional)', hintText: 'Ej: Depto 123, Casa B'),
              _buildTextFormField(controller: _cityController, labelText: 'Ciudad / Comuna', hintText: 'Ej: Springfield'),
              _buildTextFormField(controller: _postalCodeController, labelText: 'Código Postal (Opcional)', hintText: 'Ej: 1234567', keyboardType: TextInputType.number),
              _buildTextFormField(controller: _instructionsController, labelText: 'Instrucciones de Entrega (Opcional)', hintText: 'Ej: Dejar en conserjería, llamar al llegar', maxLines: 3),
              const SizedBox(height: 24.0),

              // 3. Delivery Options Section
              Text('Opciones de Envío', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Card(
                child: Column(
                  children: _deliveryOptions.map((option) {
                    return RadioListTile<DeliveryOption>(
                      title: Text(option.title, style: textTheme.titleMedium),
                      subtitle: Text('${option.subtitle} (+\$${option.price.toStringAsFixed(0)})', style: textTheme.bodyMedium),
                      value: option,
                      groupValue: _selectedDeliveryOption,
                      onChanged: (DeliveryOption? value) {
                        setState(() { _selectedDeliveryOption = value; });
                      },
                      activeColor: colorScheme.primary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24.0),

              // 4. Payment Methods Section
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

              // --- 5. Final Order Review ---
              Text('Revisión Final', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(context, 'Subtotal Productos:', '\$${cart.totalPrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(context, 'Costo de Envío:', '+\$${(_selectedDeliveryOption?.price ?? 0.0).toStringAsFixed(0)}'),
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
              // --- End Final Order Review ---
              const SizedBox(height: 32.0),

              // --- 6. Confirm and Pay Button ---
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
