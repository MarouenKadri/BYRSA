import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import 'user_common_widgets.dart';

/// Affiche le bottom sheet de changement de mot de passe.
void showChangePasswordBottomSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    isScrollControlled: true,
    wrapWithSurface: false,
    child: const _ChangePasswordSheet(),
  );
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _repeatCtrl  = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew     = true;
  bool _hideRepeat  = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _repeatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppSheetSurface(
        color: const Color(0xFFFAFAFA),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Handle ────────────────────────────────────────────────
                  const AppBottomSheetHandle(),
                  AppGap.h20,

                  // ── Titre Inter Light centré ──────────────────────────────
                  Text(
                    "Mot de passe",
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
                  AppGap.h24,

                  // ── Mot de passe actuel ───────────────────────────────────
                  _ShadowField(
                    child: _PasswordField(
                      controller: _currentCtrl,
                      label: "Mot de passe actuel",
                      obscure: _hideCurrent,
                      onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Champ requis" : null,
                    ),
                  ),
                  AppGap.h16,

                  // ── Nouveau mot de passe ──────────────────────────────────
                  _ShadowField(
                    child: _PasswordField(
                      controller: _newCtrl,
                      label: "Nouveau mot de passe",
                      obscure: _hideNew,
                      onToggle: () => setState(() => _hideNew = !_hideNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Champ requis";
                        if (v.length < 8) return "Minimum 8 caractères";
                        return null;
                      },
                    ),
                  ),
                  AppGap.h16,

                  // ── Confirmation ──────────────────────────────────────────
                  _ShadowField(
                    child: _PasswordField(
                      controller: _repeatCtrl,
                      label: "Confirmer le nouveau mot de passe",
                      obscure: _hideRepeat,
                      onToggle: () => setState(() => _hideRepeat = !_hideRepeat),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Champ requis";
                        if (v != _newCtrl.text) return "Les mots de passe ne correspondent pas";
                        return null;
                      },
                    ),
                  ),
                  AppGap.h32,

                  // ── CTA principal noir pilule ─────────────────────────────
                  ProfileSheetPrimaryAction(
                    onPressed: _submit,
                    label: "Enregistrer",
                  ),
                  AppGap.h12,

                  // ── CTA secondaire discret ────────────────────────────────
                  Center(
                    child: ProfileSheetSecondaryAction(
                      label: "Annuler",
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    // TODO: appeler l'API de changement de mot de passe
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

// ─── Champ mot de passe avec toggle visibilité ────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: _passwordInputDecoration(context, label: label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 19,
            color: const Color(0xFF1F2933),
          ),
          onPressed: onToggle,
        ),
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}

// ─── Décoration locale : no-stroke, fond blanc, icône hairline ───────────────

InputDecoration _passwordInputDecoration(
  BuildContext context, {
  required String label,
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
      color: const Color(0xFF8A949E),
    ),
    prefixIcon: const Icon(
      Icons.lock_outline_rounded,
      size: 16,
      color: Color(0xFFB0BAC4),
    ),
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
