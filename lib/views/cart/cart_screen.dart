// lib/views/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
// import '../../models/cart_item_model.dart'; // Not directly instantiated, can be removed if not used for type checks
import '../../core/constants/colors.dart';
import '../../screens/checkout/checkout_screen.dart'; // Import CheckoutScreen

class CartScreen extends StatefulWidget { // Converted to StatefulWidget
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> { // State class
  @override
  void initState() {
    super.initState();
    // Opcional: Solo aplicar modo inmersivo si se detecta contexto de kiosco.
    // Por ahora, se aplica siempre que esta pantalla esté activa.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restaurar UI del sistema
    // Considerar si restaurar orientaciones aquí es siempre deseable
    // o solo si se entró desde un contexto que las cambió.
    // SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Kiosk mode visual adjustments
    const double kioskExtraFontSize = 4.0; // Increase font sizes for kiosk
    final double kioskIconSize = (IconTheme.of(context).size ?? 24.0) + 4.0;


    // ignore: deprecated_member_use
    return WillPopScope( // Prevent back button exit
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('Mi Carrito'), // Original
          title: Text('Mi Carrito', style: textTheme.headlineSmall?.copyWith(fontSize: (textTheme.headlineSmall?.fontSize ?? 24) + kioskExtraFontSize)),
          automaticallyImplyLeading: false, // No back button en AppBar por defecto
                                          // Si se necesita un botón de "volver al kiosko-menu", debe ser explícito.
          actions: [
            if (cart.itemsList.isNotEmpty)
              IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vaciar Carrito',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () { Navigator.of(ctx).pop(); },
                      ),
                      TextButton(
                        child: Text('Vaciar', style: TextStyle(color: colorScheme.error)),
                        onPressed: () { cart.clearCart(); Navigator.of(ctx).pop(); },
                      ),
                    ],
                  ),
                );
              }
            ),
        ],
      ),
      body: cart.itemsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 100, color: AppColors.textMuted.withOpacity(0.5)), // Increased size
                  const SizedBox(height: 20),
                  Text('Tu carrito está vacío', style: textTheme.headlineSmall?.copyWith(fontSize: (textTheme.headlineSmall?.fontSize ?? 24) + kioskExtraFontSize)), // Increased size
                  const SizedBox(height: 8),
                  Text('¡Agrega algunos productos!', style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted, fontSize: (textTheme.titleMedium?.fontSize ?? 16) + kioskExtraFontSize - 2)), // Increased size
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0), // Increased padding
                    itemCount: cart.itemsList.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.itemsList[i];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0), // Increased margin
                        child: Padding( // Added padding inside card
                          padding: const EdgeInsets.all(12.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero, // Adjust ListTile padding if needed
                            leading: SizedBox(
                              width: 80, // Increased size
                              height: 80, // Increased size
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/products/${cartItem.product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general'}/${cartItem.product.imagen ?? '${cartItem.product.id.toLowerCase()}.jpg'}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.surfaceDark.withOpacity(0.5),
                                    child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 40), // Increased size
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              cartItem.product.nombre,
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: (textTheme.titleLarge?.fontSize ?? 20) + kioskExtraFontSize - 2) // Increased size
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: \$${cartItem.itemTotalPrice.toStringAsFixed(0)}',
                                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary, fontSize: (textTheme.bodyLarge?.fontSize ?? 16) + kioskExtraFontSize - 2) // Increased size
                                ),
                                if (cartItem.selectedAgregados.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Extras: ${cartItem.selectedAgregados.map((ag) => ag.nombre).join(', ')}',
                                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: (textTheme.bodyMedium?.fontSize ?? 14) + kioskExtraFontSize - 4), // Increased size
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, size: kioskIconSize + 4), // Increased size
                                  color: AppColors.primaryRed,
                                  onPressed: () { cart.updateItemQuantity(cartItem.id, cartItem.quantity - 1); },
                                  splashRadius: kioskIconSize, // Increased splash
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Added padding for quantity text
                                  child: Text('${cartItem.quantity}', style: textTheme.titleLarge?.copyWith(fontSize: (textTheme.titleLarge?.fontSize ?? 20) + kioskExtraFontSize - 2)), // Increased size
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, size: kioskIconSize + 4), // Increased size
                                  color: AppColors.primaryRed,
                                  onPressed: () { cart.updateItemQuantity(cartItem.id, cartItem.quantity + 1); },
                                  splashRadius: kioskIconSize, // Increased splash
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (ctx, i) => const Divider(height: 1, thickness: 1),
                  ),
                ),
                Container( // Container for bottom summary and button
                  padding: const EdgeInsets.all(20.0), // Increased padding
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor, // Match scaffold background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, -5), // Shadow to the top
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total General:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: (textTheme.headlineSmall?.fontSize ?? 24) + kioskExtraFontSize)), // Increased size
                          Text( '\$${cart.totalPrice.toStringAsFixed(0)}', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary, fontSize: (textTheme.headlineSmall?.fontSize ?? 24) + kioskExtraFontSize), // Increased size
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Increased spacing
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20.0), // Increased padding for taller button
                            textStyle: textTheme.labelLarge?.copyWith(fontSize: (textTheme.labelLarge?.fontSize ?? 14) + kioskExtraFontSize + 2, fontWeight: FontWeight.bold), // Increased font size
                          ),
                          onPressed: cart.itemsList.isEmpty ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                            );
                          },
                          child: const Text('PROCEDER AL PAGO'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    ));
  }
}
