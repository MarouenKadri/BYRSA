import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import 'step4_credentials_page.dart';

class Step3GenderPage extends StatefulWidget {
  final RegistrationData data;

  const Step3GenderPage({super.key, required this.data});

  @override
  State<Step3GenderPage> createState() => _Step3GenderPageState();
}

class _Step3GenderPageState extends State<Step3GenderPage> {
  Gender? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      currentStep: 3,
      totalSteps: 7,
      title: 'Votre genre',
      subtitle: 'Cette information reste privée',
      buttonLabel: 'Continuer',
      isButtonEnabled: _selectedGender != null,
      onBack: () => Navigator.pop(context),
      onButtonPressed: _selectedGender != null ? _goToNextStep : null,
      child: Column(
        children: Gender.values.map((gender) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _GenderCard(
              gender: gender,
              isSelected: _selectedGender == gender,
              onTap: () => setState(() => _selectedGender = gender),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _goToNextStep() {
    widget.data.gender = _selectedGender;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step4CredentialsPage(data: widget.data),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final Gender gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (gender) {
      case Gender.homme:
        return Icons.person_rounded;
      case Gender.femme:
        return Icons.face_3_rounded;
      case Gender.autre:
        return Icons.people_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.verifiedBg : AppColors.chipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                gender.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
