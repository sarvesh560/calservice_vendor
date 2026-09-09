import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/localization/language_controller.dart';
import 'onboarding_controller.dart';
import 'components/onboarding_illustration.dart';
import 'components/onboarding_page_content.dart';
import 'components/onboarding_indicator.dart';
import 'components/onboarding_controls.dart';


class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  static const _slides = [
    (
      image: 'assets/images/onboarding/animations/Plumbers.json',
      eyebrow: 'PAGE 01 • SERVICE NETWORK',
      title: 'Join CalService\nNetwork',
      description: 'Connect with thousands of customers needing verified expert service technicians in your area.',
    ),
    (
      image: 'assets/images/onboarding/animations/Femenine Color palette of a painter.json',
      eyebrow: 'PAGE 02 • SMART JOB MANAGEMENT',
      title: 'Manage Jobs\n& Dispatch',
      description: 'Receive real-time job offers, accept assignments, update your status, and complete work effortlessly.',
    ),
    (
      image: 'assets/images/onboarding/animations/Man riding a red scooter.json',
      eyebrow: 'PAGE 03 • GROW YOUR BUSINESS',
      title: 'Instant Earnings\n& Payouts',
      description: 'Track your daily earnings, manage your bank accounts, and request instant wallet withdrawals anytime.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted && _pageController.position.haveDimensions) {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    context.go(AppRoutes.createAccount);
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showLanguageSelector(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _LanguageTile(
                  code: 'en',
                  label: 'English',
                  isSelected: currentLang == 'en',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('en');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'ta',
                  label: 'தமிழ் (Tamil)',
                  isSelected: currentLang == 'ta',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('ta');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'hi',
                  label: 'हिन्दी (Hindi)',
                  isSelected: currentLang == 'hi',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('hi');
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageControllerProvider);
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.brandMidnightDark,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BRANDING
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CALSERVICE\nVENDOR',
                    style: AppTypography.label.copyWith(
                      color: AppColors.brandMist,
                      letterSpacing: 1.5,
                      height: 1.15,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  OnboardingLanguageSelector(
                    currentLang: currentLang,
                    onTap: () => _showLanguageSelector(context, currentLang),
                  ),
                ],
              ),
            ),

            // ILLUSTRATION AREA (~42%)
            Expanded(
              flex: 42,
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(_slides.length, (index) {
                  final slideOffset = _pageOffset - index;
                  // Render optimization
                  if (slideOffset.abs() > 1.5) return const SizedBox.shrink();

                  return OnboardingIllustration(
                    imagePath: _slides[index].image,
                    pageOffset: slideOffset,
                    isActive: _currentPage == index,
                  );
                }).reversed.toList(),
              ),
            ),

            // TEXT & INDICATOR AREA (~45%)
            Expanded(
              flex: 45,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.md),
                                child: OnboardingPageContent(
                                  eyebrow: _slides[index].eyebrow,
                                  title: _slides[index].title,
                                  description: _slides[index].description,
                                  isActive: _currentPage == index,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // PAGE INDICATOR
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: OnboardingIndicator(
                      slideCount: _slides.length,
                      pageOffset: _pageOffset,
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM CONTROLS (~13%)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
                child: OnboardingBottomControls(
                  isLastPage: isLastPage,
                  onSkip: _onFinish,
                  onNext: _onNext,
                  onGetStarted: _onFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        label,
        style: AppTypography.title.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}
