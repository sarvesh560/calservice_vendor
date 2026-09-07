import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/animated_pressable.dart';

class OnboardingLanguageSelector extends StatelessWidget {
  const OnboardingLanguageSelector({
    super.key,
    required this.currentLang,
    required this.onTap,
  });

  final String currentLang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent, // Very minimal
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: AppColors.brandSlate.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: AppColors.brandMist,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class OnboardingBottomControls extends StatefulWidget {
  const OnboardingBottomControls({
    super.key,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  });

  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  State<OnboardingBottomControls> createState() => _OnboardingBottomControlsState();
}

class _OnboardingBottomControlsState extends State<OnboardingBottomControls> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Skip Button
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.isLastPage ? 0.0 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: widget.isLastPage ? 0.0 : 72.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: 72,
                child: AnimatedPressable(
                  onPressed: widget.isLastPage ? () {} : widget.onSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      'Skip',
                      style: AppTypography.label.copyWith(
                        color: AppColors.brandMist.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Flexible space
        Expanded(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            alignment: widget.isLastPage ? Alignment.center : Alignment.centerRight,
            child: _PremiumNextButton(
              isLastPage: widget.isLastPage,
              onTap: widget.isLastPage ? widget.onGetStarted : widget.onNext,
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumNextButton extends StatefulWidget {
  final bool isLastPage;
  final VoidCallback onTap;

  const _PremiumNextButton({required this.isLastPage, required this.onTap});

  @override
  State<_PremiumNextButton> createState() => _PremiumNextButtonState();
}

class _PremiumNextButtonState extends State<_PremiumNextButton> with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _arrowAnim = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _arrowController,
        curve: Curves.easeInOutSine,
      ),
    );
    
    // Very subtle idle animation
    _arrowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: widget.onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: widget.isLastPage ? 24 : 16),
          decoration: BoxDecoration(
            color: AppColors.brandChampagne,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandChampagne.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.isLastPage ? 'GET STARTED' : 'NEXT',
                  key: ValueKey(widget.isLastPage),
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandMidnightDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: widget.isLastPage ? 48.0 : 8.0,
              ),
              AnimatedBuilder(
                animation: _arrowAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_arrowAnim.value, 0),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
