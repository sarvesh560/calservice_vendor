import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_motion.dart';

class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.imagePath,
    required this.pageOffset,
    required this.isActive,
  });

  final String imagePath;
  final double pageOffset;
  final bool isActive;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    if (widget.isActive) {
      _triggerFloat();
    }
  }

  void _triggerFloat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isTest = const bool.fromEnvironment('dart.vm.product') == false &&
            WidgetsBinding.instance.lifecycleState == null;
        final isReduced = AppMotion.isReduced || MediaQuery.of(context).disableAnimations || isTest;
        if (!isReduced) {
          _floatController.repeat();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant OnboardingIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _triggerFloat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _floatController.stop();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = AppMotion.isReduced || MediaQuery.of(context).disableAnimations;
    final absOffset = widget.pageOffset.abs();
    
    // Calculate parallax properties based on swipe
    final double scale = isReduced ? 1.0 : (1.0 - (0.04 * absOffset.clamp(0.0, 1.0)));
    final double opacity = (1.0 - absOffset.clamp(0.0, 1.0)).clamp(0.0, 1.0);
    
    // Directional parallax
    final double direction = widget.pageOffset > 0 ? 1 : -1;
    final double translateX = isReduced ? 0.0 : (widget.pageOffset * -30.0);
    final double rotateY = isReduced ? 0.0 : (absOffset.clamp(0.0, 1.0) * -0.02 * direction);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        double floatY = 0.0;
        double floatRotate = 0.0;
        double floatScale = 1.0;
        
        if (!isReduced && _floatController.isAnimating) {
          // Use easeInOut curve for smoother floating
          final t = Curves.easeInOutSine.transform(_floatController.value);
          // Subtly float up and down (3-5px)
          floatY = math.sin(t * 2 * math.pi) * -4.0;
          // Extremely subtle rotation
          floatRotate = math.cos(t * 2 * math.pi) * 0.002;
          // Very subtle scale (0.995 -> 1.005)
          floatScale = 1.0 + (math.sin(t * 2 * math.pi) * 0.005);
        }

        final combinedScale = scale * floatScale;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(translateX, floatY),
            child: Transform.scale(
              scale: combinedScale,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(rotateY)
                  ..rotateZ(floatRotate),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: FractionallySizedBox(
        widthFactor: 0.78, // Scale down to ~78% of width per requirements
        child: Container(
          // Soft subtle backdrop glow behind the SVG
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandChampagne.withValues(alpha: 0.03),
                blurRadius: 60,
                spreadRadius: 20,
              )
            ],
          ),
          child: Lottie.asset(
            widget.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(Icons.error_outline, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
