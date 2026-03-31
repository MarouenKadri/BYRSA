import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────────
                Text(
                  'Mot de passe',
                  style: context.profilePageTitleStyle.copyWith(
                    fontSize: AppFontSize.h1,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                AppGap.h8,
                Text(
                  'Choisissez un nouveau mot de passe sécurisé',
                  style: context.profileSecondaryLabelStyle.copyWith(
                    fontSize: AppFontSize.body,
                    height: 1.4,
                  ),
                ),
                AppSpacing.sectionGap,

                // ── Champs ───────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Mot de passe actuel',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _currentCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
                        ),
                        AppGap.h24,
                        AppTextField(
                          label: 'Nouveau mot de passe',
                          hint: 'Minimum 8 caractères',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _newCtrl,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Champ obligatoire';
                            if (v.length < 8) return 'Minimum 8 caractères';
                            if (!v.contains(RegExp(r'[A-Za-z]'))) {
                              return 'Doit contenir au moins 1 lettre';
                            }
                            if (!v.contains(RegExp(r'[0-9]'))) {
                              return 'Doit contenir au moins 1 chiffre';
                            }
                            return null;
                          },
                        ),
                        AppGap.h24,
                        AppTextField(
                          label: 'Confirmer le mot de passe',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _confirmCtrl,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Champ obligatoire';
                            if (v != _newCtrl.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        AppGap.h24,
                        _PasswordStrengthTips(),
                      ],
                    ),
                  ),
                ),

                // ── Bouton ───────────────────────────────────────────────────
                AppButton(
                  label: 'Mettre à jour',
                  onPressed: _submit,
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final error =
        await context.read<AuthProvider>().updatePassword(_newCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      showAppSnackBar(context, error, type: SnackBarType.error);
      return;
    }
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      title: Text('Mot de passe modifié !', style: context.text.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: AppInsets.a18,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 48),
          ),
          AppGap.h16,
          Text(
            'Votre mot de passe a été mis à jour avec succès.',
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirmLabel: 'Parfait',
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }
}

// ─── Conseils de sécurité ─────────────────────────────────────────────────────

class _PasswordStrengthTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a14,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conseils de sécurité',
            style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h10,
          _tip(context, 'Au moins 8 caractères'),
          AppGap.h6,
          _tip(context, 'Mélangez lettres et chiffres'),
          AppGap.h6,
          _tip(context, 'Évitez les mots courants'),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline,
            size: 16, color: context.colors.textSecondary),
        AppGap.w8,
        Text(
          text,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}
