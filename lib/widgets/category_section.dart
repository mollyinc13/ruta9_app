// lib/widgets/category_section.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<Product> products;
  final Function(Product product) onProductSelected;
  final Function(Product product) onProductAdded;
  final IconData? icon; // New optional icon parameter

  const CategorySection({
    super.key,
    required this.categoryTitle,
    required this.products,
    required this.onProductSelected,
    required this.onProductAdded,
    this.icon, // Initialize new icon parameter
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color? iconColor = textTheme.headlineSmall?.color?.withOpacity(0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
          child: Row( // Use Row to place icon next to title
            children: [
              if (icon != null) // Conditionally display icon
                Icon(icon, size: textTheme.headlineSmall?.fontSize, color: iconColor),
              if (icon != null) // Conditionally display spacing
                const SizedBox(width: 8.0),
              Expanded( // Title takes remaining space
                child: Text(
                  categoryTitle,
                  style: textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis, // Handle long titles
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12.0),
                child: ProductCard(
                  product: product,
                  onTap: () => onProductSelected(product),
                  onAddButtonPressed: () => onProductAdded(product),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
