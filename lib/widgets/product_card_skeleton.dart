// lib/widgets/product_card_skeleton.dart
import 'package:flutter/material.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Use theme colors for skeleton elements if available, or default greys
    final Color baseColor = Colors.grey[800]!; // Matching ShimmerLoading base for non-shimmer parts
    final Color highlightColor = Colors.grey[700]!; // Not directly used here, but for consistency

    return Card(
      // Use CardTheme from AppTheme (includes shape, elevation, margin if defined)
      // Ensure margin is consistent with ProductCard if it's applied by CategorySection/GridView spacing
      // clipBehavior: Clip.antiAlias, // Good practice
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Image Placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor, // Placeholder color for image area
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0), // Match ProductCard's image ClipRRect
                  topRight: Radius.circular(12.0),
                ),
              ),
            ),
          ),
          // Text Placeholders
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Match ProductCard's padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container( // Placeholder for Product Name
                        width: double.infinity,
                        height: 16.0, // Approx height for titleMedium
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 8.0), // Increased spacing
                      Container( // Placeholder for Price
                        width: 100.0, // Shorter width for price
                        height: 14.0, // Approx height for titleMedium (was titleSmall before)
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container( // Placeholder for Button
                    width: double.infinity,
                    height: 40.0, // Approx height for ElevatedButton
                    decoration: BoxDecoration(
                      color: baseColor, // Or a slightly different shade to mimic button
                      borderRadius: BorderRadius.circular(8.0), // Match button shape
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
