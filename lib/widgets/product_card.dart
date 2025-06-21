import 'package:flutter/material.dart';
import '../models/product_model.dart';
// AppColors is not strictly needed if all colors come from theme, but kept for consistency if used by placeholder
import '../core/constants/colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddButtonPressed;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddButtonPressed,
    this.onTap,
  });

  String _getImagePath(Product product) {
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
    else if (categoryPath.contains('combo')) { basePath += 'combos/'; } // Added for COMBOS
    else if (categoryPath.contains('snack') || categoryPath.contains('acompañamiento')) { basePath += 'snacks/'; }
    else if (categoryPath.contains('bebida')) { basePath += 'bebidas/'; }
    else { basePath += 'general/'; }
    return '$basePath$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // CardTheme is applied by the global theme.
    // final CardTheme cardTheme = Theme.of(context).cardTheme;

    final String imagePath = _getImagePath(product);

    return Card(
      // Using properties from AppTheme.cardTheme by default
      // Consider specifying margin here if CategorySection doesn't provide enough spacing
      // margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0), // Example if needed
      clipBehavior: Clip.antiAlias, // Ensures content respects card's rounded corners
      child: InkWell(
        onTap: onTap,
        // borderRadius: BorderRadius.circular(12.0), // Already handled by Card's shape if InkWell is direct child
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Product Image
            Expanded(
              flex: 3,
              child: Hero( // MODIFIED: Added Hero widget
                tag: 'hero_product_image_${product.id}', // Unique tag per product
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
            ),
            // Product Details
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
                        Text(
                          product.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.precio.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAddButtonPressed,
                        child: const Text('Agregar'),
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
