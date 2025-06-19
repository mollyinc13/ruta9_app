import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/category_section.dart';
import '../views/product/product_detail_dialog.dart';
// import '../widgets/floating_cart_button.dart'; // Removed import

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
  // int _cartItemCount = 0; // Removed state for FAB badge

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final allProducts = await _productService.getProducts();
      if (allProducts.isEmpty && mounted) {
        print('MenuR9ZonaFrancaScreen: No products loaded from service. Ensure assets/data/products.json is populated and valid.');
        setState(() {
          _error = 'No hay productos disponibles en este momento. Intente más tarde.';
          _isLoading = false;
        });
        return;
      }
      final zonaFrancaProducts = allProducts.where((p) => p.zonaFranca == true).toList();
      print('MenuR9ZonaFrancaScreen: Total products loaded: ${allProducts.length}, Zona Franca products: ${zonaFrancaProducts.length}');
      if (mounted) {
        if (zonaFrancaProducts.isEmpty) {
          print('MenuR9ZonaFrancaScreen: No products specifically marked for Zona Franca.');
           setState(() {
            _categorizedProducts = {};
            _isLoading = false;
          });
        } else {
          setState(() {
            _categorizedProducts = _productService.groupProductsByCategory(zonaFrancaProducts);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('MenuR9ZonaFrancaScreen: Error loading or categorizing products: $e');
      if (mounted) {
        setState(() {
          _error = 'Ocurrió un error al cargar los productos.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleProductInteraction(Product product) {
    showDialog<Map<String, dynamic>>(
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
        // setState(() { // Removed cart item count update
        //   _cartItemCount += (result['quantity'] as int?) ?? 1;
        // });
      } else {
        print('Product detail dialog dismissed without action.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // This screen is now part of MainAppShell, so its AppBar might be controlled
        // by MainAppShell or defined here. If MainAppShell doesn't have a central AppBar,
        // this AppBar is fine.
        // If MainAppShell *does* have an AppBar, this one might need to be removed or adjusted.
        // For now, keeping it as it provides context for this specific view.
        title: const Text('Ruta 9 - Zona Franca'),
        automaticallyImplyLeading: false, // Usually false if this is a root view in a tab
      ),
      body: _buildBody(),
      // floatingActionButton: FloatingCartButton( // Removed FAB
      //   itemCount: _cartItemCount,
      //   onPressed: () {
      //     print('Floating Cart Button Tapped!');
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Navegar a la pantalla del carrito (pendiente).')),
      //     );
      //   },
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Removed
    );
  }

  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator());}
    if (_error != null) { return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center,),),); }
    if (_categorizedProducts.isEmpty) {
      return Center(child: Text('No hay productos disponibles para Zona Franca en este momento.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }
    final categoryKeys = _categorizedProducts.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
