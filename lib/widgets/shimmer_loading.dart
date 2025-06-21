// lib/widgets/shimmer_loading.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Will add this dependency

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading; // Control whether to show shimmer or child

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    // Define shimmer gradient colors based on the app's dark theme
    final shimmerBaseColor = Colors.grey[800]!; // Darker grey for base
    final shimmerHighlightColor = Colors.grey[700]!; // Lighter grey for highlight

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      period: const Duration(milliseconds: 1200), // Adjust speed of shimmer
      child: child, // The child is the skeleton layout
    );
  }
}
