import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/navigation/root_nav.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_type_card.dart';
import 'step7_photo_page.dart';

// ─── Step 6 : Choisir Client ou Freelancer ────────────────────────────────────

class Step6UserTypePage extends StatefulWidget {
  final RegistrationData data;

  const Step6UserTypePage({super.key, required this.data});

  @override
  State<Step6UserTypePage> createState() => _Step6UserTypePageState();
}

class _Step6UserTypePageState extends State<Step6UserTypePage> {
  UserType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      currentStep: 6,
      totalSteps: 7,
      title: 'Qui êtes-vous ?',
      subtitle: 'Choisissez votre type de compte',
      buttonLabel: 'Continuer',
      isButtonEnabled: _selectedType != null,
      onBack: () => Navigator.pop(context),
      onButtonPressed: _selectedType != null ? _goToNextStep : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColors.warning, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Client ↔ Freelancer : basculez quand vous voulez',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ...UserType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: UserTypeCard(
                userType: type,
                isSelected: _selectedType == type,
                onTap: () => setState(() => _selectedType = type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    widget.data.userType = _selectedType;

    if (_selectedType == UserType.freelancer) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Step7PhotoPage(data: widget.data)),
      );
    } else {
      // Client → inscription terminée
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationSuccessPage(data: widget.data),
        ),
        (_) => false,
      );
    }
  }
}

// ─── Page de succès ───────────────────────────────────────────────────────────

class RegistrationSuccessPage extends StatelessWidget {
  final RegistrationData data;

  const RegistrationSuccessPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.verifiedBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 70,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenue ${data.firstName} !',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Votre compte a été créé avec succès.\nVous pouvez maintenant utiliser Inkern.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _SuccessButton(data: data),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessButton extends StatefulWidget {
  final RegistrationData data;
  const _SuccessButton({required this.data});

  @override
  State<_SuccessButton> createState() => _SuccessButtonState();
}

class _SuccessButtonState extends State<_SuccessButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Commencer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().register(widget.data);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      // error handled silently
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootNav()),
        (_) => false,
      );
    }
  }
}
