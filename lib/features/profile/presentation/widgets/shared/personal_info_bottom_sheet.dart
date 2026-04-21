import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../profile/profile_provider.dart';
import 'user_common_widgets.dart';

/// Affiche le bottom sheet d'informations personnelles.
void showPersonalInfoBottomSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    isScrollControlled: true,
    wrapWithSurface: false,
    child: const _PersonalInfoSheet(),
  );
}

class _PersonalInfoSheet extends StatelessWidget {
  const _PersonalInfoSheet();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return AppFormSheet(
      title: "Informations personnelles",
      footer: Column(
        children: [
          ProfileSheetPrimaryAction(
            onPressed: () => Navigator.pop(context),
            label: "Fermer",
          ),
        ],
      ),
      child: ProfileSheetSection(
        icon: Icons.person_outline_rounded,
        title: 'Identité',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.person_outline_rounded,
                label: "Prénom",
                value: profile?.firstName ?? '—',
              ),
            ),
            AppGap.h16,
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.person_outline_rounded,
                label: "Nom",
                value: profile?.lastName ?? '—',
              ),
            ),
            AppGap.h16,
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.mail_outline_rounded,
                label: "Email",
                value: profile?.email ?? '—',
              ),
            ),
            AppGap.h16,
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.phone_outlined,
                label: "Téléphone",
                value: profile?.phone?.isNotEmpty == true
                    ? profile!.phone!
                    : '—',
              ),
            ),
            AppGap.h16,
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.cake_outlined,
                label: "Date de naissance",
                value: _formatBirthDate(profile?.birthDate),
              ),
            ),
            AppGap.h16,
            _ShadowField(
              child: _ReadOnlyField(
                icon: Icons.wc_outlined,
                label: "Genre",
                value: _formatGender(profile?.gender),
              ),
            ),
            AppGap.h16,
            Text(
              'Ces informations ne peuvent pas être modifiées après inscription.',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textTertiary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBirthDate(DateTime? birthDate) {
  if (birthDate == null) return '—';
  return DateFormat('dd/MM/yyyy', 'fr_FR').format(birthDate);
}

String _formatGender(String? gender) {
  switch (gender) {
    case 'homme':
      return 'Homme';
    case 'femme':
      return 'Femme';
    case 'autre':
      return 'Autre';
    default:
      return '—';
  }
}

// ─── Wrapper ombre ambiante douce ─────────────────────────────────────────────

class _ShadowField extends StatelessWidget {
  final Widget child;
  const _ShadowField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Champ lecture seule ──────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textTertiary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        readOnly: true,
        prefixIcon: Icon(icon, size: 16, color: context.colors.textHint),
      ),
    );
  }
}
