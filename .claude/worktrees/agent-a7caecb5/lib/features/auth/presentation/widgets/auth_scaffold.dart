import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import 'auth_header.dart';
import 'step_indicator.dart';
import 'primary_button.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? currentStep;
  final int? totalSteps;
  final Widget child;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final bool isButtonEnabled;
  final VoidCallback? onBack;
  final Widget? bottomWidget;

  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.currentStep,
    this.totalSteps,
    required this.child,
    required this.buttonLabel,
    this.onButtonPressed,
    this.isLoading = false,
    this.isButtonEnabled = true,
    this.onBack,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: onBack,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentStep != null && totalSteps != null) ...[
                StepIndicator(
                  currentStep: currentStep!,
                  totalSteps: totalSteps!,
                ),
                AppSpacing.sectionGap,
              ],

              AuthHeader(title: title, subtitle: subtitle),
              AppSpacing.sectionGap,

              Expanded(
                child: SingleChildScrollView(child: child),
              ),

              if (bottomWidget != null) ...[
                bottomWidget!,
                const SizedBox(height: 16),
              ],

              PrimaryButton(
                label: buttonLabel,
                onPressed: onButtonPressed,
                isLoading: isLoading,
                isEnabled: isButtonEnabled,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
