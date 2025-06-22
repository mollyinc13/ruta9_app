// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/agregado_model.dart';
import '../models/cart_item_model.dart';
// import 'dart:math'; // Not used if _generateCartItemId is deterministic

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  List<CartItem> get itemsList => _items.values.toList();

  int get itemCount {
    int count = 0;
    _items.forEach((key, cartItem) { count += cartItem.quantity; });
    return count;
  }

  int get uniqueItemCount => _items.length;

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) { total += cartItem.itemTotalPrice; });
    return total;
  }

  String _generateCartItemId(String productId, List<Agregado> selectedAgregados) {
    if (selectedAgregados.isEmpty) { return productId; }
    List<String> agregadoNames = selectedAgregados.map((ag) => ag.nombre).toList()..sort();
    return '$productId-${agregadoNames.join('-')}';
  }

  // MODIFIED addItem method with Debug Prints
  void addItem({
    required Product product,
    required int quantity,
    required List<Agregado> selectedAgregados,
  }) {
    debugPrint("[CartProvider.addItem] Entered addItem method.");
    debugPrint("[CartProvider.addItem] Product: ${product.nombre} (ID: ${product.id}), Quantity: $quantity, Agregados: ${selectedAgregados.map((ag) => ag.nombre).join(', ')}");

    final cartItemId = _generateCartItemId(product.id, selectedAgregados);
    debugPrint("[CartProvider.addItem] Generated cartItemId: $cartItemId");

    double singleItemBasePrice = product.precio;
    for (var agregado in selectedAgregados) {
      singleItemBasePrice += agregado.precio;
    }
    final double itemTotalPriceContribution = singleItemBasePrice * quantity; // Price for the quantity being added *now*

    if (_items.containsKey(cartItemId)) {
      debugPrint("[CartProvider.addItem] Item $cartItemId already exists. Updating quantity.");
      _items.update(
        cartItemId,
        (existingCartItem) {
          int newQuantity = existingCartItem.quantity + quantity;
          double newItemTotalPrice = existingCartItem.itemTotalPrice + itemTotalPriceContribution; // Add contribution
          return CartItem(
            id: existingCartItem.id,
            product: existingCartItem.product,
            quantity: newQuantity,
            selectedAgregados: existingCartItem.selectedAgregados,
            itemTotalPrice: newItemTotalPrice,
          );
        },
      );
      debugPrint("[CartProvider.addItem] Updated item $cartItemId. New quantity: ${_items[cartItemId]!.quantity}, New itemTotalPrice: ${_items[cartItemId]!.itemTotalPrice}");
    } else {
      debugPrint("[CartProvider.addItem] Item $cartItemId is new. Adding to cart.");
      _items.putIfAbsent(
        cartItemId,
        () => CartItem(
          id: cartItemId,
          product: product,
          quantity: quantity,
          selectedAgregados: List.from(selectedAgregados),
          itemTotalPrice: itemTotalPriceContribution, // This is the total for this new item
        ),
      );
      debugPrint("[CartProvider.addItem] Added new item $cartItemId. Quantity: ${_items[cartItemId]!.quantity}, itemTotalPrice: ${_items[cartItemId]!.itemTotalPrice}");
    }

    debugPrint("[CartProvider.addItem] Current cart unique items: ${uniqueItemCount}, total quantity: ${itemCount}, grand total price: \$${totalPrice.toStringAsFixed(0)}");
    notifyListeners();
    debugPrint("[CartProvider.addItem] Exited addItem method and called notifyListeners().");
  }

  void updateItemQuantity(String cartItemId, int newQuantity) {
    if (!_items.containsKey(cartItemId)) { return; }
    if (newQuantity <= 0) {
      removeItem(cartItemId);
    } else {
      _items.update(
        cartItemId,
        (existingCartItem) {
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
