// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/constants/colors.dart';
import 'tap_scale_wrapper.dart'; // Assuming TapScaleWrapper is available for button animation

// Changed to StatefulWidget to manage favorite state locally
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
  bool _isFavorite = false; // Local state for favorite toggle

  String _getImagePath(Product product) {
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

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    print('Favorite toggled for ${widget.product.id}: $_isFavorite (UI only)');
    // In a real app, this would also call a provider/service to update backend/local persistence
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = _getImagePath(widget.product);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Stack( // Use Stack to overlay favorite button on image
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'hero_product_image_${widget.product.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container( alignment: Alignment.center, color: AppColors.surfaceDark.withOpacity(0.8), child: Icon( Icons.fastfood, color: AppColors.textMuted.withOpacity(0.6), size: 40, ), );
                           },
                        ),
                      ),
                    ),
                  ),
                  Positioned( // Favorite button
                    top: 8,
                    right: 8,
                    child: Material( // Material for InkWell splash and shape
                      color: AppColors.backgroundDark.withOpacity(0.4),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? colorScheme.primary : AppColors.textLight.withOpacity(0.9),
                        ),
                        iconSize: 24, // Adjust size as needed
                        padding: const EdgeInsets.all(6), // Adjust padding for touch area
                        constraints: const BoxConstraints(), // Remove default IconButton padding
                        tooltip: _isFavorite ? 'Quitar de Favoritos' : 'Agregar a Favoritos',
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text( widget.product.nombre, style: textTheme.titleMedium?.copyWith( fontWeight: FontWeight.bold,), maxLines: 2, overflow: TextOverflow.ellipsis, ),
                        const SizedBox(height: 4),
                        Text( '\$${widget.product.precio.toStringAsFixed(0)}', style: textTheme.titleMedium?.copyWith( color: colorScheme.secondary, fontWeight: FontWeight.bold, ), ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TapScaleWrapper(
                        onPressed: widget.onAddButtonPressed,
                        child: ElevatedButton(
                          onPressed: () {}, // Dummy, handled by wrapper
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: const Text('Agregar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
