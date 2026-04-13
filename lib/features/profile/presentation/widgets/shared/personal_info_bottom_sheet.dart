import 'package:flutter/material.dart';
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

    return AppSheetSurface(
      color: AppColors.snow,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  const AppBottomSheetHandle(),
                  AppGap.h20,
                  Text(
                    "Informations personnelles",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSize.title,
                      fontWeight: FontWeight.w300,
                      color: context.colors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                  AppGap.h16,
                  Divider(color: context.colors.divider, height: 1),
                ],
              ),
            ),

            // ── Contenu ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ProfileSheetSection(
                icon: Icons.person_outline_rounded,
                title: 'Identité',
                child: Column(
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
                    Text(
                      'Ces informations ne peuvent pas être modifiées après inscription.',
                      style: context.text.bodySmall?.copyWith(
                        color: const Color(0xFF7A858F),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            AppGap.h20,
            Divider(color: context.colors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  ProfileSheetPrimaryAction(
                    onPressed: () => Navigator.pop(context),
                    label: "Fermer",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
      style: const TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9AA4AF),
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        readOnly: true,
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFFB0BAC4)),
      ),
    );
  }
}
