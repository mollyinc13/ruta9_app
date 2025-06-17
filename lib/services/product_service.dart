import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product_model.dart';

class ProductService {
  List<Product>? _products; // Cached products

  Future<List<Product>> getProducts() async {
    if (_products != null) {
      return _products!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _products = jsonList
          .map((jsonItem) => Product.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      print('ProductService: Loaded ${_products!.length} products from assets.');
      return _products!;
    } catch (e) {
      print('Error loading products from assets: $e');
      // In a real app, handle this error more gracefully
      return [];
    }
  }

  // Helper to group products by subcategory for the UI
  Map<String, List<Product>> groupProductsByCategory(List<Product> products) {
    final Map<String, List<Product>> categorizedProducts = {};
    for (var product in products) {
      final category = product.subcategoria ?? 'Otros'; // Default category if null
      if (categorizedProducts.containsKey(category)) {
        categorizedProducts[category]!.add(product);
      } else {
        categorizedProducts[category] = [product];
      }
    }
    // Optionally sort products within each category by position
    categorizedProducts.forEach((key, value) {
      value.sort((a, b) => a.posicion.compareTo(b.posicion));
    });
    return categorizedProducts;
  }
}
