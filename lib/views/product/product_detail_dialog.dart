import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/agregado_model.dart';
import '../../core/constants/colors.dart';

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

  void _addToCart() {
    final Map<String, dynamic> cartItem = {
      'productId': widget.product.id,
      'productName': widget.product.nombre,
      'quantity': _quantity,
      'basePrice': widget.product.precio,
      'totalPrice': _calculateTotalPrice(), // Updated to use new method
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
      backgroundColor: AppColors.success.withOpacity(0.9),
      duration: const Duration(seconds: 3),
    ));
    Navigator.of(context).pop(cartItem);
  }

  // Method to calculate total price including selected agregados
  double _calculateTotalPrice() {
    double total = widget.product.precio;
    for (var agregado in _selectedAgregados) {
      total += agregado.precio;
    }
    return total * _quantity;
  }

  // --- Widget to build the Agregados Selection List ---
  Widget _buildAgregadosList() {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (!widget.product.contieneModificadores) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text("Este producto no tiene agregados.", style: textTheme.bodyMedium),
      );
    }
    if (widget.product.agregados.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text("Este producto puede tener agregados, pero no hay ninguno definido.", style: textTheme.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            "Agregados Disponibles:",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...widget.product.agregados.map((agregado) {
          bool isSelected = _selectedAgregados.contains(agregado);
          return CheckboxListTile(
            title: Text(agregado.nombre, style: textTheme.bodyLarge),
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
                // Price will be updated via _calculateTotalPrice in the build method for price display
              });
            },
            secondary: SizedBox( // For Agregado Image
              width: 50, height: 50,
              child: Image.asset(
                _getAgregadoImagePath(agregado),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.3),
                  child: Icon(Icons.fastfood, color: AppColors.textMuted.withOpacity(0.5), size: 24),
                ),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
            activeColor: Theme.of(context).colorScheme.primary,
            dense: false, // Make it a bit more spacious
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
          );
        }).toList(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = _getProductImagePath(widget.product);
    final double currentTotalPrice = _calculateTotalPrice(); // Calculate total price for display

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Image.asset(
                imagePath, fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.5),
                  child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.nombre, style: textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  // Display dynamic total price
                  Text('\$${currentTotalPrice.toStringAsFixed(0)}',
                       style: textTheme.titleLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (widget.product.descripcion != null && widget.product.descripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0,0,16.0,8.0),
                child: Text(widget.product.descripcion!, style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildAgregadosList(), // Call the new method here
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Cantidad:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Container( // Quantity controls remain the same
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
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                onPressed: _addToCart,
                child: Text('Agregar \$${currentTotalPrice.toStringAsFixed(0)}', style: textTheme.labelLarge), // Update button text with total price
              ),
            ),
          ],
        ),
      ),
    );
  }
}
