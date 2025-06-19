import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/agregado_model.dart';
import '../../core/constants/colors.dart'; // Kept for AppColors if used directly (e.g. placeholder)

class ProductDetailDialog extends StatefulWidget {
  final Product product;
  const ProductDetailDialog({super.key, required this.product});

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _quantity = 1;
  Set<Agregado> _selectedAgregados = {};

  @override
  void initState() {
    super.initState();
    _selectedAgregados = {};
  }

  String _getProductImagePath(Product product) {
    String imageName = product.imagen ?? "";
    if (imageName.isEmpty) {
      imageName = '${product.id.toLowerCase().replaceAll(' ', '_')}.jpg';
    } else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) {
      imageName += '.jpg';
    }
    String categoryPath = product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general';
    String basePath = 'assets/images/products/';
    if (categoryPath.contains('burger')) { basePath += 'burgers/'; }
    else if (categoryPath.contains('sandwich')) { basePath += 'sandwiches/'; }
    else if (categoryPath.contains('snack') || categoryPath.contains('acompañamiento')) { basePath += 'snacks/'; }
    else if (categoryPath.contains('bebida')) { basePath += 'bebidas/'; }
    else { basePath += 'general/'; }
    return '$basePath$imageName';
  }

  String _getAgregadoImagePath(Agregado agregado) {
    String imageName = agregado.imagen ?? "";
    if (imageName.isEmpty) {
      return 'assets/images/agregados/default_agregado.jpg';
    } else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) {
      imageName += '.jpg';
    }
    return 'assets/images/agregados/$imageName';
  }

  void _incrementQuantity() { setState(() { _quantity++; }); }
  void _decrementQuantity() { if (_quantity > 1) { setState(() { _quantity--; }); } }

  double _calculateTotalPrice() {
    double total = widget.product.precio;
    for (var agregado in _selectedAgregados) {
      total += agregado.precio;
    }
    return total * _quantity;
  }

  void _addToCart() {
    final Map<String, dynamic> cartItem = {
      'productId': widget.product.id,
      'productName': widget.product.nombre,
      'quantity': _quantity,
      'basePrice': widget.product.precio,
      'totalPrice': _calculateTotalPrice(),
      'selectedAgregados': _selectedAgregados
          .map((ag) => {'nombre': ag.nombre, 'precio': ag.precio, 'imagen': ag.imagen})
          .toList(),
    };
    print("--- Adding to Cart ---");
    print("Product: ${cartItem['productName']} (ID: ${cartItem['productId']})");
    print("Quantity: ${cartItem['quantity']}");
    print("Base Price: \$${cartItem['basePrice']}");
    print("Selected Agregados:");
    for(var ag in cartItem['selectedAgregados']){
      print("  - ${ag['nombre']} (\$${ag['precio']})");
    }
    print("Total Price: \$${cartItem['totalPrice']}");
    print("------------------------------------");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${cartItem['productName']} (x$_quantity) agregado al carrito.'),
      backgroundColor: AppColors.success.withOpacity(0.9), // Consider using Theme.of(context).colorScheme.primary for theme consistency
      duration: const Duration(seconds: 3),
    ));
    Navigator.of(context).pop(cartItem);
  }

  Widget _buildAgregadosList() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context); // For accessing theme properties easily

    if (!widget.product.contieneModificadores) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Added horizontal padding
        child: Text("Este producto no tiene agregados.", style: textTheme.bodyMedium),
      );
    }
    if (widget.product.agregados.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Added horizontal padding
        child: Text("Este producto puede tener agregados, pero no hay ninguno definido.", style: textTheme.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Use symmetric padding for the title of the section
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            "Agregados Disponibles:",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), // Slightly larger title
          ),
        ),
        ListView.separated( // Using ListView.separated for better spacing and dividers
          shrinkWrap: true, // Important for ListView inside SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // ListView itself shouldn't scroll here
          itemCount: widget.product.agregados.length,
          itemBuilder: (context, index) {
            final agregado = widget.product.agregados[index];
            bool isSelected = _selectedAgregados.contains(agregado);
            return CheckboxListTile(
              title: Text(agregado.nombre, style: textTheme.titleMedium), // Slightly larger
              subtitle: Text(
                '+ \$${agregado.precio.toStringAsFixed(0)}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedAgregados.add(agregado);
                  } else {
                    _selectedAgregados.remove(agregado);
                  }
                });
              },
              secondary: ClipRRect( // Clip the agregado image
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 50, height: 50,
                  child: Image.asset(
                    _getAgregadoImagePath(agregado),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.3),
                      child: Icon(Icons.restaurant_menu, color: AppColors.textMuted.withOpacity(0.5), size: 24), // Changed icon
                    ),
                  ),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: theme.colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0), // Adjusted padding
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.surfaceDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = _getProductImagePath(widget.product);
    final double currentTotalPrice = _calculateTotalPrice();
    // Get dialog shape from theme for consistent corner rounding
    final DialogTheme dialogTheme = Theme.of(context).dialogTheme;
    final BorderRadius dialogBorderRadius = (dialogTheme.shape is RoundedRectangleBorder)
        ? (dialogTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius
        : BorderRadius.circular(12.0); // Default if not RoundedRectangleBorder

    return Dialog(
      shape: dialogTheme.shape, // Use theme's shape
      backgroundColor: dialogTheme.backgroundColor, // Use theme's background
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Slightly less horizontal
      child: ClipRRect( // Clip the entire dialog content to its shape
        borderRadius: dialogBorderRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect( // Apply rounding to top of the image
                borderRadius: BorderRadius.only(
                  topLeft: dialogBorderRadius.topLeft,
                  topRight: dialogBorderRadius.topRight,
                ),
                child: SizedBox(
                  height: 180, // Slightly taller image
                  child: Image.asset(
                    imagePath, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.5),
                      child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 60), // Larger icon
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0), // Adjusted padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.nombre, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), // Bolder name
                    const SizedBox(height: 6),
                    Text('\$${currentTotalPrice.toStringAsFixed(0)}',
                         style: textTheme.headlineMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)), // Larger price
                  ],
                ),
              ),
              if (widget.product.descripcion != null && widget.product.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(widget.product.descripcion!, style: textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis), // Increased maxLines
                ),

              Expanded(
                child: SingleChildScrollView(
                  // Removed horizontal padding here, as _buildAgregadosList handles it internally for its content
                  child: _buildAgregadosList(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cantidad:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.textMuted.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(8),),
                      child: Row(children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _decrementQuantity, color: AppColors.primaryRed, iconSize: 28, splashRadius: 24,),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('$_quantity', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),
                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _incrementQuantity, color: AppColors.primaryRed, iconSize: 28, splashRadius: 24,),
                        ],),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                  onPressed: _addToCart,
                  child: Text('Agregar \$${currentTotalPrice.toStringAsFixed(0)}', style: textTheme.labelLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
