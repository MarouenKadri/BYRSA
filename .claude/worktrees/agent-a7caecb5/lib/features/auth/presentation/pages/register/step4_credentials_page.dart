import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/phone_input_field.dart';
import 'step5_password_page.dart';

class Step4CredentialsPage extends StatefulWidget {
  final RegistrationData data;

  const Step4CredentialsPage({super.key, required this.data});

  @override
  State<Step4CredentialsPage> createState() => _Step4CredentialsPageState();
}

class _Step4CredentialsPageState extends State<Step4CredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        currentStep: 4,
        totalSteps: 7,
        title: 'Vos coordonnées',
        subtitle: 'Pour vous contacter et vérifier votre identité',
        buttonLabel: 'Continuer',
        onBack: () => Navigator.pop(context),
        onButtonPressed: _goToNextStep,
        child: Column(
          children: [
            CustomTextField(
              label: 'Email',
              hint: 'exemple@mail.com',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email requis';
                if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PhoneInputField(
              controller: _phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Téléphone requis';
                if (value.replaceAll(' ', '').length < 10) {
                  return 'Numéro invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ─── Usage des coordonnées ───
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _usageRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    description: 'Connexion à votre compte',
                  ),
                  const Divider(height: 20),
                  _usageRow(
                    icon: Icons.sms_outlined,
                    label: 'Téléphone',
                    description: 'Vérification par SMS',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Sécurité ───
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded,
                      color: AppColors.info, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vos données sont chiffrées et ne seront jamais partagées',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info,
                        height: 1.4,
                      ),
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

  Widget _usageRow({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) return;

    widget.data
      ..email = _emailController.text.trim()
      ..phone = _phoneController.text.replaceAll(' ', '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step5PasswordPage(data: widget.data),
      ),
    );
  }
}
