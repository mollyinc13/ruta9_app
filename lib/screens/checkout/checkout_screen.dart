// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Kiosk mode UI

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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restore system UI
    // Consider if restoring orientations is always desired, similar to CartScreen
    // SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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

    // Kiosk mode visual adjustments
    const double kioskExtraFontSize = 4.0;
    final TextStyle? titleLargeKiosk = textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: (textTheme.titleLarge?.fontSize ?? 20) + kioskExtraFontSize);
    final TextStyle? titleMediumKiosk = textTheme.titleMedium?.copyWith(fontSize: (textTheme.titleMedium?.fontSize ?? 16) + kioskExtraFontSize - 2);
    final TextStyle? bodyMediumKiosk = textTheme.bodyMedium?.copyWith(fontSize: (textTheme.bodyMedium?.fontSize ?? 14) + kioskExtraFontSize - 2);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button exit in kiosk mode
      child: Scaffold(
        appBar: AppBar(
          title: Text('Confirmar Pedido', style: textTheme.headlineSmall?.copyWith(fontSize: (textTheme.headlineSmall?.fontSize ?? 24) + kioskExtraFontSize)),
          automaticallyImplyLeading: false, // No back button in AppBar for kiosk mode
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0), // Increased padding
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Order Summary
                Text('Resumen del Pedido', style: titleLargeKiosk),
                const SizedBox(height: 12), // Increased spacing
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Increased padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total a Pagar (Productos):', style: titleMediumKiosk),
                        Text( '\$${cart.totalPrice.toStringAsFixed(0)}', style: titleMediumKiosk?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28.0), // Increased spacing

                // 2. Delivery Address
                Text('Dirección de Envío', style: titleLargeKiosk),
                const SizedBox(height: 16.0), // Increased spacing
                _buildTextFormField(controller: _streetController, labelText: 'Calle y Número', hintText: 'Ej: Av. Siempreviva 742', textStyle: bodyMediumKiosk),
                _buildTextFormField(controller: _apartmentController, labelText: 'Departamento, Casa, etc. (Opcional)', hintText: 'Ej: Depto 123, Casa B', textStyle: bodyMediumKiosk),
                _buildTextFormField(controller: _cityController, labelText: 'Ciudad / Comuna', hintText: 'Ej: Springfield', textStyle: bodyMediumKiosk),
                _buildTextFormField(controller: _postalCodeController, labelText: 'Código Postal (Opcional)', hintText: 'Ej: 1234567', keyboardType: TextInputType.number, textStyle: bodyMediumKiosk),
                _buildTextFormField(controller: _instructionsController, labelText: 'Instrucciones de Entrega (Opcional)', hintText: 'Ej: Dejar en conserjería, llamar al llegar', maxLines: 3, textStyle: bodyMediumKiosk),
                const SizedBox(height: 28.0),

                // 3. Delivery Options Section
                Text('Opciones de Envío', style: titleLargeKiosk),
                const SizedBox(height: 12.0),
                Card(
                  elevation: 2,
                  child: Column(
                    children: _deliveryOptions.map((option) {
                      return RadioListTile<DeliveryOption>(
                        title: Text(option.title, style: titleMediumKiosk),
                        subtitle: Text('${option.subtitle} (+\$${option.price.toStringAsFixed(0)})', style: bodyMediumKiosk),
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
                const SizedBox(height: 28.0),

                // 4. Payment Methods Section
                Text('Método de Pago', style: titleLargeKiosk),
                const SizedBox(height: 12.0),
                Card(
                  elevation: 2,
                  child: Column(
                    children: _paymentMethods.map((method) {
                      return RadioListTile<PaymentMethod>(
                        title: Text(method.title, style: titleMediumKiosk),
                        secondary: Icon(method.icon, color: AppColors.textMuted, size: 32), // Increased icon size
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
                const SizedBox(height: 28.0),

                // --- 5. Final Order Review ---
                Text('Revisión Final', style: titleLargeKiosk),
                const SizedBox(height: 12.0),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Increased padding
                    child: Column(
                      children: [
                        _buildSummaryRow(context, 'Subtotal Productos:', '\$${cart.totalPrice.toStringAsFixed(0)}', textStyle: titleMediumKiosk),
                        const SizedBox(height: 10),
                        _buildSummaryRow(context, 'Costo de Envío:', '+\$${(_selectedDeliveryOption?.price ?? 0.0).toStringAsFixed(0)}', textStyle: titleMediumKiosk),
                        const Divider(height: 24, thickness: 1), // Increased spacing
                        _buildSummaryRow(
                          context,
                          'Total General:',
                          '\$${grandTotal.toStringAsFixed(0)}',
                          isTotal: true,
                          textStyle: titleLargeKiosk?.copyWith(color: colorScheme.secondary)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36.0), // Increased spacing

                // --- 6. Confirm and Pay Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20.0), // Increased padding for taller button
                       textStyle: textTheme.labelLarge?.copyWith(fontSize: (textTheme.labelLarge?.fontSize ?? 14) + kioskExtraFontSize + 4, fontWeight: FontWeight.bold), // Increased font size
                    ),
                    onPressed: cart.itemsList.isEmpty ? null : () => _handleConfirmOrder(cart),
                    child: const Text('CONFIRMAR Y PAGAR (SIMULADO)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false, TextStyle? textStyle}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final defaultStyle = isTotal ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) : textTheme.titleMedium;
    final valueStyle = isTotal
            ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary)
            : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle ?? defaultStyle),
        Text(value, style: textStyle ?? valueStyle),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    TextStyle? textStyle, // Added textStyle for kiosk
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased padding
      child: TextFormField(
        controller: controller,
        style: textStyle, // Apply kiosk text style
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: textStyle, // Apply to label
          hintText: hintText,
          hintStyle: textStyle?.copyWith(color: AppColors.textMuted), // Apply to hint
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))), // Ensure consistent border
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Adjust padding
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
