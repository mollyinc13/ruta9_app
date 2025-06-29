import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Para CartProvider
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../views/product/product_detail_dialog.dart'; // Asumiendo que se reutilizará o adaptará
import '../widgets/product_card.dart'; // Asumiendo que se reutilizará o adaptará
import '../core/constants/colors.dart'; // Para colores consistentes
import 'package:collection/collection.dart'; // For groupBy
import '../views/cart/cart_screen.dart'; // Added import for CartScreen

class TotemKioskScreen extends StatefulWidget {
  const TotemKioskScreen({super.key});

  @override
  State<TotemKioskScreen> createState() => _TotemKioskScreenState();
}

class _TotemKioskScreenState extends State<TotemKioskScreen> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  List<Product> _allKioskProducts = [];
  Map<String, List<Product>> _productsByCategory = {};
  List<String> _tabCategories = [];
  TabController? _tabController;
  bool _isLoading = true;
  String? _error;

  // Íconos para categorías (similar a MenuR9ZonaFrancaScreen)
  final Map<String, IconData> _categoryIcons = {
    'BURGER': Icons.lunch_dining,
    'SANDWICH': Icons.breakfast_dining,
    'SNACK': Icons.fastfood,
    'BEBIDA': Icons.local_drink,
    'ACOMPAÑAMIENTOS': Icons.fastfood,
    'COMBOS': Icons.takeout_dining,
    'OTROS': Icons.category,
    'TODOS': Icons.apps
  };

  IconData _getIconForCategory(String categoryName) {
    return _categoryIcons[categoryName.toUpperCase()] ?? Icons.label_important_outline;
  }

  @override
  void initState() {
    super.initState();
    _enterKioskMode();
    _loadProducts();
  }

  @override
  void dispose() {
    _leaveKioskMode();
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  void _enterKioskMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // O la orientación deseada para el kiosco, ej. landscape
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
  }

  void _leaveKioskMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values); // Restaurar todas las orientaciones
  }

  Future<void> _loadProducts() async {
    // Lógica similar a MenuR9ZonaFrancaScreen para cargar productos
    // Filtrar por zonaFranca o un nuevo campo si es necesario para el kiosco
    setState(() { _isLoading = true; _error = null; });
    try {
      final allProducts = await _productService.getProducts();
      if (!mounted) return;

      // TODO: Decidir si el kiosco usa productos de 'zonaFranca' u otra lógica
      _allKioskProducts = allProducts.where((p) => p.zonaFranca == true).toList();

      if (_allKioskProducts.isEmpty) {
        setState(() { _isLoading = false; _error = 'No hay productos disponibles para el kiosco.'; });
        _setupTabController([]);
        return;
      }

      _productsByCategory = groupBy(_allKioskProducts, (Product p) => p.subcategoria ?? 'OTROS');
      List<String> uniqueCategories = _productsByCategory.keys.toList();
      uniqueCategories.sort(); // O un orden personalizado
      _tabCategories = ["TODOS", ...uniqueCategories];
      _setupTabController(uniqueCategories);
      setState(() { _isLoading = false; });
    } catch (e) {
      if (mounted) { setState(() { _error = 'Error al cargar productos: ${e.toString()}'; _isLoading = false; });}
      _setupTabController([]);
    }
  }

  void _setupTabController(List<String> categories) {
    if (!mounted) return;
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _tabController = TabController(length: _tabCategories.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    // Forzar actualización si el tabController se recrea con el mismo length
    if (mounted) setState(() {});
  }

  void _handleTabSelection() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      if (mounted) {
        setState(() {}); // Para reconstruir si es necesario al cambiar de tab
      }
    }
  }

  void _handleProductInteraction(Product product, BuildContext currentContext) {
    final cart = Provider.of<CartProvider>(currentContext, listen: false);
    // Adaptar ProductDetailDialog o crear uno nuevo para Kiosco si es necesario
    // Por ahora, asumimos que podemos reusar ProductDetailDialog
    // y que la lógica de agregar al carrito es similar.
    showDialog<dynamic>(
      context: currentContext, // Usar el BuildContext del builder del ProductCard
      builder: (BuildContext dialogContext) {
        return ProductDetailDialog(product: product);
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic> && mounted) {
        final String productName = result['productName'] ?? 'Producto';
        final int quantity = result['quantity'] ?? 0;
        final double totalPrice = (result['totalPrice'] as num?)?.toDouble() ?? 0.0;

        // Confirmación visual más grande para kiosco
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('$productName (x$quantity) agregado. Total: \$${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
            backgroundColor: Theme.of(currentContext).colorScheme.secondary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // Impedir salir con botón "atrás"
      child: Scaffold(
        backgroundColor: AppColors.primaryDark, // Fondo oscuro
        body: SafeArea( // SafeArea para no interferir con áreas de sistema (aunque en immersive puede no aplicar igual)
          child: _buildKioskBody(),
        ),
        bottomNavigationBar: _buildConfirmOrderButton(),
      ),
    );
  }

  Widget _buildKioskBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 18), textAlign: TextAlign.center));
    }
    if (_allKioskProducts.isEmpty || _tabController == null || _tabController!.length == 0) {
      return const Center(child: Text('No hay productos para mostrar.', style: TextStyle(fontSize: 18, color: AppColors.textLight)));
    }

    return Column(
      children: [
        // TabBar más grande para Kiosco
        Container(
          color: AppColors.backgroundDark, // Color de fondo para la TabBar
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primaryYellow,
            indicatorWeight: 3.0,
            tabs: _tabCategories.map((String category) {
              String keyForIcon = category.toUpperCase();
              bool isSelected = _tabCategories[_tabController!.index].toUpperCase() == keyForIcon;
              return Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForCategory(keyForIcon),
                        size: 32.0, // Iconos más grandes
                        color: isSelected ? AppColors.primaryYellow : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14, // Texto de categoría más legible
                           color: isSelected ? AppColors.primaryYellow : AppColors.textMuted,
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabCategories.map((String category) {
              final productsToShow = (category == "TODOS")
                  ? _allKioskProducts
                  : (_productsByCategory[category] ?? []);
              if (productsToShow.isEmpty) {
                return Center(child: Text('No hay productos en ${category.toUpperCase()}', style: const TextStyle(fontSize: 18, color: AppColors.textLight)));
              }
              // Usar GridView con ProductCards adaptados para Kiosco
              return GridView.builder(
                key: PageStorageKey(category), // Para mantener posición de scroll
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Ajustar según tamaño de pantalla del kiosco
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Ajustar para imágenes más grandes
                ),
                itemCount: productsToShow.length,
                itemBuilder: (context, index) {
                  final product = productsToShow[index];
                  // Necesitaríamos un KioskProductCard o adaptar ProductCard
                  return KioskProductCard(
                    product: product,
                    onAddButtonPressed: () {
                       // Pasar el BuildContext del Card para el SnackBar
                      _handleProductInteraction(product, context);
                    }
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmOrderButton() {
    final cart = context.watch<CartProvider>(); // Para habilitar/deshabilitar y mostrar total
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.backgroundDark, // Fondo consistente
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.black,
          minimumSize: const Size(double.infinity, 60), // Botón grande
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: cart.items.isEmpty ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
        child: Text('Ver Carrito y Pagar (${cart.itemCount} items) - \$${cart.totalPrice.toStringAsFixed(0)}'),
      ),
    );
  }
}

// Widget KioskProductCard (adaptación de ProductCard)
class KioskProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddButtonPressed;

  const KioskProductCard({
    super.key,
    required this.product,
    required this.onAddButtonPressed,
  });

  String _getProductImagePath(Product product) {
    String imageName = product.imagen ?? "";
    if (imageName.isEmpty) { imageName = '${product.id.toLowerCase().replaceAll(' ', '_')}.jpg';}
    else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) { imageName += '.jpg';}
    String categoryPath = product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general';
    String basePath = 'assets/images/products/';
    if (categoryPath.contains('burger')) { basePath += 'burgers/'; }
    else if (categoryPath.contains('sandwich')) { basePath += 'sandwiches/'; }
    else if (categoryPath.contains('combo')) { basePath += 'combos/'; }
    else if (categoryPath.contains('snack') || categoryPath.contains('acompañamiento')) { basePath += 'snacks/'; }
    else if (categoryPath.contains('bebida')) { basePath += 'bebidas/'; }
    else { basePath += 'general/'; }
    return '$basePath$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias, // Para que la imagen respete el borde redondeado
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3, // Más espacio para la imagen
            child: Image.asset(
              _getProductImagePath(product),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                alignment: Alignment.center,
                color: AppColors.surfaceDark.withOpacity(0.5),
                child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 60),
              ),
            ),
          ),
          Expanded(
            flex: 2, // Espacio para texto y botón
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    product.nombre,
                    style: textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold), // Fuente más grande
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${product.precio.toStringAsFixed(0)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Precio más visible
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('AGREGAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12.0), // Botón más alto
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: onAddButtonPressed,
            ),
          ),
        ],
      ),
    );
  }
}
