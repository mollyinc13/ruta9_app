import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../core/constants/colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddButtonPressed;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddButtonPressed,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  String _getImagePath(Product product) {
    String imageName = product.imagen ?? "";
    if (imageName.isEmpty) {
      imageName = '${product.id.toLowerCase().replaceAll(' ', '_')}.jpg';
    } else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) {
      imageName += '.jpg';
    }
    String categoryPath = product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general';
    String basePath = 'assets/images/products/';
    if (categoryPath.contains('burger')) {
      basePath += 'burgers/';
    } else if (categoryPath.contains('sandwich')) {
      basePath += 'sandwiches/';
    } else if (categoryPath.contains('combo')) {
      basePath += 'combos/';
    } else if (categoryPath.contains('snack') || categoryPath.contains('acompañamiento')) {
      basePath += 'snacks/';
    } else if (categoryPath.contains('bebida')) {
      basePath += 'bebidas/';
    } else {
      basePath += 'general/';
    }
    return '$basePath$imageName';
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    print('Favorite toggled for ${widget.product.id}: $_isFavorite (UI only)');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[ProductCard build] Product: ${widget.product.id}, onAddButtonPressed is ${widget.onAddButtonPressed == null ? 'NULL' : 'NOT NULL'}");

    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = _getImagePath(widget.product);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          alignment: Alignment.center,
                          color: AppColors.surfaceDark.withOpacity(0.8),
                          child: Icon(
                            Icons.fastfood,
                            color: AppColors.textMuted.withOpacity(0.6),
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.backgroundDark.withOpacity(0.4),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? colorScheme.primary : AppColors.textLight.withOpacity(0.9),
                      ),
                      iconSize: 24,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      tooltip: _isFavorite ? 'Quitar de Favoritos' : 'Agregar a Favoritos',
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.nombre,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${widget.product.precio.toStringAsFixed(0)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("[ProductCard ElevatedButton] RAW TAP DETECTED for ${widget.product.id}");
                      widget.onAddButtonPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
                    ),
                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
