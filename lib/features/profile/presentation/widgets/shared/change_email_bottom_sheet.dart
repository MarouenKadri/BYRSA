import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import 'user_common_widgets.dart';

/// Affiche le bottom sheet de changement d'email.
void showChangeEmailBottomSheet(BuildContext context, {String currentEmail = ''}) {
  showAppBottomSheet(
    context: context,
    isScrollControlled: true,
    wrapWithSurface: false,
    child: _ChangeEmailSheet(currentEmail: currentEmail),
  );
}

class _ChangeEmailSheet extends StatefulWidget {
  final String currentEmail;
  const _ChangeEmailSheet({this.currentEmail = ''});

  @override
  State<_ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<_ChangeEmailSheet> {
  final _formKey     = GlobalKey<FormState>();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppSheetSurface(
        // Fond #FAFAFA opaque — override du blanc translucide par défaut
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
                    "Adresse email",
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

                  // ── Email actuel (lecture seule) ─────────────────────────
                  _ShadowField(
                    child: _ReadOnlyField(
                      label: "Email actuel",
                      value: widget.currentEmail.isNotEmpty
                          ? widget.currentEmail
                          : "user@example.com",
                    ),
                  ),
                  AppGap.h16,

                  // ── Nouvel email ─────────────────────────────────────────
                  _ShadowField(
                    child: _EmailField(
                      controller: _newCtrl,
                      label: "Nouvel email",
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Champ requis";
                        if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
                          return "Adresse email invalide";
                        }
                        if (v == widget.currentEmail) {
                          return "Doit être différent de l'email actuel";
                        }
                        return null;
                      },
                    ),
                  ),
                  AppGap.h16,

                  // ── Confirmation ─────────────────────────────────────────
                  _ShadowField(
                    child: _EmailField(
                      controller: _confirmCtrl,
                      label: "Confirmer le nouvel email",
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Champ requis";
                        if (v != _newCtrl.text) return "Les emails ne correspondent pas";
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
    // TODO: appeler l'API de changement d'email
  }
}

// ─── Wrapper ombre ambiante douce — aucune bordure visible ───────────────────

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

// ─── Champ lecture seule (email actuel) ──────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

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
      decoration: _emailInputDecoration(context, label: label, readOnly: true),
    );
  }
}

// ─── Champ email éditable ─────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _EmailField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: _emailInputDecoration(context, label: label).copyWith(
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}

// ─── Décoration locale : no-stroke, fond blanc, icône hairline ───────────────

InputDecoration _emailInputDecoration(
  BuildContext context, {
  required String label,
  bool readOnly = false,
}) {
  final Color labelColor =
      readOnly ? const Color(0xFF9AA4AF) : const Color(0xFF8A949E);

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
      color: labelColor,
    ),
    prefixIcon: const Icon(
      Icons.mail_outline_rounded,
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
