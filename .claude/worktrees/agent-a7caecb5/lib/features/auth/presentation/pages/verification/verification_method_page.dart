import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/primary_button.dart';
import 'otp_verification_page.dart';

enum VerificationMethod { sms, email }

class VerificationMethodPage extends StatefulWidget {
  final RegistrationData data;
  final Widget? nextPage;
  final VoidCallback? onVerified;

  const VerificationMethodPage({
    super.key,
    required this.data,
    this.nextPage,
    this.onVerified,
  });

  @override
  State<VerificationMethodPage> createState() => _VerificationMethodPageState();
}

class _VerificationMethodPageState extends State<VerificationMethodPage> {
  VerificationMethod? _selectedMethod;
  bool _isLoading = false;

  bool get _hasPhone =>
      widget.data.phone != null && widget.data.phone!.isNotEmpty;

  String get _maskedPhone {
    final phone = widget.data.phone ?? '';
    if (phone.length < 4) return phone;
    return '+33 ${phone.substring(0, 2)} •• •• •• ${phone.substring(phone.length - 2)}';
  }

  String get _maskedEmail {
    final email = widget.data.email ?? '';
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name.substring(0, 2)}${'•' * (name.length - 2)}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vérification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comment souhaitez-vous recevoir votre code ?',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              if (_hasPhone) ...[
                _MethodCard(
                  icon: Icons.sms_rounded,
                  title: 'Par SMS',
                  subtitle: _maskedPhone,
                  isSelected: _selectedMethod == VerificationMethod.sms,
                  onTap: () =>
                      setState(() => _selectedMethod = VerificationMethod.sms),
                ),
                const SizedBox(height: 16),
              ],

              _MethodCard(
                icon: Icons.email_rounded,
                title: 'Par Email',
                subtitle: _maskedEmail,
                isSelected: _selectedMethod == VerificationMethod.email,
                onTap: () =>
                    setState(() => _selectedMethod = VerificationMethod.email),
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
                    Icon(Icons.info_rounded, color: AppColors.info, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un code à 6 chiffres vous sera envoyé',
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

              const Spacer(),

              PrimaryButton(
                label: 'Envoyer le code',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                isEnabled: _selectedMethod != null,
                onPressed: _selectedMethod != null ? _sendCode : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            data: widget.data,
            method: _selectedMethod!,
            nextPage: widget.nextPage,
            onVerified: widget.onVerified,
          ),
        ),
      );
    }
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.verifiedBg : AppColors.chipBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
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
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
