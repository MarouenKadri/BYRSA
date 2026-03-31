import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
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

  // Données non modifiables (récupérées depuis le profil)
  static const String _firstName = 'Jean';
  static const String _lastName  = 'Dupont';
  static final DateTime _birthDate = DateTime(1995, 5, 12);
  static const String _gender    = 'Homme';

  @override
  Widget build(BuildContext context) {
    return AppSheetSurface(
      color: const Color(0xFFFAFAFA),
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
                    style: GoogleFonts.inter(
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
                        value: _firstName,
                      ),
                    ),
                    AppGap.h16,
                    _ShadowField(
                      child: _ReadOnlyField(
                        icon: Icons.person_outline_rounded,
                        label: "Nom",
                        value: _lastName,
                      ),
                    ),
                    AppGap.h16,
                    _ShadowField(
                      child: _ReadOnlyField(
                        icon: Icons.cake_outlined,
                        label: "Date de naissance",
                        value:
                            '${_birthDate.day.toString().padLeft(2, '0')}/'
                            '${_birthDate.month.toString().padLeft(2, '0')}/'
                            '${_birthDate.year}',
                      ),
                    ),
                    AppGap.h16,
                    _ShadowField(
                      child: _ReadOnlyField(
                        icon: Icons.wc_rounded,
                        label: "Genre",
                        value: _gender,
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
                    label: "Enregistrer",
                  ),
                  AppGap.h12,
                  Center(
                    child: ProfileSheetSecondaryAction(
                      label: "Annuler",
                      onTap: () => Navigator.pop(context),
                    ),
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
      style: GoogleFonts.inter(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9AA4AF),
      ),
      decoration: _infoInputDecoration(context, label: label, icon: icon),
    );
  }
}

// ─── Décoration locale : no-stroke, fond blanc, icône hairline ───────────────

InputDecoration _infoInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
}) {
  OutlineInputBorder border({Color color = Colors.transparent, bool visible = false}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: visible
            ? BorderSide(color: color, width: 1)
            : BorderSide.none,
      );

  return InputDecoration(
    hintText: label,
    hintStyle: GoogleFonts.inter(
      fontSize: AppFontSize.md,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF9AA4AF),
    ),
    prefixIcon: Icon(icon, size: 16, color: const Color(0xFFB0BAC4)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    filled: true,
    fillColor: Colors.white,
    border: border(),
    enabledBorder: border(),
    focusedBorder: border(),
    disabledBorder: border(),
    errorBorder: border(color: AppColors.error, visible: true),
    focusedErrorBorder: border(color: AppColors.error, visible: true),
  );
}
