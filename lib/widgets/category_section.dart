import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<Product> products;
  final Function(Product product) onProductSelected;
  final Function(Product product) onProductAdded;

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
      return const SizedBox.shrink(); // Return an empty box if no products, to not take up title space
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          // Adjusted vertical padding for title
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
          child: Text(
            categoryTitle,
            style: textTheme.headlineSmall,
          ),
        ),
        SizedBox(
          height: 320, // Keeping fixed height for now
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Padding for the ListView itself (affects start of first item and end of last item)
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 200, // Keeping fixed width for now
                // Margin for spacing between cards
                margin: const EdgeInsets.only(right: 12.0), // Increased right margin for spacing
                child: ProductCard(
                  product: product,
                  onTap: () => onProductSelected(product),
                  onAddButtonPressed: () => onProductAdded(product),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24), // Slightly increased spacing after the category section
      ],
    );
  }
}
