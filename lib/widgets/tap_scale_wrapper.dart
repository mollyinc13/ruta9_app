// lib/widgets/tap_scale_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class TapScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleFactor;

  const TapScaleWrapper({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 100),
    this.scaleFactor = 0.95, // Scale down to 95%
  });

  @override
  State<TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<TapScaleWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    debugPrint("[TapScaleWrapper _handleTapDown] Tap down detected. onPressed is ${widget.onPressed == null ? 'NULL' : 'NOT NULL'}");
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    debugPrint("[TapScaleWrapper _handleTapUp] Tap up detected. onPressed is ${widget.onPressed == null ? 'NULL' : 'NOT NULL'}");
    if (widget.onPressed != null) {
      // To ensure onPressed is called even if widget is disposed during animation:
      // Call onPressed first, then reverse. Or, ensure mounted.
      debugPrint("[TapScaleWrapper _handleTapUp] Calling widget.onPressed().");
      widget.onPressed!();
      if (mounted) { // Check if mounted before reversing
        _controller.reverse();
      }
    }
  }

  void _handleTapCancel() {
    debugPrint("[TapScaleWrapper _handleTapCancel] Tap cancel detected. onPressed is ${widget.onPressed == null ? 'NULL' : 'NOT NULL'}");
    if (widget.onPressed != null && mounted) { // Check if mounted
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
