import 'package:flutter/material.dart';

class FloatingCartButton extends StatelessWidget {
  final int itemCount; // For displaying a badge, 0 for no badge or no number
  final VoidCallback onPressed;

  const FloatingCartButton({
    super.key,
    this.itemCount = 0, // Default to 0 items
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colorScheme.secondary, // Using secondary color (e.g., yellow)
      foregroundColor: colorScheme.onSecondary, // Text/icon color on secondary
      tooltip: 'Ver Carrito', // Tooltip for accessibility
      elevation: 6.0,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Icon(Icons.shopping_cart, size: 28),
          if (itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colorScheme.error, // Or primaryRed from AppColors
                  borderRadius: BorderRadius.circular(10), // Make it circular
                  border: Border.all(color: colorScheme.secondary, width: 1.5)
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  '$itemCount',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onError, // Text color on error color
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Slightly smaller for badge
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
