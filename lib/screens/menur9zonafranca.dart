// lib/screens/menur9zonafranca.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/category_section.dart';
import '../widgets/combos_section.dart';
import '../views/product/product_detail_dialog.dart';
// Import FontAwesomeIcons if specific icons are desired, or use standard Material Icons
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    'BURGER': Icons.lunch_dining, // Example, was 'Hamburguesas' before, now expecting 'BURGER' from CSV
    'HAMBURGUESAS': Icons.lunch_dining, // Keep old mapping just in case
    'BEBIDAS': Icons.local_bar,
    'ACOMPAÑAMIENTOS': Icons.fastfood, // Or a more specific icon for fries etc.
    'SANDWICHES': Icons.breakfast_dining, // Example
    // Add other categories and their icons as needed
    'OTROS': Icons.category, // Default for 'Otros'
  };

  IconData _getIconForCategory(String categoryName) {
    return _categoryIcons[categoryName.toUpperCase()] ?? Icons.label_important_outline; // Fallback icon
  }

  // ... (initState, _loadProducts, _handleProductInteraction methods remain the same) ...
  @override
  void initState() { super.initState(); _loadProducts(); }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; _comboProducts = []; _otherCategorizedProducts = {}; });
    try {
      final allProducts = await _productService.getProducts();
      if (allProducts.isEmpty && mounted) {
        // Simplified for brevity
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
      // Simplified for brevity
      if (mounted) { setState(() { _error = 'Ocurrió un error al cargar los productos.'; _isLoading = false; }); }
    }
  }

  void _handleProductInteraction(Product product) {
    showDialog<Map<String, dynamic>>( context: context, builder: (BuildContext dialogContext) { return ProductDetailDialog(product: product); },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text("${result['productName']} (x${result['quantity']}) procesado."), duration: const Duration(seconds: 2), backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),),);
      } else { print('Product detail dialog dismissed without action.'); }
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
    // Sort otherCategoryKeys if a specific order is desired, e.g., alphabetically
    // otherCategoryKeys.sort();

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
                  icon: _getIconForCategory(categoryName), // Pass the icon
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
