import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/category_section.dart';
import '../views/product/product_detail_dialog.dart'; // Import the dialog

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

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      if (products.isEmpty && mounted) {
        print('No products loaded from service. Ensure assets/data/products.json is populated and valid.');
        setState(() {
          _error = 'No hay productos disponibles en este momento. Intente más tarde.';
          _isLoading = false;
        });
        return;
      }
      if (mounted) {
        setState(() {
          _categorizedProducts = _productService.groupProductsByCategory(products);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading or categorizing products: $e');
      if (mounted) {
        setState(() {
          _error = 'Ocurrió un error al cargar los productos.';
          _isLoading = false;
        });
      }
    }
  }

  // Updated to show the ProductDetailDialog
  void _handleProductInteraction(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use a different context name
        return ProductDetailDialog(product: product);
      },
    ).then((result) {
      // This 'then' block executes after the dialog is popped.
      // 'result' is the value passed to Navigator.pop() in ProductDetailDialog.
      if (result != null && result is Map<String, dynamic>) {
        // A cart item was successfully "added" (simulated)
        print('Dialog closed, item added to cart (simulated): ${result['productName']}');
        // You could show another SnackBar here, or update a cart badge, etc.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${result['productName']} (x${result['quantity']}) procesado."),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          ),
        );
      } else {
        // Dialog was dismissed without "adding to cart" (e.g., tapped outside, back button)
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center,),
        ),
      );
    }
    if (_categorizedProducts.isEmpty) {
      return Center(child: Text('No hay categorías de productos para mostrar.', style: Theme.of(context).textTheme.titleMedium,));
    }
    final categoryKeys = _categorizedProducts.keys.toList();
    return ListView.builder(
      itemCount: categoryKeys.length,
      itemBuilder: (context, index) {
        final categoryName = categoryKeys[index];
        final productsInCategory = _categorizedProducts[categoryName]!;
        return CategorySection(
          categoryTitle: categoryName,
          products: productsInCategory,
          // Both tap on card and "Add" button will trigger the same dialog
          onProductSelected: _handleProductInteraction,
          onProductAdded: _handleProductInteraction,
        );
      },
    );
  }
}
