// lib/screens/menur9zonafranca.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For groupBy
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';
import '../widgets/shimmer_loading.dart';
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
    'SANDWICH': Icons.breakfast_dining, // Usando breakfast_dining para Sandwich
    'SNACK': Icons.fastfood,
    'BEBIDA': Icons.local_drink,
    'ACOMPAÑAMIENTOS': Icons.fastfood, // Alias por si aparece esta categoría
    'COMBOS': Icons.takeout_dining,
    'OTROS': Icons.category,
    'TODOS': Icons.apps // Ícono para la pestaña "TODOS"
  };

  IconData _getIconForCategory(String categoryName) {
    // La clave ya viene en mayúsculas desde donde se llama en TabBar
    return _categoryIcons[categoryName] ?? Icons.label_important_outline;
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

  // MODIFIED _handleProductInteraction method's .then() block with Debug Prints
  void _handleProductInteraction(Product product) {
    debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction] Opening ProductDetailDialog for ${product.nombre}");
    showDialog<dynamic>( context: context, builder: (BuildContext dialogContext) { return ProductDetailDialog(product: product); },
    ).then((result) {
      debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction.then] Dialog closed. Result: $result");
      if (result != null && result is Map<String, dynamic>) {
        final String productName = result['productName'] ?? 'Producto';
        final int quantity = result['quantity'] ?? 0;
        // Ensure totalPrice is treated as double, even if it comes as int from JSON map in some cases
        final double totalPrice = (result['totalPrice'] as num?)?.toDouble() ?? 0.0;

        debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction.then] Item added details - Name: $productName, Qty: $quantity, Total: $totalPrice");

        if (mounted) {
          debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction.then] Showing SnackBar for item added.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName (x$quantity) agregado al carrito. Total: \$${totalPrice.toStringAsFixed(0)}'),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction.then] Widget not mounted, SnackBar not shown.");
        }
      } else {
        debugPrint("[MenuR9ZonaFrancaScreen._handleProductInteraction.then] Dialog dismissed without adding item or with unexpected result.");
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
                tabs: _tabCategories.map((String category) {
                  String keyForIcon = category.toUpperCase();
                  return Tab(
                    icon: InkResponse(
                      onTap: () {
                        // El TabBar se encarga del cambio de pestaña.
                        // Este onTap es para activar el efecto InkResponse.
                        // Si el TabBar no registra el tap en el Icon directamente,
                        // podríamos necesitar llamar a _tabController.animateTo(index) aquí,
                        // pero usualmente TabBar es suficientemente inteligente.
                      },
                      radius: 35, // Radio del efecto ripple
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Padding para área de toque
                        child: Icon(
                          _getIconForCategory(keyForIcon),
                          size: 28.0, // Tamaño del ícono aumentado (era 24 por defecto)
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // labelStyle y unselectedLabelStyle pueden ser innecesarios si solo hay íconos,
                // pero los mantengo por si afectan el espaciado/altura de la TabBar.
                // Por ahora, los mantendré por si afectan el tamaño/padding de la Tab.
                labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildLoadingSkeletonGrid() {
    int skeletonItemCount = 6;
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 200 / 320,
      ),
      itemCount: skeletonItemCount,
      itemBuilder: (context, index) {
        return const ShimmerLoading(
          isLoading: true,
          child: ProductCardSkeleton(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) { return _buildLoadingSkeletonGrid(); }
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
