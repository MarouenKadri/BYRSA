import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/photo_picker.dart';
import 'step6_usertype_page.dart';

// ─── Step 7 : Photo de profil (Freelancer uniquement) ─────────────────────────

class Step7PhotoPage extends StatefulWidget {
  final RegistrationData data;

  const Step7PhotoPage({super.key, required this.data});

  @override
  State<Step7PhotoPage> createState() => _Step7PhotoPageState();
}

class _Step7PhotoPageState extends State<Step7PhotoPage> {
  File? _photo;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      currentStep: 7,
      totalSteps: 7,
      title: 'Votre photo de profil',
      subtitle: 'Aidez les clients à vous reconnaître',
      buttonLabel: 'Créer mon compte',
      isLoading: _isLoading,
      isButtonEnabled: _photo != null,
      onBack: () => Navigator.pop(context),
      onButtonPressed: _photo != null ? _handleSubmit : null,
      child: Column(
        children: [
          // ─── Banner info ───
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Les profils avec photo reçoivent 5× plus de demandes',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ─── Photo picker avec anneau décoratif ───
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _photo != null
                      ? AppColors.primary.withOpacity(0.35)
                      : AppColors.border,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: PhotoPicker(
                photo: _photo,
                size: 160,
                isCircle: true,
                onPhotoChanged: (file) => setState(() => _photo = file),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Hint ───
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _photo != null
                      ? Icons.check_circle_rounded
                      : Icons.touch_app_rounded,
                  size: 15,
                  color: _photo != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _photo != null
                      ? 'Appuyez pour modifier la photo'
                      : 'Appuyez pour ajouter une photo',
                  style: TextStyle(
                    fontSize: 13,
                    color: _photo != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: _photo != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Tips ───
          _buildTips(),
          const SizedBox(height: 20),

          // ─── Passer cette étape ───
          Center(
            child: TextButton(
              onPressed: _handleSkip,
              child: Text(
                'Passer cette étape',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conseils pour une bonne photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _tip(Icons.face_rounded, 'Visage bien visible et centré'),
          const SizedBox(height: 8),
          _tip(Icons.wb_sunny_outlined, 'Bonne luminosité'),
          const SizedBox(height: 8),
          _tip(Icons.verified_rounded, 'Photo récente et professionnelle'),
        ],
      ),
    );
  }

  Widget _tip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    widget.data.photo = _photo;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationSuccessPage(data: widget.data),
        ),
        (_) => false,
      );
    }
  }

  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationSuccessPage(data: widget.data),
      ),
      (_) => false,
    );
  }
}
