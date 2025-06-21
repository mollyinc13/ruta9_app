// lib/screens/menur9zonafranca.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For groupBy
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart'; // Will use ProductCard directly
import '../views/product/product_detail_dialog.dart';
// CombosSectionWidget and CategorySection are no longer directly used by this screen's build method.

class MenuR9ZonaFrancaScreen extends StatefulWidget {
  const MenuR9ZonaFrancaScreen({super.key});
  @override
  State<MenuR9ZonaFrancaScreen> createState() => _MenuR9ZonaFrancaScreenState();
}

class _MenuR9ZonaFrancaScreenState extends State<MenuR9ZonaFrancaScreen> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();

  List<Product> _allZonaFrancaProducts = []; // All products for Zona Franca
  List<String> _tabCategories = []; // Categories for TabBar, including "TODOS"
  Map<String, List<Product>> _productsByCategory = {}; // Products grouped by actual subcategoria

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
        _setupTabController([]); // Setup with empty tabs even on initial empty load
        return;
      }

      _allZonaFrancaProducts = allProducts.where((p) => p.zonaFranca == true).toList();
      if (_allZonaFrancaProducts.isEmpty) {
        setState(() { _isLoading = false; }); // Will show empty message
        _setupTabController([]); // Setup with empty tabs
        return;
      }

      // Group products by their actual subcategoria for TabBarView content
      _productsByCategory = groupBy(_allZonaFrancaProducts, (Product p) => p.subcategoria ?? 'OTROS');

      // Create tab list: "TODOS" + sorted unique subcategories
      List<String> uniqueCategories = _productsByCategory.keys.toList();
      uniqueCategories.sort(); // Sort for consistent tab order

      _tabCategories = ["TODOS", ...uniqueCategories];

      _setupTabController(uniqueCategories); // Pass actual categories for controller length

      setState(() { _isLoading = false; });

    } catch (e) {
      if (mounted) { setState(() { _error = 'Ocurrió un error al cargar los productos.'; _isLoading = false; });}
      _setupTabController([]); // Setup with empty tabs on error too
    }
  }

  void _setupTabController(List<String> categories) {
    // Check if the widget is still mounted before interacting with TabController or setState
    if (!mounted) return;

    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose(); // Dispose old controller if exists

    _tabController = TabController(length: _tabCategories.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // This method is called when the tab selection changes.
    // If _tabController is not null and its index is changing,
    // it means the user has swiped or tapped a new tab.
    if (_tabController != null && _tabController!.indexIsChanging) {
      // TabBarView itself handles switching the content.
      // If you needed to perform actions based on tab change (e.g., logging, fetching new data for the selected tab),
      // you could do that here. For the current setup where all data is pre-loaded and filtered,
      // just calling setState might be needed if other parts of the UI depend on the selected tab index
      // outside of what TabBarView manages.
      if (mounted) {
        setState(() {
          // This setState call ensures that if any other part of your UI
          // (not managed by TabBarView directly) depends on the selected tab index,
          // it gets rebuilt. For example, if you had a dynamic title outside the AppBar's bottom.
        });
      }
    }
  }

  // _getProductsForSelectedTab is not strictly needed if TabBarView is built by mapping _tabCategories directly.
  // It was part of an earlier thought process. Keeping it commented out for now.
  // List<Product> _getProductsForSelectedTab() {
  //   if (_tabController == null || _tabCategories.isEmpty) return [];
  //   final selectedCategory = _tabCategories[_tabController!.index];
  //   if (selectedCategory == "TODOS") {
  //     return _allZonaFrancaProducts;
  //   }
  //   return _productsByCategory[selectedCategory] ?? [];
  // }

  void _handleProductInteraction(Product product) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta 9 - Zona Franca'),
        automaticallyImplyLeading: false,
        bottom: _tabController != null && _tabController!.length > 0 && !(_tabController!.length == 1 && _tabCategories.first == "TODOS" && _allZonaFrancaProducts.isEmpty)
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

    if (_tabController == null || _tabController!.length == 0) {
         return Center(child: Text('No hay productos disponibles para Zona Franca.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }
    // Specific check for only "TODOS" tab with no products
    if (_tabController!.length == 1 && _tabCategories.first == "TODOS" && _allZonaFrancaProducts.isEmpty) {
        return Center(child: Text('No hay productos disponibles para Zona Franca.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,));
    }


    return TabBarView(
      controller: _tabController,
      children: _tabCategories.map((String category) {
        final productsToShow = (category == "TODOS")
            ? _allZonaFrancaProducts
            : (_productsByCategory[category] ?? []);

        if (productsToShow.isEmpty && category == "TODOS" && _tabCategories.length > 1) {
            // If "TODOS" is empty but other categories exist, it implies a filter error or no products at all.
            // This message might be redundant if the main check above handles it.
             return Center(child: Text('No hay productos disponibles.', style: Theme.of(context).textTheme.titleMedium));
        } else if (productsToShow.isEmpty && category != "TODOS") {
             return Center(child: Text('No hay productos en la categoría ${category.toUpperCase()}.', style: Theme.of(context).textTheme.titleMedium));
        }

        return GridView.builder(
          key: PageStorageKey(category), // Preserve scroll position per tab
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
            return ProductCard(
              product: product,
              onTap: () => _handleProductInteraction(product),
              onAddButtonPressed: () => _handleProductInteraction(product),
            );
          },
        );
      }).toList(),
    );
  }
}
