// lib/widgets/combos_section.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart'; // Reusing the existing ProductCard

class CombosSectionWidget extends StatelessWidget {
  final List<Product> comboProducts;
  final Function(Product product) onComboSelected; // Callback when a combo card is tapped
  final Function(Product product) onComboAdded;    // Callback for "Add" button on combo card

  const CombosSectionWidget({
    super.key,
    required this.comboProducts,
    required this.onComboSelected,
    required this.onComboAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (comboProducts.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no combos
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    // Determine card width for a "slider-like" feel, aiming for roughly 1.5 to 2 cards visible on average screens.
    // This is an estimate; true "2 at a time" would need more complex layout or PageView.
    // Let's make combo cards wider than standard product cards.
    // Standard ProductCard in CategorySection is 200. Let's try 280 or 300 for combos.
    final double cardWidth = 280;
    // Height can be the same as CategorySection's ProductCard list, or adjusted if combos need more height.
    // CategorySection SizedBox height is 320. ProductCard flex factors are 3 (image) and 2 (details).
    // This makes the image part roughly 320 * 3/5 = 192, details 320 * 2/5 = 128.
    // If cardWidth is 280, aspect ratio is 280/320 = 0.875. Image: 280x192. Details: 280x128.
    // This should be fine.
    final double listHeight = 320;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
          child: Text(
            "Nuestros Combos", // Title for the section
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), // Make it bold
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: comboProducts.length,
            itemBuilder: (context, index) {
              final product = comboProducts[index];
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 16.0), // Spacing between combo cards
                child: ProductCard( // Reusing ProductCard
                  product: product,
                  onTap: () => onComboSelected(product),
                  onAddButtonPressed: () => onComboAdded(product),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24), // Spacing after the combos section
      ],
    );
  }
}
