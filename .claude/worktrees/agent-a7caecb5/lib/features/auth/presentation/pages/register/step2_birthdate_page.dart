import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import 'step3_gender_page.dart';

class Step2BirthdatePage extends StatefulWidget {
  final RegistrationData data;

  const Step2BirthdatePage({super.key, required this.data});

  @override
  State<Step2BirthdatePage> createState() => _Step2BirthdatePageState();
}

class _Step2BirthdatePageState extends State<Step2BirthdatePage> {
  DateTime? _selectedDate;

  bool get _isValid => _selectedDate != null;

  String _formatDate(DateTime d) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: DateTime(1920),
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      currentStep: 2,
      totalSteps: 7,
      title: 'Votre date de naissance',
      subtitle: 'Vous devez avoir au moins 18 ans',
      buttonLabel: 'Continuer',
      isButtonEnabled: _isValid,
      onBack: () => Navigator.pop(context),
      onButtonPressed: _isValid ? _goToNextStep : null,
      child: Column(
        children: [
          GestureDetector(
            onTap: _openDatePicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedDate != null
                    ? AppColors.verifiedBg
                    : AppColors.chipBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedDate != null
                      ? AppColors.primary
                      : AppColors.border,
                  width: _selectedDate != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _selectedDate != null
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: _selectedDate != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDate != null
                              ? 'Date de naissance'
                              : 'Sélectionner une date',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_selectedDate!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _selectedDate != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous devez avoir au moins 18 ans pour utiliser Inkern',
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
    );
  }

  void _goToNextStep() {
    widget.data.birthDate = _selectedDate;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step3GenderPage(data: widget.data),
      ),
    );
  }
}
