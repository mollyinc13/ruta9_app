// lib/screens/menur9zonafranca.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For groupBy
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../views/product/product_detail_dialog.dart';

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

  void _setupTabController(List<String> categoriesForLengthDetermination) {
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

  void _handleProductInteraction(Product product) {
    // Corrected line:
    showDialog<dynamic>( context: context, builder: (BuildContext dialogContext) { return ProductDetailDialog(product: product); },
    ).then((result) {
      if (result == true) {
        print('MenuR9ZonaFrancaScreen: ProductDetailDialog closed with success (item added).');
      } else {
        print('MenuR9ZonaFrancaScreen: ProductDetailDialog dismissed without adding to cart (result: $result).');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Added a null check for _tabController before accessing its length or properties
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

    // Simplified condition for showing "No products" message
    if (_allZonaFrancaProducts.isEmpty) {
         return Center(child: Text('No hay productos disponibles para Zona Franca.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }
    // If _tabController is null (can happen briefly or on error during init), show loading or empty.
    // This check is important before TabBarView.
    if (_tabController == null) {
        return const Center(child: CircularProgressIndicator()); // Or an appropriate empty/error message
    }


    return TabBarView(
      key: ValueKey(_tabCategories.join('-')),
      controller: _tabController,
      children: _tabCategories.map((String category) {
        final productsToShow = (category == "TODOS")
            ? _allZonaFrancaProducts
            : (_productsByCategory[category] ?? []);

        // Simplified empty message logic within TabBarView child
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
              duration: Duration(milliseconds: 300 + (index % 5 * 100)),
              curve: Curves.easeOut,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - value) * 30),
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
