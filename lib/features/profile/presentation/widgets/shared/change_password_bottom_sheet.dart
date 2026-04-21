import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
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
      child: Form(
        key: _formKey,
        child: AppFormSheet(
          title: "Mot de passe",
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final err = await context.read<AuthProvider>().updatePassword(_newCtrl.text.trim());
    if (!mounted) return;
    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
    } else {
      Navigator.pop(context);
      showAppSnackBar(context, 'Mot de passe mis à jour', type: SnackBarType.success);
    }
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
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        prefixIcon: Icon(Icons.lock_outline_rounded, size: 16, color: context.colors.textHint),
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 19,
            color: context.colors.textPrimary,
          ),
          onPressed: onToggle,
        ),
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}

