import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart'; // Assuming ProductCard is in the same directory

class CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<Product> products;
  final Function(Product product) onProductSelected; // Callback when a product card is tapped
  final Function(Product product) onProductAdded;   // Callback for "Add" button on product card

  const CategorySection({
    super.key,
    required this.categoryTitle,
    required this.products,
    required this.onProductSelected,
    required this.onProductAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      // Optionally, display something else if there are no products in this category
      // return SizedBox.shrink();
      // Or a message, but for now, if it's empty, it just won't show product cards.
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            categoryTitle,
            style: textTheme.headlineSmall, // Using headlineSmall from the theme
          ),
        ),
        SizedBox(
          height: 320, // Fixed height for the horizontal list. Adjust as needed.
                       // This height needs to accommodate ProductCard's dimensions.
                       // ProductCard has Expanded Image (flex 3) and Details (flex 2)
                       // Consider the typical card width for aspect ratio.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding for the first/last items
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 200, // Fixed width for each ProductCard in the list. Adjust as needed.
                margin: const EdgeInsets.symmetric(horizontal: 4.0), // Spacing between cards
                child: ProductCard(
                  product: product,
                  onTap: () => onProductSelected(product),
                  onAddButtonPressed: () => onProductAdded(product),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16), // Spacing after the category section
      ],
    );
  }
}
