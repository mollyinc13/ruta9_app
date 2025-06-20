// lib/models/cart_item_model.dart
import 'package:flutter/foundation.dart'; // For @required if using older Flutter, or for general Flutter types.
import 'product_model.dart';
import 'agregado_model.dart';

class CartItem {
  final String id; // Unique ID for the cart item (could be product.id if no variants, or a new UUID)
  final Product product;
  int quantity;
  final List<Agregado> selectedAgregados;
  double itemTotalPrice; // Price for this cart item (product.precio + sum of selectedAgregados.precio) * quantity

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedAgregados,
    required this.itemTotalPrice,
  });

  // Helper method to recalculate total price for this item if quantity or agregados change
  // This might be better handled in the CartProvider when updating quantity
  void recalculateItemTotalPrice() {
    double baseSinglePrice = product.precio;
    for (var agregado in selectedAgregados) {
      baseSinglePrice += agregado.precio;
    }
    itemTotalPrice = baseSinglePrice * quantity;
  }

  // For easier debugging
  @override
  String toString() {
    return 'CartItem(id: $id, productName: ${product.nombre}, quantity: $quantity, selectedAgregados: ${selectedAgregados.length}, itemTotalPrice: $itemTotalPrice)';
  }

  // Optional: For equality checks if managing lists of CartItems directly
  // and needing to find/remove them based on more than just ID.
  // For simple cart, ID-based management in CartProvider is usually enough.
  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is CartItem &&
  //       other.id == id &&
  //       other.product.id == product.id && // Simplistic check, could be deeper
  //       other.quantity == quantity &&
  //       listEquals(other.selectedAgregados, selectedAgregados); // Requires listEquals from foundation.dart
  // }

  // @override
  // int get hashCode =>
  //     id.hashCode ^
  //     product.id.hashCode ^
  //     quantity.hashCode ^
  //     selectedAgregados.hashCode; // Simplistic
}
