// Relevant parts of menur9zonafranca.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/category_section.dart';
import '../views/product/product_detail_dialog.dart';
import '../widgets/floating_cart_button.dart'; // Import the button

class MenuR9ZonaFrancaScreen extends StatefulWidget {
  const MenuR9ZonaFrancaScreen({super.key});
  @override
  State<MenuR9ZonaFrancaScreen> createState() => _MenuR9ZonaFrancaScreenState();
}

class _MenuR9ZonaFrancaScreenState extends State<MenuR9ZonaFrancaScreen> {
  final ProductService _productService = ProductService();
  Map<String, List<Product>> _categorizedProducts = {};
  bool _isLoading = true;
  String? _error;
  int _cartItemCount = 0; // Placeholder for cart item count

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // ... (existing _loadProducts logic remains the same) ...
    try {
      final products = await _productService.getProducts();
      if (products.isEmpty && mounted) {
        // Simplified error message assignment for brevity in this context
        setState(() { _error = 'No hay productos disponibles en este momento. Intente más tarde.'; _isLoading = false; });
        return;
      }
      if (mounted) {
        setState(() {
          _categorizedProducts = _productService.groupProductsByCategory(products);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Simplified error message assignment
        setState(() { _error = 'Ocurrió un error al cargar los productos.'; _isLoading = false; });
      }
    }
  }

  void _handleProductInteraction(Product product) {
    showDialog<Map<String, dynamic>>( // Specify type for showDialog
      context: context,
      builder: (BuildContext dialogContext) {
        return ProductDetailDialog(product: product);
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        print('Dialog closed, item added to cart (simulated): ${result['productName']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${result['productName']} (x${result['quantity']}) procesado."),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          ),
        );
        // Placeholder: Increment cart count
        // In a real app, this would come from a cart service/state management
        setState(() {
          _cartItemCount += (result['quantity'] as int?) ?? 1;
        });
      } else {
        print('Product detail dialog dismissed without action.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta 9 - Zona Franca'),
      ),
      body: _buildBody(), // _buildBody remains the same
      floatingActionButton: FloatingCartButton(
        itemCount: _cartItemCount, // Use the state variable
        onPressed: () {
          print('Floating Cart Button Tapped!');
          // Placeholder: Navigate to cart screen or show cart summary
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navegar a la pantalla del carrito (pendiente).')),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Example location
    );
  }

   Widget _buildBody() { // Copied for completeness, no changes here
    if (_isLoading) { return const Center(child: CircularProgressIndicator());}
    if (_error != null) { return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center,),),); }
    if (_categorizedProducts.isEmpty) { return Center(child: Text('No hay categorías de productos para mostrar.', style: Theme.of(context).textTheme.titleMedium,));}
    final categoryKeys = _categorizedProducts.keys.toList();
    return ListView.builder(
      itemCount: categoryKeys.length,
      itemBuilder: (context, index) {
        final categoryName = categoryKeys[index];
        final productsInCategory = _categorizedProducts[categoryName]!;
        return CategorySection(
          categoryTitle: categoryName,
          products: productsInCategory,
          onProductSelected: _handleProductInteraction,
          onProductAdded: _handleProductInteraction,
        );
      },
    );
  }
}
