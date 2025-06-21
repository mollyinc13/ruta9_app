import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/category_section.dart';
import '../widgets/combos_section.dart';
import '../views/product/product_detail_dialog.dart';

class MenuR9ZonaFrancaScreen extends StatefulWidget {
  const MenuR9ZonaFrancaScreen({super.key});
  @override
  State<MenuR9ZonaFrancaScreen> createState() => _MenuR9ZonaFrancaScreenState();
}

class _MenuR9ZonaFrancaScreenState extends State<MenuR9ZonaFrancaScreen> {
  final ProductService _productService = ProductService();
  List<Product> _comboProducts = [];
  Map<String, List<Product>> _otherCategorizedProducts = {};
  bool _isLoading = true;
  String? _error;

  // Helper map to get icons for categories
  final Map<String, IconData> _categoryIcons = {
    'BURGER': Icons.lunch_dining,
    'HAMBURGUESAS': Icons.lunch_dining,
    'BEBIDAS': Icons.local_bar,
    'ACOMPAÑAMIENTOS': Icons.fastfood,
    'SANDWICHES': Icons.breakfast_dining,
    'OTROS': Icons.category,
  };

  IconData _getIconForCategory(String categoryName) {
    return _categoryIcons[categoryName.toUpperCase()] ?? Icons.label_important_outline;
  }

  @override
  void initState() { super.initState(); _loadProducts(); }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; _comboProducts = []; _otherCategorizedProducts = {}; });
    try {
      final allProducts = await _productService.getProducts();
      if (allProducts.isEmpty && mounted) {
        setState(() { _error = 'No hay productos disponibles en este momento. Intente más tarde.'; _isLoading = false; }); return;
      }
      final zonaFrancaProducts = allProducts.where((p) => p.zonaFranca == true).toList();
      if (mounted) {
        if (zonaFrancaProducts.isEmpty) {
          setState(() { _isLoading = false; });
        } else {
          final List<Product> combos = [];
          final List<Product> otherProducts = [];
          for (var product in zonaFrancaProducts) {
            if ((product.subcategoria ?? '').toUpperCase() == 'COMBOS') { combos.add(product); }
            else { otherProducts.add(product); }
          }
          combos.sort((a,b) => a.id.compareTo(b.id));
          setState(() {
            _comboProducts = combos;
            _otherCategorizedProducts = _productService.groupProductsByCategory(otherProducts);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) { setState(() { _error = 'Ocurrió un error al cargar los productos.'; _isLoading = false; }); }
    }
  }

  void _handleProductInteraction(Product product) {
    showDialog<dynamic>( // Changed to dynamic to accept bool or null
      context: context,
      builder: (BuildContext dialogContext) {
        return ProductDetailDialog(product: product);
      },
    ).then((result) {
      // The dialog now pops `true` on successful add, or nothing (null) on close button/dismiss.
      if (result == true) {
        // This means item was "added to cart" successfully
        // The SnackBar with item details is now shown from within ProductDetailDialog's _addToCart.
        // Here, we might just want a generic confirmation or update cart badge (which is already provider-driven).
        print('MenuR9ZonaFrancaScreen: ProductDetailDialog closed with success (item added).');
        // Optionally, show a different, simpler SnackBar here or rely on CartProvider for UI updates.
        // For example, to refresh cart count if it wasn't provider-driven for the badge:
        // setState(() { /* _cartItemCount might be updated by listening to CartProvider elsewhere */ });
      } else {
        // Dialog was dismissed via close button, tap outside, or system back.
        print('MenuR9ZonaFrancaScreen: ProductDetailDialog dismissed without adding to cart (result: $result).');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Ruta 9 - Zona Franca'), automaticallyImplyLeading: false, ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator());}
    if (_error != null) { return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center,),),); }
    if (_comboProducts.isEmpty && _otherCategorizedProducts.isEmpty) {
      return Center(child: Text('No hay productos disponibles para Zona Franca en este momento.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }
    final otherCategoryKeys = _otherCategorizedProducts.keys.toList();

    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        if (_comboProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: CombosSectionWidget(
              comboProducts: _comboProducts,
              onComboSelected: _handleProductInteraction,
              onComboAdded: _handleProductInteraction,
            ),
          ),
        if (_otherCategorizedProducts.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final categoryName = otherCategoryKeys[index];
                final productsInCategory = _otherCategorizedProducts[categoryName]!;
                return CategorySection(
                  categoryTitle: categoryName,
                  products: productsInCategory,
                  icon: _getIconForCategory(categoryName),
                  onProductSelected: _handleProductInteraction,
                  onProductAdded: _handleProductInteraction,
                );
              },
              childCount: otherCategoryKeys.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
      ],
    );
  }
}
