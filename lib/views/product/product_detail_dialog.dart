import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../core/constants/colors.dart';

// Dummy Option Class
class _DummyOption {
  final String id;
  final String name;
  _DummyOption({required this.id, required this.name});
  @override
  bool operator ==(Object other) => identical(this, other) || other is _DummyOption && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => name;
}

class ProductDetailDialog extends StatefulWidget {
  final Product product;
  const ProductDetailDialog({super.key, required this.product});
  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _quantity = 1;
  Map<String, Set<_DummyOption>> _selectedOptionsByGroup = {};
  Map<String, List<_DummyOption>> _dummyOptionsForGroup = {};

  @override
  void initState() {
    super.initState();
    _initializeModifiers();
  }

  void _initializeModifiers() {
    _selectedOptionsByGroup = {};
    _dummyOptionsForGroup = {};
    for (var modifierGroup in widget.product.modificadores) {
      final groupKey = modifierGroup.titulo; // This is the Modifier's title, used as group title
      _selectedOptionsByGroup[groupKey] = {};

      int numberOfDummyOptions = 3;
      if (modifierGroup.cantidadMaxima == 1 && modifierGroup.cantidadMinima == 1) {
        numberOfDummyOptions = 3;
      } else if (modifierGroup.cantidadMaxima > 1) {
        numberOfDummyOptions = 4;
      }

      // **Refinement: Make dummy option names more descriptive**
      _dummyOptionsForGroup[groupKey] = List.generate(
        numberOfDummyOptions,
        // (index) => _DummyOption(id: '${groupKey}_opt${index + 1}', name: 'Opción ${index + 1}')
        (index) => _DummyOption(id: '${groupKey}_opt${index + 1}', name: '${modifierGroup.titulo} - Opción ${index + 1}')
      );

      if (modifierGroup.cantidadMinima == 1 &&
          modifierGroup.cantidadMaxima == 1 &&
          _dummyOptionsForGroup[groupKey]!.isNotEmpty) {
        _selectedOptionsByGroup[groupKey]!.add(_dummyOptionsForGroup[groupKey]!.first);
      }
    }
  }

  String _getProductImagePath(Product product) { // Renamed for clarity
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

  // New helper for agregado images
  String _getAgregadoImagePath(Agregado agregado) {
    String imageName = agregado.imagen ?? "";
    if (imageName.isEmpty) { // Fallback if no image name
      // Create a generic name, or return a path to a default placeholder
      return 'assets/images/agregados/default_agregado.jpg'; // Assuming a default placeholder
    } else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) {
      imageName += '.jpg';
    }
    return 'assets/images/agregados/$imageName';
  }

  Widget _buildModifierGroupSection(Modifier modifierGroup) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String groupKey = modifierGroup.titulo;
    final List<_DummyOption> options = _dummyOptionsForGroup[groupKey] ?? [];
    final Set<_DummyOption> selectedInThisGroup = _selectedOptionsByGroup[groupKey]!;

    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('  (No hay opciones de ejemplo para "${modifierGroup.titulo}")', style: textTheme.bodySmall)
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(modifierGroup.titulo, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(
            '(Min: ${modifierGroup.cantidadMinima}, Max: ${modifierGroup.cantidadMaxima})',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          if (modifierGroup.cantidadMaxima == 1)
            ...options.map((option) {
              return RadioListTile<_DummyOption>(
                title: Text(option.name, style: textTheme.bodyMedium),
                value: option, dense: true, contentPadding: EdgeInsets.zero,
                groupValue: selectedInThisGroup.isNotEmpty ? selectedInThisGroup.first : null,
                onChanged: (_DummyOption? value) {
                  if (value != null) {
                    setState(() { selectedInThisGroup.clear(); selectedInThisGroup.add(value); });
                  }
                },
              );
            }).toList(),
          if (modifierGroup.cantidadMaxima > 1)
            ...options.map((option) {
              return CheckboxListTile(
                title: Text(option.name, style: textTheme.bodyMedium),
                value: selectedInThisGroup.contains(option), dense: true, contentPadding: EdgeInsets.zero,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      if (selectedInThisGroup.length < modifierGroup.cantidadMaxima) {
                        selectedInThisGroup.add(option);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Máximo ${modifierGroup.cantidadMaxima} opciones para ${modifierGroup.titulo}'),
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    } else {
                      selectedInThisGroup.remove(option);
                    }
                  });
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  void _incrementQuantity() { setState(() { _quantity++; }); }
  void _decrementQuantity() { if (_quantity > 1) { setState(() { _quantity--; }); } }

  void _addToCart() {
    bool allMinMet = true;
    String validationMessage = "";
    if (widget.product.contieneModificadores) {
      for (var group in widget.product.modificadores) {
        final selectedCount = _selectedOptionsByGroup[group.titulo]?.length ?? 0;
        if (selectedCount < group.cantidadMinima) {
          allMinMet = false;
          validationMessage += 'Debes seleccionar al menos ${group.cantidadMinima} en "${group.titulo}".\n';
        }
      }
    }
    if (!allMinMet) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(validationMessage.trim(), style: const TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.error, duration: const Duration(seconds: 3),
      ));
      return;
    }
    final Map<String, dynamic> cartItem = {
      'productId': widget.product.id, 'productName': widget.product.nombre, 'quantity': _quantity,
      'basePrice': widget.product.precio, 'totalPrice': widget.product.precio * _quantity,
      'selectedModifiers': _selectedOptionsByGroup.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => { 'groupTitle': entry.key, 'options': entry.value.map((opt) => opt.name).toList(), })
          .toList(),
    };
    print("--- Adding to Cart (Placeholder) ---");
    print("Product: ${cartItem['productName']} (ID: ${cartItem['productId']})");
    print("Quantity: ${cartItem['quantity']}");
    print("Base Price: \$${cartItem['basePrice']}");
    print("Total Price: \$${cartItem['totalPrice']}");
    if ((cartItem['selectedModifiers'] as List).isNotEmpty) {
      print("Selected Modifiers:");
      for (var modGroup in cartItem['selectedModifiers']) {
        print("  ${modGroup['groupTitle']}: ${modGroup['options'].join(', ')}");
      }
    } else { print("Selected Modifiers: None"); }
    print("------------------------------------");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${cartItem['productName']} (x$_quantity) agregado al carrito (simulación).'),
      backgroundColor: AppColors.success.withOpacity(0.9), duration: const Duration(seconds: 3),
    ));
    Navigator.of(context).pop(cartItem);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = _getProductImagePath(widget.product); // Updated call

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
                  Text('\$${widget.product.precio.toStringAsFixed(0)}', style: textTheme.titleLarge?.copyWith(color: colorScheme.secondary)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.product.contieneModificadores && widget.product.modificadores.isNotEmpty)
                      ...widget.product.modificadores.map((group) => _buildModifierGroupSection(group)).toList()
                    else if (widget.product.contieneModificadores)
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 16.0),
                         child: Text("Este producto tiene modificadores, pero no se han cargado opciones.", style: textTheme.bodyMedium),
                       )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("Este producto no tiene modificadores.", style: textTheme.bodyMedium),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Cantidad:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textMuted.withOpacity(0.5), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _decrementQuantity, color: AppColors.primaryRed, iconSize: 28, splashRadius: 24,),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('$_quantity', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _incrementQuantity, color: AppColors.primaryRed, iconSize: 28, splashRadius: 24,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                onPressed: _addToCart,
                child: Text('Agregar al Carrito', style: textTheme.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
