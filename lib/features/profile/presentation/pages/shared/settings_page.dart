import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/theme_provider.dart';
import 'wallet_page.dart';
import 'notifications_settings_page.dart';
import 'account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppPageAppBar(
        leading: AppBackButtonLeading(),
        title: 'Paramètres',
        centerTitle: true,
      ),
      body: AppPageBody(
        padding: AppInsets.a16,
        useSafeAreaBottom: true,
        child: ListView(
          children: [
          // ─── Compte ───
          _SectionTitle(title: 'Compte'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.person_rounded,
                title: 'Informations personnelles',
                subtitle: 'Nom, email, téléphone',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.lock_rounded,
                title: 'Mot de passe et sécurité',
                subtitle: 'Changer le mot de passe, 2FA',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.badge_rounded,
                title: 'Vérification d\'identité',
                subtitle: 'Compte vérifié ✓',
                trailing: _VerifiedBadge(),
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── Paiements ───
          _SectionTitle(title: 'Paiements'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Portefeuille',
                subtitle: 'Solde : 245,50 €',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletPage()),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.credit_card_rounded,
                title: 'Finance',
                subtitle: '•••• 4242',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.account_balance_rounded,
                title: 'Coordonnées bancaires',
                subtitle: 'IBAN •••• 1234',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.receipt_long_rounded,
                title: 'Historique des transactions',
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── Notifications ───
          _SectionTitle(title: 'Notifications'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.notifications_rounded,
                title: 'Préférences de notifications',
                subtitle: 'Push, email, SMS',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsSettingsPage()),
                  );
                },
              ),
            ],
          ),

          AppGap.h24,

          // ─── Préférences ───
          _SectionTitle(title: 'Préférences'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.language_rounded,
                title: 'Langue',
                subtitle: 'Français',
                onTap: () => _showLanguageDialog(context),
              ),
              _SettingsItem(
                icon: Icons.dark_mode_rounded,
                title: 'Apparence',
                subtitle: 'App',
                onTap: () => _showThemeDialog(context),
              ),
              _SettingsItem(
                icon: Icons.location_on_rounded,
                title: 'Localisation',
                subtitle: 'Paris, France',
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── Confidentialité ───
          _SectionTitle(title: 'Confidentialité'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.visibility_rounded,
                title: 'Visibilité du profil',
                subtitle: 'Public',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.block_rounded,
                title: 'Utilisateurs bloqués',
                subtitle: '0 bloqué',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_rounded,
                title: 'Politique de confidentialité',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.description_rounded,
                title: 'Conditions d\'utilisation',
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── Support ───
          _SectionTitle(title: 'Support'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.help_rounded,
                title: 'Centre d\'aide',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.chat_rounded,
                title: 'Contacter le support',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.bug_report_rounded,
                title: 'Signaler un problème',
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── À propos ───
          _SectionTitle(title: 'À propos'),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.info_rounded,
                title: 'À propos de Inkern',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.star_rounded,
                title: 'Noter l\'application',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.share_rounded,
                title: 'Partager l\'application',
                onTap: () {},
              ),
            ],
          ),

          AppGap.h24,

          // ─── Déconnexion ───
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.logout_rounded,
                title: 'Déconnexion',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Supprimer compte ───
          Center(
            child: AppButton(
              label: 'Supprimer mon compte',
              variant: ButtonVariant.ghost,
              width: null,
              onPressed: () => _showDeleteAccountDialog(context),
            ),
          ),

          AppGap.h32,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showAppDialog(
      context: context,
      title: const Text('Langue'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(label: 'Français', code: 'fr', isSelected: true),
          _LanguageOption(label: 'English', code: 'en', isSelected: false),
          _LanguageOption(label: 'Español', code: 'es', isSelected: false),
          _LanguageOption(label: 'Deutsch', code: 'de', isSelected: false),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final current = context.read<ThemeProvider>().mode;
    showAppDialog(
      context: context,
      title: const Text('Apparence'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            icon: Icons.business_center_outlined,
            label: 'App',
            isSelected: current == AppThemeMode.app,
            onTap: () { context.read<ThemeProvider>().setMode(AppThemeMode.app); Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showAppDialog(
      context: context,
      title: const Text('Déconnexion'),
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
      cancelLabel: 'Annuler',
      confirmLabel: 'Déconnexion',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        Navigator.pop(context);
        context.read<AuthProvider>().logout();
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: context.text.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colors.textTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDesign.radius16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: 56, color: context.colors.divider),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        child: Padding(
          padding: AppInsets.h16v14,
          child: Row(
            children: [
              Container(
                padding: AppInsets.a8,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radius10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.text.bodySmall,
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: context.colors.textHint,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppTagPill(
      label: 'Vérifié',
      icon: Icons.verified_rounded,
      backgroundColor: context.colors.successLight,
      foregroundColor: context.colors.primary,
      padding: AppInsets.h8v4,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: context.colors.primary)
          : null,
      onTap: () => Navigator.pop(context),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? context.colors.primary : context.colors.textTertiary),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: context.colors.primary)
          : null,
      onTap: onTap,
    );
  }
}
