import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../verification/verification_method_page.dart';
import 'step6_usertype_page.dart';

class Step5PasswordPage extends StatefulWidget {
  final RegistrationData data;

  const Step5PasswordPage({super.key, required this.data});

  @override
  State<Step5PasswordPage> createState() => _Step5PasswordPageState();
}

class _Step5PasswordPageState extends State<Step5PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        currentStep: 5,
        totalSteps: 7,
        title: 'Mot de passe',
        subtitle: 'Choisissez un mot de passe sécurisé',
        buttonLabel: 'Continuer',
        onBack: () => Navigator.pop(context),
        onButtonPressed: _goToNextStep,
        child: Column(
          children: [
            CustomTextField(
              label: 'Mot de passe',
              hint: 'Minimum 8 caractères',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              controller: _passwordController,
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Mot de passe requis';
                if (value.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Confirmer le mot de passe',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              controller: _confirmController,
              validator: (value) {
                if (value != _passwordController.text) {
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
    );
  }

  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) return;

    widget.data.password = _passwordController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationMethodPage(
          data: widget.data,
          nextPage: Step6UserTypePage(data: widget.data),
        ),
      ),
    );
  }
}

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
