import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// A premium press wrapper that provides a subtle scale-down effect
/// (1.0 -> 0.98) using the centralized [AppMotion] system.
/// Fallbacks to no animation if reduced motion is enabled.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = 0.98,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scale;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.resolve(AppMotion.fast),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.curve,
        reverseCurve: AppMotion.curve,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure duration respects dynamic reduced motion toggles
    _controller.duration = AppMotion.resolve(AppMotion.fast);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
