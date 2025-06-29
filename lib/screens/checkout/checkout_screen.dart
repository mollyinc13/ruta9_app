// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For pre-filling user name
import '../../providers/cart_provider.dart';
import '../../core/constants/colors.dart';
import 'order_confirmation_screen.dart';
// import '../main_app_shell.dart'; // Not needed if navigating to OrderConfirmationScreen then that handles next step
import '../../services/onepay_service.dart'; // Import OnePayService

// Removed DeliveryOption class as it's no longer used

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
  // Controllers for user info (relevant for pickup)
  final _nameController = TextEditingController(); // Added for customer name
  final _phoneController = TextEditingController(); // Added for customer phone (optional)
  // Removed delivery-specific controllers:
  // final _streetController = TextEditingController();
  // final _apartmentController = TextEditingController();
  // final _cityController = TextEditingController();
  // final _postalCodeController = TextEditingController();
  // final _instructionsController = TextEditingController();

  // Removed delivery options

  final OnePayService _onePayService = OnePayService(); // Instance of OnePayService
  bool _isProcessingPayment = false; // State for loading indicator during payment

  // Updated payment methods to include Onepay
  final List<PaymentMethod> _paymentMethods = const [
    PaymentMethod(id: 'onepay_transbank', title: 'Onepay (Transbank)', icon: Icons.payment), // Placeholder icon, replace with Onepay logo if available
    PaymentMethod(id: 'cash_pickup', title: 'Efectivo en Local', icon: Icons.money_outlined),
    PaymentMethod(id: 'card_pickup', title: 'Tarjeta en Local (Simulado)', icon: Icons.credit_card_outlined),
  ];
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Pre-fill name if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? '';
      // Podríamos también intentar pre-rellenar el teléfono si lo tuviéramos en el perfil de Firebase
      // o si lo guardamos en Firestore y lo recuperamos aquí.
      // Por ahora, solo el nombre.
    }

    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _paymentMethods.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    // Removed disposal of delivery-specific controllers

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // Updated to reflect no delivery fee
  double _calculateGrandTotal(CartProvider cart) {
    return cart.totalPrice; // Only product total
  }

  Future<void> _handleConfirmOrder(CartProvider cart) async { // Made async
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa los campos requeridos.')),
      );
      return;
    }

    if (_selectedPaymentMethod?.id == 'onepay_transbank') {
      setState(() { _isProcessingPayment = true; });

      // **IMPORTANTE:** En una app real, aquí llamarías a tu backend para crear
      // la transacción Onepay y obtener 'ott' y 'externalUniqueNumber'.
      // Por ahora, usaremos valores dummy para simulación.
      const String dummyOtt = "dummy_ott_12345";
      final String dummyExternalUniqueNumber = "ruta9_kiosk_${DateTime.now().millisecondsSinceEpoch}";

      try {
        final paymentResult = await _onePayService.startAndroidPayment(
          ott: dummyOtt,
          externalUniqueNumber: dummyExternalUniqueNumber,
        );

        setState(() { _isProcessingPayment = false; });

        if (paymentResult['status'] == 'SUCCESS') {
          // TODO: Aquí deberías verificar el resultado con tu backend usando el externalUniqueNumber
          // y el transactionId de Onepay (si el SDK lo devuelve o tu backend lo tiene).
          // Por ahora, asumimos éxito si el SDK/platform channel dice SUCCESS.

          _finalizeOrder(cart, paymentResult);

        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pago Onepay fallido o cancelado: ${paymentResult['message'] ?? 'Error desconocido'}')),
          );
        }
      } catch (e) {
        setState(() { _isProcessingPayment = false; });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error procesando pago Onepay: ${e.toString()}')),
        );
      }
    } else {
      // Lógica para otros métodos de pago (Efectivo, Tarjeta simulada)
      _finalizeOrder(cart, {'paymentMethod': _selectedPaymentMethod?.title});
    }
  }

  void _finalizeOrder(CartProvider cart, Map<String, dynamic> paymentDetails) {
    // Esta función ahora es llamada tanto por Onepay exitoso como por otros métodos.
    debugPrint('Order Confirmed for Pickup!');
    debugPrint('Customer Name: ${_nameController.text}');
    debugPrint('Customer Phone: ${_phoneController.text}');
    debugPrint('Payment Details: $paymentDetails');
    debugPrint('Grand Total: ${_calculateGrandTotal(cart)}');

    // TODO: Save order to Firestore with pickup details and paymentDetails

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

                // 2. Customer Information for Pickup
                Text('Información para Retiro', style: titleLargeKiosk),
                const SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Nombre de quien retira',
                  hintText: 'Ej: Juan Pérez',
                  textStyle: bodyMediumKiosk,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un nombre';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _phoneController,
                  labelText: 'Teléfono de contacto (Opcional)',
                  hintText: 'Ej: 912345678',
                  keyboardType: TextInputType.phone,
                  textStyle: bodyMediumKiosk
                ),
                const SizedBox(height: 28.0),

                // Delivery Options Section - REMOVED
                // Text('Opciones de Envío', style: titleLargeKiosk),
                // ... Card with delivery options ...
                // const SizedBox(height: 28.0),

                // 4. Payment Methods Section (Adjusted title if needed)
                Text('Método de Pago en Local', style: titleLargeKiosk),
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
                        // const SizedBox(height: 10), // Spacing for delivery cost, removed
                        // _buildSummaryRow(context, 'Costo de Envío:', '+\$${(_selectedDeliveryOption?.price ?? 0.0).toStringAsFixed(0)}', textStyle: titleMediumKiosk), // Delivery cost removed
                        const Divider(height: 24, thickness: 1),
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
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: (textTheme.labelLarge?.fontSize ?? 14) + kioskExtraFontSize + 4, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (cart.itemsList.isEmpty || _isProcessingPayment) ? null : () => _handleConfirmOrder(cart),
                    child: _isProcessingPayment
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.0))
                        : const Text('CONFIRMAR Y PAGAR'), // Texto ajustado
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
