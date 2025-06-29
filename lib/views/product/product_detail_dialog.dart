// lib/views/product/product_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/agregado_model.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants/colors.dart';
import '../../widgets/tap_scale_wrapper.dart';

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

  String _getAgregadoImagePath(Agregado agregado) {
    String imageName = agregado.imagen ?? "";
    if (imageName.isEmpty) { return 'assets/images/agregados/default_agregado.jpg'; }
    else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) { imageName += '.jpg';}
    return 'assets/images/agregados/$imageName';
  }

  void _incrementQuantity() { setState(() { _quantity++; }); }
  void _decrementQuantity() { if (_quantity > 1) { setState(() { _quantity--; }); } }

  double _calculateTotalPrice() {
    double total = widget.product.precio;
    for (var agregado in _selectedAgregados) { total += agregado.precio; }
    return total * _quantity;
  }

  // MODIFIED _addToCart method with Debug Prints
  void _addToCart() {
    debugPrint("[ProductDetailDialog._addToCart] Entered _addToCart method.");
    debugPrint("[ProductDetailDialog._addToCart] Product: ${widget.product.nombre}, ID: ${widget.product.id}");
    debugPrint("[ProductDetailDialog._addToCart] Quantity: $_quantity");
    debugPrint("[ProductDetailDialog._addToCart] Selected Agregados: ${_selectedAgregados.map((ag) => ag.nombre).join(', ')}");

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final double finalPrice = _calculateTotalPrice();

    debugPrint("[ProductDetailDialog._addToCart] Calculated finalPrice for pop: $finalPrice");
    debugPrint("[ProductDetailDialog._addToCart] Calling cartProvider.addItem()...");

    try {
      cartProvider.addItem(
        product: widget.product,
        quantity: _quantity,
        selectedAgregados: _selectedAgregados.toList(),
      );
      debugPrint("[ProductDetailDialog._addToCart] cartProvider.addItem() call completed.");
    } catch (e) {
      debugPrint("[ProductDetailDialog._addToCart] ERROR during cartProvider.addItem(): $e");
      // Optionally, show an error SnackBar here too if addItem can throw
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al añadir al carro: $e')));
    }

    final Map<String, dynamic> popResult = {
      'productName': widget.product.nombre,
      'quantity': _quantity,
      'totalPrice': finalPrice
    };
    debugPrint("[ProductDetailDialog._addToCart] Popping with result: $popResult");
    Navigator.of(context).pop(popResult);
    debugPrint("[ProductDetailDialog._addToCart] Exited _addToCart method after pop.");
  }

  Widget _buildAgregadosList() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context);
    if (!widget.product.contieneModificadores) { return Padding( padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), child: Text("Este producto no tiene agregados.", style: textTheme.bodyMedium),); }
    if (widget.product.agregados.isEmpty) { return Padding( padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), child: Text("Este producto puede tener agregados, pero no hay ninguno definido.", style: textTheme.bodyMedium),); }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding( padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0), child: Text( "Agregados Disponibles:", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), ),),
        ListView.separated( shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: widget.product.agregados.length,
          itemBuilder: (context, index) {
            final agregado = widget.product.agregados[index];
            bool isSelected = _selectedAgregados.contains(agregado);
            return CheckboxListTile(
              title: Text(agregado.nombre, style: textTheme.titleMedium),
              subtitle: Text('+ \$${agregado.precio.toStringAsFixed(0)}', style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),),
              value: isSelected,
              onChanged: (bool? selected) { setState(() { if (selected == true) { _selectedAgregados.add(agregado); } else { _selectedAgregados.remove(agregado); } }); },
              secondary: ClipRRect( borderRadius: BorderRadius.circular(8.0), child: SizedBox( width: 50, height: 50, child: Image.asset( _getAgregadoImagePath(agregado), fit: BoxFit.cover, errorBuilder: (ctx, err, st) => Container( alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.3), child: Icon(Icons.restaurant_menu, color: AppColors.textMuted.withOpacity(0.5), size: 24), ),),),),
              controlAffinity: ListTileControlAffinity.leading, activeColor: theme.colorScheme.primary, contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0), );
          },
          separatorBuilder: (context, index) => Divider( height: 1, indent: 16, endIndent: 16, color: AppColors.surfaceDark.withOpacity(0.7),),
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
    final DialogThemeData dialogTheme = Theme.of(context).dialogTheme;
    final BorderRadius dialogBorderRadius = (dialogTheme.shape is RoundedRectangleBorder) ? (dialogTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius : BorderRadius.circular(12.0);

    return Dialog(
      shape: dialogTheme.shape,
      backgroundColor: dialogTheme.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ClipRRect(
        borderRadius: dialogBorderRadius,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Hero(
                  //   tag: 'hero_product_image_${widget.product.id}',
                  ClipRRect(
                      borderRadius: BorderRadius.only( topLeft: dialogBorderRadius.topLeft, topRight: dialogBorderRadius.topRight,),
                      child: SizedBox(
                        height: 180,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            alignment: Alignment.center,
                            color: AppColors.surfaceDark.withOpacity(0.5),
                            child: Icon(Icons.fastfood, color: AppColors.textMuted, size: 60),
                          ),
                        ),
                      ),
                    ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.nombre, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('\$${currentTotalPrice.toStringAsFixed(0)}', style: textTheme.headlineMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (widget.product.descripcion != null && widget.product.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(widget.product.descripcion!, style: textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                  Expanded( child: SingleChildScrollView( child: _buildAgregadosList(),),),
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
                          ],),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: TapScaleWrapper(
                      onPressed: _addToCart, // TapScaleWrapper maneja la acción y la animación
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
                          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                          shape: Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({}),
                          elevation: Theme.of(context).elevatedButtonTheme.style?.elevation?.resolve({})
                        ),
                        onPressed: null, // El ElevatedButton solo define la apariencia, el TapScaleWrapper maneja el tap.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Agregar \$${currentTotalPrice.toStringAsFixed(0)}',
                            style: textTheme.labelLarge?.copyWith(fontSize: 15)
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () { Navigator.of(context).pop(); },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textLight.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
