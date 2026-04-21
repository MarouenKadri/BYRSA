import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
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
      child: Form(
        key: _formKey,
        child: AppFormSheet(
          title: "Adresse email",
          footer: Column(
            children: [
              ProfileSheetPrimaryAction(
                onPressed: _submit,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShadowField(
                child: _ReadOnlyField(
                  label: "Email actuel",
                  value: widget.currentEmail.isNotEmpty
                      ? widget.currentEmail
                      : "user@example.com",
                ),
              ),
              AppGap.h16,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final err = await context.read<AuthProvider>().updateEmail(_newCtrl.text.trim());
    if (!mounted) return;
    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
    } else {
      Navigator.pop(context);
      showAppSnackBar(
        context,
        'Email mis à jour. Confirmez via le lien envoyé.',
        type: SnackBarType.success,
      );
    }
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
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textTertiary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        readOnly: true,
        prefixIcon: Icon(Icons.mail_outline_rounded, size: 16, color: context.colors.textHint),
      ),
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
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        prefixIcon: Icon(Icons.mail_outline_rounded, size: 16, color: context.colors.textHint),
      ).copyWith(errorStyle: context.profileErrorStyle),
    );
  }
}

