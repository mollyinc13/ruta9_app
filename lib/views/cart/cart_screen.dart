// lib/views/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart'; // Keep for type, though not directly instantiated
import '../../core/constants/colors.dart';
import '../../screens/checkout/checkout_screen.dart'; // Import CheckoutScreen

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        automaticallyImplyLeading: false,
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
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
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
                                onPressed: () { cart.updateItemQuantity(cartItem.id, cartItem.quantity - 1); },
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('${cartItem.quantity}', style: textTheme.titleMedium),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 24),
                                color: AppColors.primaryRed,
                                onPressed: () { cart.updateItemQuantity(cartItem.id, cartItem.quantity + 1); },
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total General:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text( '\$${cart.totalPrice.toStringAsFixed(0)}', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: cart.itemsList.isEmpty ? null : () {
                            // MODIFIED: Navigate to CheckoutScreen
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
    );
  }
}
