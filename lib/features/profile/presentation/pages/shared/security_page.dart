import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/shared/change_password_bottom_sheet.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text('Sécurité', style: context.profilePageTitleStyle),
        centerTitle: true,
      ),
      body: AppPageBody(
        padding: AppInsets.a16,
        useSafeAreaBottom: true,
        child: ListView(
          children: [
          // ─── Mot de passe ───
          _SectionCard(
            icon: Icons.lock_rounded,
            iconColor: Colors.red,
            title: 'Mot de passe',
            children: [
              _InfoRow(
                label: 'Dernier changement',
                value: 'Il y a 3 mois',
              ),
              AppGap.h16,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () => _showChangePasswordSheet(context),
                  icon: Icons.edit_rounded,
                  label: 'Changer le mot de passe',
                  variant: ButtonVariant.outline,
                ),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Authentification à deux facteurs ───
          _SectionCard(
            icon: Icons.security_rounded,
            iconColor: Colors.deepOrange,
            title: 'Authentification à deux facteurs (2FA)',
            children: [
              AppInfoBanner(
                icon: _twoFactorEnabled
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                message: _twoFactorEnabled
                    ? 'Votre compte est protégé par la 2FA'
                    : 'Activez la 2FA pour plus de sécurité',
                color: _twoFactorEnabled
                    ? AppColors.primary
                    : AppColors.warning,
              ),
              AppGap.h16,
              _ToggleRow(
                title: 'Activer la 2FA',
                subtitle: 'Recevoir un code par SMS ou email',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  if (value) {
                    _showSetup2FASheet(context);
                  } else {
                    setState(() => _twoFactorEnabled = false);
                  }
                },
              ),
              if (_twoFactorEnabled) ...[
                const Divider(height: 24),
                _MethodTile(
                  icon: Icons.sms_rounded,
                  title: 'SMS',
                  subtitle: '+33 6 ** ** ** 78',
                  isActive: true,
                ),
                AppGap.h8,
                _MethodTile(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  subtitle: 't.m****@email.com',
                  isActive: false,
                ),
              ],
            ],
          ),

          AppGap.h16,

          // ─── Biométrie ───
          _SectionCard(
            icon: Icons.fingerprint_rounded,
            iconColor: Colors.purple,
            title: 'Connexion biométrique',
            children: [
              _ToggleRow(
                title: 'Face ID / Touch ID',
                subtitle: 'Se connecter avec la biométrie',
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Appareils connectés ───
          _SectionCard(
            icon: Icons.devices_rounded,
            iconColor: Colors.cyan,
            title: 'Appareils connectés',
            children: [
              _DeviceTile(
                icon: Icons.phone_iphone_rounded,
                name: 'iPhone 14 Pro',
                location: 'Paris, France',
                lastActive: 'Actif maintenant',
                isCurrent: true,
              ),
              AppGap.h12,
              _DeviceTile(
                icon: Icons.laptop_mac_rounded,
                name: 'MacBook Pro',
                location: 'Paris, France',
                lastActive: 'Il y a 2 heures',
                isCurrent: false,
              ),
              AppGap.h16,
              AppButton(
                label: 'Déconnecter tous les appareils',
                variant: ButtonVariant.ghost,
                icon: Icons.logout_rounded,
                onPressed: () => _showDisconnectAllDialog(context),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Historique de connexion ───
          _SectionCard(
            icon: Icons.history_rounded,
            iconColor: AppColors.secondary,
            title: 'Historique de connexion',
            children: [
              _LoginHistoryTile(
                date: 'Aujourd\'hui, 14:32',
                location: 'Paris, France',
                device: 'iPhone 14 Pro',
                isSuccess: true,
              ),
              const Divider(height: 16),
              _LoginHistoryTile(
                date: 'Hier, 09:15',
                location: 'Paris, France',
                device: 'MacBook Pro',
                isSuccess: true,
              ),
              const Divider(height: 16),
              _LoginHistoryTile(
                date: '25 Nov, 18:42',
                location: 'Lyon, France',
                device: 'Inconnu',
                isSuccess: false,
              ),
              AppGap.h12,
              Center(
                child: AppButton(
                  label: 'Voir tout l\'historique',
                  variant: ButtonVariant.ghost,
                  width: null,
                  onPressed: () {},
                ),
              ),
            ],
          ),

          AppGap.h32,
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) =>
      showChangePasswordBottomSheet(context);

  void _showSetup2FASheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) {
        return AppPickerSheet(
          title: 'Double authentification',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorEnabled = true);
                },
                child: const AppRoundIconTile(
                  icon: Icons.sms_rounded,
                  iconColor: AppColors.primary,
                  title: 'SMS',
                  subtitle: 'Recevoir un code par SMS',
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorEnabled = true);
                },
                child: const AppRoundIconTile(
                  icon: Icons.email_rounded,
                  iconColor: AppColors.primary,
                  title: 'Email',
                  subtitle: 'Recevoir un code par email',
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorEnabled = true);
                },
                child: const AppRoundIconTile(
                  icon: Icons.lock_rounded,
                  iconColor: AppColors.primary,
                  title: 'Application d\'authentification',
                  subtitle: 'Google Authenticator, Authy...',
                ),
              ),
            ],
          ),
          footer: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16 + MediaQuery.of(context).padding.bottom),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: context.profileTertiaryStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDisconnectAllDialog(BuildContext context) {
    showAppDialog(
      context: context,
      title: const Text('Déconnecter tous les appareils ?'),
      content: const Text(
        'Vous serez déconnecté de tous vos appareils sauf celui-ci.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Déconnecter',
      confirmVariant: ButtonVariant.destructive,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Widgets auxiliaires
// ═══════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: AppInsets.a20,
      border: Border.all(color: context.colors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: AppInsets.a10,
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Icon(icon, color: iconColor),
              ),
              AppGap.w14,
              Text(title, style: context.profileSectionTitleStyle),
            ],
          ),
          AppGap.h20,
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: context.profileSecondaryLabelStyle),
        const Spacer(),
        Text(value, style: context.profileValueStyle),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.profilePrimaryLabelStyle),
              Text(subtitle, style: context.profileSecondaryLabelStyle),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a12,
      decoration: BoxDecoration(
        color: isActive ? context.colors.successLight : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: isActive ? Border.all(color: AppColors.primary) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? AppColors.primary : context.colors.textSecondary),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.profilePrimaryLabelStyle),
                Text(subtitle, style: context.profileSecondaryLabelStyle),
              ],
            ),
          ),
          if (isActive)
            AppSurfaceCard(
              padding: AppInsets.h8v4,
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Text('Actif', style: context.profileTagStyle),
            ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const _DeviceTile({
    required this.icon,
    required this.name,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: AppInsets.a12,
      color: isCurrent ? context.colors.successLight : context.colors.background,
      borderRadius: BorderRadius.circular(AppRadius.input),
      border: isCurrent ? Border.all(color: AppColors.primary) : null,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Icon(icon, color: context.colors.textSecondary),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: context.profileValueStyle),
                    if (isCurrent) ...[
                      AppGap.w8,
                      AppSurfaceCard(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.tag),
                        child: Text('Cet appareil', style: context.profileTagStyle.copyWith(fontSize: AppFontSize.tiny)),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$location • $lastActive',
                  style: context.profileMetaStyle,
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: context.colors.textHint,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _LoginHistoryTile extends StatelessWidget {
  final String date;
  final String location;
  final String device;
  final bool isSuccess;

  const _LoginHistoryTile({
    required this.date,
    required this.location,
    required this.device,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSurfaceCard(
          padding: AppInsets.a8,
          color: isSuccess ? context.colors.successLight : AppColors.error.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            size: 16,
            color: isSuccess ? AppColors.primary : Colors.red,
          ),
        ),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: context.profileValueStyle),
              Text(
                '$device • $location',
                style: context.profileMetaStyle,
              ),
            ],
          ),
        ),
        Text(
          isSuccess ? 'Réussi' : 'Échoué',
          style: context.text.labelMedium?.copyWith(
            color: isSuccess ? AppColors.primary : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _StrengthBar(isActive: true, color: Colors.red)),
            AppGap.w4,
            Expanded(child: _StrengthBar(isActive: true, color: Colors.orange)),
            AppGap.w4,
            Expanded(child: _StrengthBar(isActive: true, color: AppColors.success)),
            AppGap.w4,
            Expanded(child: _StrengthBar(isActive: false, color: AppColors.success)),
          ],
        ),
        AppGap.h8,
        Text(
          'Force du mot de passe : Bon',
          style: context.profileMetaStyle,
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _StrengthBar({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? color : context.colors.border,
        borderRadius: BorderRadius.circular(AppRadius.micro),
      ),
    );
  }
}

class _Setup2FAOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Setup2FAOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Container(
        padding: AppInsets.a16,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            AppSurfaceCard(
              padding: AppInsets.a10,
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.input),
              child: Icon(icon, color: AppColors.primary),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.profilePrimaryLabelStyle),
                  Text(subtitle, style: context.profileSecondaryLabelStyle),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
          ],
        ),
      ),
    );
  }
}
