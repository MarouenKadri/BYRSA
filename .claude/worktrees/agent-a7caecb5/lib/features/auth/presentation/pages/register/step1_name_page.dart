import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import 'step2_birthdate_page.dart';

class Step1NamePage extends StatefulWidget {
  final RegistrationData data;

  const Step1NamePage({super.key, required this.data});

  @override
  State<Step1NamePage> createState() => _Step1NamePageState();
}

class _Step1NamePageState extends State<Step1NamePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        currentStep: 1,
        totalSteps: 7,
        title: 'Comment vous appelez-vous ?',
        subtitle: 'Votre nom sera affiché sur votre profil',
        buttonLabel: 'Continuer',
        onBack: () => Navigator.pop(context),
        onButtonPressed: _goToNextStep,
        child: Column(
          children: [
            CustomTextField(
              label: 'Prénom',
              hint: 'Jean',
              prefixIcon: Icons.person_outline_rounded,
              controller: _firstNameController,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Prénom requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Nom',
              hint: 'Dupont',
              prefixIcon: Icons.badge_outlined,
              controller: _lastNameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nom requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ─── Info banner ───
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: AppColors.info, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre nom complet sera visible sur votre profil public',
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

  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) return;

    widget.data
      ..firstName = _firstNameController.text.trim()
      ..lastName = _lastNameController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step2BirthdatePage(data: widget.data),
      ),
    );
  }
}
