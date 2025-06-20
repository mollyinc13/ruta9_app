// lib/screens/menur9zonafranca.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For groupBy
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../views/product/product_detail_dialog.dart';
// AppColors might be needed if SnackBar uses it explicitly, else Theme colors are fine
import '../core/constants/colors.dart';


class MenuR9ZonaFrancaScreen extends StatefulWidget {
  const MenuR9ZonaFrancaScreen({super.key});
  @override
  State<MenuR9ZonaFrancaScreen> createState() => _MenuR9ZonaFrancaScreenState();
}

class _MenuR9ZonaFrancaScreenState extends State<MenuR9ZonaFrancaScreen> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  List<Product> _allZonaFrancaProducts = [];
  List<String> _tabCategories = [];
  Map<String, List<Product>> _productsByCategory = {};
  TabController? _tabController;
  bool _isLoading = true;
  String? _error;

  final Map<String, IconData> _categoryIcons = {
    'BURGER': Icons.lunch_dining,
    'BEBIDAS': Icons.local_bar,
    'ACOMPAÑAMIENTOS': Icons.fastfood,
    'SANDWICH': Icons.breakfast_dining,
    'COMBOS': Icons.takeout_dining,
    'OTROS': Icons.category,
  };

  IconData _getIconForCategory(String categoryName) {
    return _categoryIcons[categoryName.toUpperCase()] ?? Icons.label_important_outline;
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; _allZonaFrancaProducts = []; _tabCategories = []; _productsByCategory = {}; });
    try {
      final allProducts = await _productService.getProducts();
      if (!mounted) return;
      if (allProducts.isEmpty) {
        setState(() { _error = 'No hay productos disponibles.'; _isLoading = false; });
        _setupTabController([]);
        return;
      }
      _allZonaFrancaProducts = allProducts.where((p) => p.zonaFranca == true).toList();
      if (_allZonaFrancaProducts.isEmpty) {
        setState(() { _isLoading = false; });
        _setupTabController([]);
        return;
      }
      _productsByCategory = groupBy(_allZonaFrancaProducts, (Product p) => p.subcategoria ?? 'OTROS');
      List<String> uniqueCategories = _productsByCategory.keys.toList();
      uniqueCategories.sort();
      _tabCategories = ["TODOS", ...uniqueCategories];
      _setupTabController(uniqueCategories);
      setState(() { _isLoading = false; });
    } catch (e) {
      if (mounted) { setState(() { _error = 'Ocurrió un error al cargar los productos.'; _isLoading = false; });}
      _setupTabController([]);
    }
  }

  void _setupTabController(List<String> categories) {
    if (!mounted) return;
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _tabController = TabController(length: _tabCategories.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  // MODIFIED _handleProductInteraction method's .then() block
  void _handleProductInteraction(Product product) {
    showDialog<dynamic>( context: context, builder: (BuildContext dialogContext) { return ProductDetailDialog(product: product); },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final String productName = result['productName'] ?? 'Producto';
        final int quantity = result['quantity'] ?? 0;
        // Ensure totalPrice is treated as double, even if it comes as int from JSON map in some cases
        final double totalPrice = (result['totalPrice'] as num?)?.toDouble() ?? 0.0;


        if (mounted) { // Good practice to check if widget is still in tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName (x$quantity) agregado al carrito. Total: \$${totalPrice.toStringAsFixed(0)}'),
              // Using theme's primary color for SnackBar background for consistency
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              // Or use AppColors.success if a distinct success color is preferred:
              // backgroundColor: AppColors.success.withOpacity(0.9),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        print('MenuR9ZonaFrancaScreen: Item added - $productName (x$quantity), Total: $totalPrice');
      } else {
        print('MenuR9ZonaFrancaScreen: ProductDetailDialog dismissed without adding item (result: $result).');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showTabBar = _tabController != null &&
                      _tabController!.length > 0 &&
                      !(_tabController!.length == 1 && _tabCategories.first == "TODOS" && _allZonaFrancaProducts.isEmpty);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta 9 - Zona Franca'),
        automaticallyImplyLeading: false,
        bottom: showTabBar
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabCategories.map((String category) => Tab(text: category.toUpperCase())).toList(),
                labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator()); }
    if (_error != null) { return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center,),),); }
    if (_allZonaFrancaProducts.isEmpty) {
         return Center(child: Text('No hay productos disponibles para Zona Franca.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }
    if (_tabController == null) {
        return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      key: ValueKey(_tabCategories.join('-')),
      controller: _tabController,
      children: _tabCategories.map((String category) {
        final productsToShow = (category == "TODOS")
            ? _allZonaFrancaProducts
            : (_productsByCategory[category] ?? []);

        if (productsToShow.isEmpty) {
             return Center(child: Text('No hay productos en la categoría ${category.toUpperCase()}.', style: Theme.of(context).textTheme.titleMedium));
        }

        return GridView.builder(
          key: PageStorageKey(category),
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 200 / 320,
          ),
          itemCount: productsToShow.length,
          itemBuilder: (context, index) {
            final product = productsToShow[index];
            return TweenAnimationBuilder<double>(
              key: ValueKey(product.id),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - value) * 20),
                    child: child,
                  ),
                );
              },
              child: ProductCard(
                product: product,
                onTap: () => _handleProductInteraction(product),
                onAddButtonPressed: () => _handleProductInteraction(product),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
