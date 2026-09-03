import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import 'auth_controller.dart';

/// Native Flutter Create Account screen matching [ServicesScreen] design architecture.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobileNumber = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signup(
            firstName: firstName,
            lastName: lastName.isNotEmpty ? lastName : null,
            mobileNumber: mobileNumber,
            email: email,
            password: password,
          );
    } on DioException catch (e) {
      debugPrint('[WORKFORCE SIGNUP ERROR] ${e.response?.statusCode}: ${e.response?.data}');
      if (mounted) {
        setState(
          () => _errorMessage = describeDioError(
            e,
            fallback: 'Unable to create workforce account. Please check details and retry.',
          ),
        );
      }
    } catch (e) {
      debugPrint('[WORKFORCE SIGNUP UNEXPECTED ERROR] $e');
      if (mounted) {
        setState(
          () => _errorMessage =
              'Unable to create workforce account. Please check details and retry.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(
        title: 'Create Account',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. Page Introduction (Matching ServicesScreen _buildPageIntro) ─
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.75),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandMidnightDark.withValues(alpha: 0.035),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create your vendor account',
                            style: AppTypography.display.copyWith(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandMidnightDark,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Set up your account to start your CalService vendor journey.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.brandSlate,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Error Banner ──────────────────────────────────────────
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.error.tint,
                          border: Border.all(color: AppColors.error.tintBorder),
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error.base),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error.base,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _errorMessage = null),
                              child: Icon(Icons.close_rounded, size: 16, color: AppColors.error.base),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Form Section 1: Account Details ───────────────────────
                    _FormCardSection(
                      title: 'Personal Details',
                      icon: Icons.person_outline_rounded,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          decoration: _inputDecoration('First Name', Icons.badge_outlined),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter first name' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _lastNameController,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          decoration: _inputDecoration('Last Name (Optional)', Icons.badge_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Form Section 2: Contact Details ───────────────────────
                    _FormCardSection(
                      title: 'Contact Details',
                      icon: Icons.contact_mail_outlined,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email Address', Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _mobileController,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Mobile Number', Icons.phone_outlined),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter mobile number' : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Form Section 3: Security Credentials ──────────────────
                    _FormCardSection(
                      title: 'Account Security',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          decoration: _inputDecoration(
                            'Password',
                            Icons.key_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.brandSlate,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter password';
                            if (v.length < 8) return 'Password must be at least 8 characters';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: AppTypography.body.copyWith(color: AppColors.brandMidnight),
                          decoration: _inputDecoration(
                            'Confirm Password',
                            Icons.key_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.brandSlate,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Please confirm password' : null,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Primary Action Button ─────────────────────────────────
                    AnimatedPressable(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.brandMidnightDark,
                          borderRadius: BorderRadius.circular(AppRadius.control),
                          border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.brandChampagne,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.brandChampagne,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Sign In Footer ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.brandSlate),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            'Sign In',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.brandChampagne,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.brandSlate),
      prefixIcon: Icon(prefixIcon, color: AppColors.brandSlate, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceMuted.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.brandChampagne, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.error.base),
      ),
    );
  }
}

class _FormCardSection extends StatelessWidget {
  const _FormCardSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brandChampagne),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.title.copyWith(
                  color: AppColors.brandMidnight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}
