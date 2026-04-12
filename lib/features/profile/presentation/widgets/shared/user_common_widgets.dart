import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

/// ─── Widget partagé : section avec icon badge ────────────────────────────
/// Utilisé dans personal_info_bottom_sheet.dart et freelancer_profile_bottom_sheet.dart
class ProfileSheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const ProfileSheetSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(7),
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(AppDesign.radius8),
                border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
                child: Icon(icon, size: 16, color: const Color(0xFF1F2933)),
              ),
              AppGap.w10,
              Text(
                title.toUpperCase(),
                style: context.profileSheetSectionStyle.copyWith(
                  color: const Color(0xFF34424E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppGap.h14,
          child,
        ],
      ),
    );
  }
}

/// ─── Widget partagé : étape de vérification ───────────────────────────────
/// Utilisé dans account_page.dart et edit_profile_page.dart
class VerificationStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const VerificationStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.v8,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDesign.radius10),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.profilePrimaryLabelStyle,
                ),
                Text(
                  subtitle,
                  style: context.profileSecondaryLabelStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration profileSheetInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  bool readOnly = false,
}) {
  const borderColor = Color(0xFFE6EBF0);
  const focusColor = AppColors.inkDark;
  final labelColor = readOnly ? const Color(0xFF7A858F) : const Color(0xFF66707A);

  OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    labelStyle: context.profileSheetFieldLabelStyle.copyWith(color: labelColor),
    floatingLabelStyle: context.profileSheetFieldLabelStyle.copyWith(
      color: readOnly ? const Color(0xFF7A858F) : focusColor,
    ),
    prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1F2933)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    filled: false,
    enabledBorder: outline(borderColor),
    focusedBorder: outline(readOnly ? borderColor : focusColor, readOnly ? 1 : 1.2),
    errorBorder: outline(context.colors.error),
    focusedErrorBorder: outline(context.colors.error, 1.2),
    disabledBorder: outline(borderColor),
  );
}

class ProfileSheetPrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ProfileSheetPrimaryAction({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: context.text.titleSmall?.copyWith(
            fontSize: AppFontSize.lg,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProfileSheetSecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ProfileSheetSecondaryAction({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF7A858F),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: context.text.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF7A858F),
        ),
      ),
      child: Text(label),
    );
  }
}
