import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisissez un nouveau mot de passe sécurisé',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                AppSpacing.sectionGap,

                // ── Champs ───────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Mot de passe actuel',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _currentCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
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
                        const SizedBox(height: 24),
                        CustomTextField(
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
                        const SizedBox(height: 24),
                        _PasswordStrengthTips(),
                      ],
                    ),
                  ),
                ),

                // ── Bouton ───────────────────────────────────────────────────
                PrimaryButton(
                  label: 'Mettre à jour',
                  onPressed: _submit,
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
      ));
      return;
    }
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.cardLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Mot de passe modifié !', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            const Text(
              'Votre mot de passe a été mis à jour avec succès.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card)),
                elevation: 0,
              ),
              child: const Text('Parfait',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conseils de sécurité ─────────────────────────────────────────────────────

class _PasswordStrengthTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conseils de sécurité',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _tip('Au moins 8 caractères'),
          const SizedBox(height: 6),
          _tip('Mélangez lettres et chiffres'),
          const SizedBox(height: 6),
          _tip('Évitez les mots courants'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline,
            size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
