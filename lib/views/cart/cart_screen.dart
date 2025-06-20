// lib/views/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart';
import '../../core/constants/colors.dart'; // For styling

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>(); // Watch for changes
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        automaticallyImplyLeading: false, // As it's a tab in MainAppShell
        actions: [
          if (cart.itemsList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vaciar Carrito',
              onPressed: () {
                // Confirmation Dialog before clearing cart
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Vaciar', style: TextStyle(color: colorScheme.error)),
                        onPressed: () {
                          cart.clearCart(); // Use read here as we are in a callback
                          // Provider.of<CartProvider>(context, listen: false).clearCart();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.itemsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 80, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text('Tu carrito está vacío', style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('¡Agrega algunos productos!', style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: cart.itemsList.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.itemsList[i];
                      return Card( // Wrap each item in a Card for better visual separation
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        // elevation: 2, // Uses CardTheme from AppTheme
                        child: ListTile(
                          leading: SizedBox(
                            width: 70, // Fixed width for image container
                            height: 70, // Fixed height for image container
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                // Basic image path derivation, assuming product.imagen exists
                                'assets/images/products/${cartItem.product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general'}/${cartItem.product.imagen ?? '${cartItem.product.id.toLowerCase()}.jpg'}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceDark.withOpacity(0.5),
                                  child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 30),
                                ),
                              ),
                            ),
                          ),
                          title: Text(cartItem.product.nombre, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total: \$${cartItem.itemTotalPrice.toStringAsFixed(0)}', style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary)),
                              if (cartItem.selectedAgregados.isNotEmpty)
                                Text(
                                  'Extras: ${cartItem.selectedAgregados.map((ag) => ag.nombre).join(', ')}',
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 24),
                                color: AppColors.primaryRed,
                                onPressed: () {
                                  cart.updateItemQuantity(cartItem.id, cartItem.quantity - 1);
                                },
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('${cartItem.quantity}', style: textTheme.titleMedium),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 24),
                                color: AppColors.primaryRed,
                                onPressed: () {
                                  cart.updateItemQuantity(cartItem.id, cartItem.quantity + 1);
                                },
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                  ),
                ),
                // Total and Checkout Button Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total General:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(0)}',
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            // backgroundColor: AppColors.primaryRed, // From theme
                            // textStyle: textTheme.labelLarge, // From theme
                          ),
                          onPressed: cart.itemsList.isEmpty ? null : () {
                            // Placeholder for checkout action
                            print('Checkout button pressed. Total: ${cart.totalPrice}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proceso de pago (pendiente).')),
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
    );
  }
}
