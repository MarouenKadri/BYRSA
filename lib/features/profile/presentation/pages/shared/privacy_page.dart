import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  // Visibilité profil
  String _profileVisibility = 'public';
  
  // Paramètres de confidentialité
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _showLocation = true;
  bool _showPhone = false;
  bool _showEmail = false;
  
  // Données et publicités
  bool _personalizedAds = true;
  bool _analyticsEnabled = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text('Confidentialité', style: context.profilePageTitleStyle),
        centerTitle: true,
      ),
      body: AppPageBody(
        padding: AppInsets.a16,
        useSafeAreaBottom: true,
        child: ListView(
          children: [
          // ─── Visibilité du profil ───
          _SectionCard(
            icon: Icons.visibility_rounded,
            iconColor: AppColors.info,
            title: 'Visibilité du profil',
            children: [
              _RadioOption(
                title: 'Public',
                subtitle: 'Tout le monde peut voir votre profil',
                value: 'public',
                groupValue: _profileVisibility,
                onChanged: (value) => setState(() => _profileVisibility = value!),
              ),
              _RadioOption(
                title: 'Clients uniquement',
                subtitle: 'Seuls les clients connectés peuvent voir',
                value: 'clients',
                groupValue: _profileVisibility,
                onChanged: (value) => setState(() => _profileVisibility = value!),
              ),
              _RadioOption(
                title: 'Privé',
                subtitle: 'Uniquement visible par vos contacts',
                value: 'private',
                groupValue: _profileVisibility,
                onChanged: (value) => setState(() => _profileVisibility = value!),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Informations visibles ───
          _SectionCard(
            icon: Icons.person_rounded,
            iconColor: AppColors.success,
            title: 'Informations visibles',
            children: [
              _ToggleRow(
                icon: Icons.circle,
                iconColor: AppColors.success,
                title: 'Statut en ligne',
                subtitle: 'Montrer quand vous êtes en ligne',
                value: _showOnlineStatus,
                onChanged: (v) => setState(() => _showOnlineStatus = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.access_time_rounded,
                iconColor: Colors.orange,
                title: 'Dernière connexion',
                subtitle: 'Afficher votre dernière activité',
                value: _showLastSeen,
                onChanged: (v) => setState(() => _showLastSeen = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.location_on_rounded,
                iconColor: Colors.red,
                title: 'Localisation',
                subtitle: 'Afficher votre ville',
                value: _showLocation,
                onChanged: (v) => setState(() => _showLocation = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.phone_rounded,
                iconColor: AppColors.info,
                title: 'Numéro de téléphone',
                subtitle: 'Visible sur votre profil public',
                value: _showPhone,
                onChanged: (v) => setState(() => _showPhone = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.email_rounded,
                iconColor: Colors.purple,
                title: 'Adresse email',
                subtitle: 'Visible sur votre profil public',
                value: _showEmail,
                onChanged: (v) => setState(() => _showEmail = v),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Utilisateurs bloqués ───
          _SectionCard(
            icon: Icons.block_rounded,
            iconColor: Colors.red,
            title: 'Utilisateurs bloqués',
            children: [
              AppSurfaceCard(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppDesign.radius12),
                child: Row(
                  children: [
                    Icon(Icons.person_off_rounded, color: context.colors.textHint, size: 40),
                    AppGap.w16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aucun utilisateur bloqué',
                            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Les utilisateurs bloqués ne peuvent pas vous contacter',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h12,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () {},
                  label: 'Gérer les utilisateurs bloqués',
                  variant: ButtonVariant.outline,
                ),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Données et publicités ───
          _SectionCard(
            icon: Icons.analytics_rounded,
            iconColor: Colors.orange,
            title: 'Données et publicités',
            children: [
              _ToggleRow(
                icon: Icons.ads_click_rounded,
                iconColor: Colors.orange,
                title: 'Publicités personnalisées',
                subtitle: 'Basées sur votre activité',
                value: _personalizedAds,
                onChanged: (v) => setState(() => _personalizedAds = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.info,
                title: 'Statistiques d\'utilisation',
                subtitle: 'Nous aider à améliorer l\'app',
                value: _analyticsEnabled,
                onChanged: (v) => setState(() => _analyticsEnabled = v),
              ),
              const Divider(height: 20),
              _ToggleRow(
                icon: Icons.mail_outline_rounded,
                iconColor: Colors.purple,
                title: 'Emails marketing',
                subtitle: 'Offres et nouveautés Inkern',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),
            ],
          ),

          AppGap.h16,

          // ─── Mes données ───
          _SectionCard(
            icon: Icons.folder_rounded,
            iconColor: AppColors.secondary,
            title: 'Mes données',
            children: [
              _ActionTile(
                icon: Icons.download_rounded,
                title: 'Télécharger mes données',
                subtitle: 'Obtenir une copie de vos données',
                onTap: () => _showDownloadDataDialog(context),
              ),
              const Divider(height: 16),
              _ActionTile(
                icon: Icons.delete_sweep_rounded,
                title: 'Effacer mes données',
                subtitle: 'Supprimer l\'historique de recherche',
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),

          AppGap.h32,
          ],
        ),
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    showAppDialog(
      context: context,
      title: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.download_rounded, color: AppColors.info),
          ),
          AppGap.w12,
          const Expanded(child: Text('Télécharger mes données')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vous recevrez un fichier contenant :'),
          AppGap.h12,
          _DataItem(text: 'Informations de profil'),
          _DataItem(text: 'Historique des missions'),
          _DataItem(text: 'Messages et conversations'),
          _DataItem(text: 'Transactions et paiements'),
          _DataItem(text: 'Avis reçus et donnés'),
          AppGap.h16,
          Text(
            'Le fichier sera envoyé à votre adresse email sous 24h.',
            style: context.text.bodySmall,
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Demander',
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showAppDialog(
      context: context,
      title: const Text('Effacer les données ?'),
      content: const Text(
        'Cette action effacera votre historique de recherche et vos données de navigation. Vos missions et avis seront conservés.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Effacer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        Navigator.pop(context);
      },
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: AppInsets.a10,
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppDesign.radius12),
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

class _RadioOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: AppInsets.a14,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.successLight : context.colors.background,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            AppGap.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.profilePrimaryLabelStyle.copyWith(
                      color: isSelected ? AppColors.primary : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.profileMetaStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.profilePrimaryLabelStyle),
              Text(subtitle, style: context.profileMetaStyle),
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: context.colors.textSecondary),
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
    );
  }
}

class _DataItem extends StatelessWidget {
  final String text;

  const _DataItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.v4,
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
          AppGap.w8,
          Text(text, style: context.text.bodyMedium?.copyWith(fontSize: AppFontSize.base, color: context.colors.textPrimary)),
        ],
      ),
    );
  }
}
