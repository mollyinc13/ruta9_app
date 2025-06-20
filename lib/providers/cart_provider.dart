// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/agregado_model.dart';
import '../models/cart_item_model.dart';
import 'dart:math'; // For random ID generation, or use uuid package

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {}; // Use Map for easier access by ID

  Map<String, CartItem> get items {
    return {..._items}; // Return a copy
  }

  List<CartItem> get itemsList {
    return _items.values.toList();
  }

  int get itemCount {
    // Returns the total number of individual products in the cart (sum of quantities)
    int count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  int get uniqueItemCount {
    // Returns the number of unique line items in the cart
    return _items.length;
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.itemTotalPrice;
    });
    return total;
  }

  // Generates a unique ID for a cart item based on product ID and selected agregados.
  // This ensures that the same product with different agregados is a different cart item.
  String _generateCartItemId(String productId, List<Agregado> selectedAgregados) {
    if (selectedAgregados.isEmpty) {
      return productId;
    }
    // Sort agregados by name to ensure consistent ID regardless of selection order
    List<String> agregadoNames = selectedAgregados.map((ag) => ag.nombre).toList()..sort();
    return '$productId-${agregadoNames.join('-')}';
  }

  void addItem({
    required Product product,
    required int quantity,
    required List<Agregado> selectedAgregados,
  }) {
    final cartItemId = _generateCartItemId(product.id, selectedAgregados);

    double singleItemBasePrice = product.precio;
    for (var agregado in selectedAgregados) {
      singleItemBasePrice += agregado.precio;
    }
    final double itemTotalPriceForNewAddition = singleItemBasePrice * quantity;

    if (_items.containsKey(cartItemId)) {
      // If item already exists with the same configuration, update quantity and total price
      _items.update(
        cartItemId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + quantity, // Add to existing quantity
          selectedAgregados: existingCartItem.selectedAgregados, // Agregados don't change for existing item
          itemTotalPrice: existingCartItem.itemTotalPrice + itemTotalPriceForNewAddition, // Add to existing total
        ),
      );
      print('CartProvider: Updated quantity for item $cartItemId. New quantity: ${_items[cartItemId]!.quantity}');
    } else {
      // If it's a new item (or new configuration of an existing product)
      _items.putIfAbsent(
        cartItemId,
        () => CartItem(
          id: cartItemId,
          product: product,
          quantity: quantity,
          selectedAgregados: List.from(selectedAgregados), // Create a new list
          itemTotalPrice: itemTotalPriceForNewAddition,
        ),
      );
      print('CartProvider: Added new item $cartItemId to cart.');
    }
    notifyListeners();
  }

  void updateItemQuantity(String cartItemId, int newQuantity) {
    if (!_items.containsKey(cartItemId)) {
      return;
    }
    if (newQuantity <= 0) {
      // If new quantity is zero or less, remove the item
      removeItem(cartItemId);
    } else {
      _items.update(
        cartItemId,
        (existingCartItem) {
          // Recalculate total price for this item based on the new quantity
          double singleItemBasePrice = existingCartItem.product.precio;
          for (var agregado in existingCartItem.selectedAgregados) {
            singleItemBasePrice += agregado.precio;
          }
          return CartItem(
            id: existingCartItem.id,
            product: existingCartItem.product,
            quantity: newQuantity,
            selectedAgregados: existingCartItem.selectedAgregados,
            itemTotalPrice: singleItemBasePrice * newQuantity,
          );
        },
      );
      print('CartProvider: Updated quantity for item $cartItemId to $newQuantity.');
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    if (_items.containsKey(cartItemId)) {
      _items.remove(cartItemId);
      print('CartProvider: Removed item $cartItemId from cart.');
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    print('CartProvider: Cart cleared.');
    notifyListeners();
  }
}
