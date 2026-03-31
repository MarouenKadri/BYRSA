import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/auth_provider.dart';
import 'wallet_page.dart';
import 'notifications_settings_page.dart';
import 'account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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

          const SizedBox(height: 24),

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
                title: 'Moyens de paiement',
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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

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
                subtitle: 'Système',
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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

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

          const SizedBox(height: 16),

          // ─── Supprimer compte ───
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              child: Text(
                'Supprimer mon compte',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apparence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(icon: Icons.brightness_auto_rounded, label: 'Système', isSelected: true),
            _ThemeOption(icon: Icons.light_mode_rounded, label: 'Clair', isSelected: false),
            _ThemeOption(icon: Icons.dark_mode_rounded, label: 'Sombre', isSelected: false),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: 56, color: AppColors.divider),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textHint,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            'Vérifié',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
          ? Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () => Navigator.pop(context),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () => Navigator.pop(context),
    );
  }
}