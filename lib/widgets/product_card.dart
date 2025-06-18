import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/constants/colors.dart'; // For direct color usage if needed outside theme

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddButtonPressed; // Callback for the "Add" button
  final VoidCallback? onTap; // Callback for tapping the card itself

  const ProductCard({
    super.key,
    required this.product,
    this.onAddButtonPressed,
    this.onTap,
  });

  // Basic function to generate an image path.
  // This will likely need refinement based on actual image naming conventions.
  String _getImagePath(Product product) {
    String imageName = product.imagen ?? ""; // Use product.imagen if available
    if (imageName.isEmpty) { // Fallback if product.imagen is null or empty
      imageName = '${product.id.toLowerCase().replaceAll(' ', '_')}.jpg';
    } else if (!imageName.toLowerCase().endsWith('.jpg') && !imageName.toLowerCase().endsWith('.png')) {
      // If product.imagen is present but without extension, assume .jpg
      imageName += '.jpg';
    }

    // Determine base path by subcategory
    String categoryPath = product.subcategoria?.toLowerCase().replaceAll(' ', '_') ?? 'general';
    String basePath = 'assets/images/products/';

    if (categoryPath.contains('burger')) { // Changed from 'hamburguesa' to 'burger' to match new CSV
        basePath += 'burgers/';
    } else if (categoryPath.contains('sandwich')) {
        basePath += 'sandwiches/';
    } else if (categoryPath.contains('snack') || categoryPath.contains('acompañamiento')) {
        basePath += 'snacks/';
    } else if (categoryPath.contains('bebida')) { // For 'Bebidas'
        basePath += 'bebidas/'; // Assuming a 'bebidas' folder might exist or be created
    } else {
        basePath += 'general/';
    }
    return '$basePath$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Attempt to load image, fallback to placeholder
    // Note: For asset images to be resolved correctly, they need to be listed in pubspec.yaml
    // or the specific subdirectories like 'assets/images/products/burgers/' must be listed.
    // The current pubspec.yaml lists the subdirectories.
    final String imagePath = _getImagePath(product);

    ImageProvider productImage = AssetImage(imagePath);
    // Using an Image.asset with errorBuilder to handle missing images

    return Card(
      // CardTheme is applied globally, but can override here if needed
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      // elevation: 4,
      // margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap, // Allow tapping the whole card
        borderRadius: BorderRadius.circular(12.0), // Match card shape
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Product Image
            Expanded(
              flex: 3, // Give more space to image
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  color: AppColors.surfaceDark.withOpacity(0.5), // Placeholder bg
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback placeholder if image fails to load
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.grey[700], // Darker placeholder background
                      child: Icon(
                        Icons.fastfood, // Placeholder icon
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 2, // Space for text and button
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push button to bottom
                  children: <Widget>[
                    // Name
                    Text(
                      product.nombre,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Price
                    Text(
                      '\$${product.precio.toStringAsFixed(0)}', // Format price
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.secondary, // Use secondary color (yellow) for price
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Add Button
                    SizedBox(
                      width: double.infinity, // Make button take full width of padding
                      child: ElevatedButton(
                        onPressed: onAddButtonPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ).copyWith(
                           backgroundColor: MaterialStateProperty.all(AppColors.primaryRed),
                           shape: MaterialStateProperty.all(
                               RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                           )
                        ),
                        child: Text(
                          'Agregar',
                          style: textTheme.labelLarge?.copyWith(fontSize: 14),
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
