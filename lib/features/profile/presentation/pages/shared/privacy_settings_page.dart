import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

/// Page Confidentialité
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Visibilité du profil
  ProfileVisibility _profileVisibility = ProfileVisibility.public;
  
  // Paramètres de confidentialité
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _showLocation = true;
  bool _showPhone = false;
  bool _showEmail = false;
  bool _allowMessages = true;
  bool _allowReviews = true;
  
  // Paramètres de données
  bool _shareAnalytics = true;
  bool _personalizedAds = false;
  bool _locationHistory = true;
  bool _searchHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Confidentialité',
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: AppInsets.a16,
        children: [
          // Info card
          _buildInfoCard(),

          AppGap.h20,

          // Visibilité du profil
          _buildSectionTitle('Visibilité du profil'),
          AppGap.h12,
          _buildVisibilityCard(),

          AppGap.h20,

          // Informations visibles
          _buildSectionTitle('Informations visibles'),
          AppGap.h12,
          _buildVisibleInfoCard(),

          AppGap.h20,

          // Interactions
          _buildSectionTitle('Interactions'),
          AppGap.h12,
          _buildInteractionsCard(),

          AppGap.h20,

          // Données et personnalisation
          _buildSectionTitle('Données et personnalisation'),
          AppGap.h12,
          _buildDataCard(),

          AppGap.h20,

          // Actions sur les données
          _buildSectionTitle('Mes données'),
          AppGap.h12,
          _buildDataActionsCard(),

          AppGap.h32,
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha:0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Icon(Icons.shield_rounded, color: AppColors.info, size: 24),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données sont protégées',
                  style: context.text.titleSmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                AppGap.h4,
                Text(
                  'Contrôlez qui peut voir vos informations et comment vos données sont utilisées.',
                  style: context.text.bodySmall?.copyWith(
                    color: AppColors.info,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: context.text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildVisibilityOption(
            ProfileVisibility.public,
            'Public',
            'Tout le monde peut voir votre profil',
            Icons.public_rounded,
            AppColors.success,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: context.colors.divider),
          _buildVisibilityOption(
            ProfileVisibility.registered,
            'Membres uniquement',
            'Seuls les utilisateurs inscrits peuvent vous voir',
            Icons.people_rounded,
            AppColors.info,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: context.colors.divider),
          _buildVisibilityOption(
            ProfileVisibility.contacts,
            'Contacts uniquement',
            'Seuls vos contacts peuvent voir votre profil',
            Icons.person_rounded,
            Colors.orange,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: context.colors.divider),
          _buildVisibilityOption(
            ProfileVisibility.hidden,
            'Masqué',
            'Votre profil n\'apparaît pas dans les recherches',
            Icons.visibility_off_rounded,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption(
    ProfileVisibility value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _profileVisibility == value;
    return InkWell(
      onTap: () => setState(() => _profileVisibility = value),
      child: Padding(
        padding: AppInsets.a16,
        child: Row(
          children: [
            Container(
              padding: AppInsets.a10,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.text.labelMedium,
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.colors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibleInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildSwitchItem(
            icon: Icons.circle,
            iconColor: AppColors.success,
            title: 'Statut en ligne',
            subtitle: 'Afficher quand vous êtes connecté',
            value: _showOnlineStatus,
            onChanged: (v) => setState(() => _showOnlineStatus = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.info,
            title: 'Dernière connexion',
            subtitle: 'Afficher votre dernière activité',
            value: _showLastSeen,
            onChanged: (v) => setState(() => _showLastSeen = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red,
            title: 'Localisation',
            subtitle: 'Afficher votre ville sur votre profil',
            value: _showLocation,
            onChanged: (v) => setState(() => _showLocation = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.phone_rounded,
            iconColor: Colors.purple,
            title: 'Numéro de téléphone',
            subtitle: 'Visible uniquement après acceptation',
            value: _showPhone,
            onChanged: (v) => setState(() => _showPhone = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.email_rounded,
            iconColor: Colors.orange,
            title: 'Adresse email',
            subtitle: 'Visible uniquement après acceptation',
            value: _showEmail,
            onChanged: (v) => setState(() => _showEmail = v),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildSwitchItem(
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.primary,
            title: 'Messages',
            subtitle: 'Autoriser les autres à vous contacter',
            value: _allowMessages,
            onChanged: (v) => setState(() => _allowMessages = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            title: 'Avis',
            subtitle: 'Autoriser les clients à laisser des avis',
            value: _allowReviews,
            onChanged: (v) => setState(() => _allowReviews = v),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildSwitchItem(
            icon: Icons.analytics_rounded,
            iconColor: AppColors.secondary,
            title: 'Données analytiques',
            subtitle: 'Aider à améliorer l\'application',
            value: _shareAnalytics,
            onChanged: (v) => setState(() => _shareAnalytics = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.ads_click_rounded,
            iconColor: Colors.pink,
            title: 'Publicités personnalisées',
            subtitle: 'Recevoir des annonces adaptées à vos intérêts',
            value: _personalizedAds,
            onChanged: (v) => setState(() => _personalizedAds = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.history_rounded,
            iconColor: Colors.teal,
            title: 'Historique de localisation',
            subtitle: 'Enregistrer vos déplacements pour les missions',
            value: _locationHistory,
            onChanged: (v) => setState(() => _locationHistory = v),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildSwitchItem(
            icon: Icons.search_rounded,
            iconColor: AppColors.secondary,
            title: 'Historique de recherche',
            subtitle: 'Sauvegarder vos recherches récentes',
            value: _searchHistory,
            onChanged: (v) => setState(() => _searchHistory = v),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Padding(
      padding: AppInsets.h16v12,
      child: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.text.labelMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDataActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.download_rounded,
            iconColor: AppColors.success,
            title: 'Télécharger mes données',
            subtitle: 'Exporter toutes vos informations',
            onTap: () => _showDownloadDataSheet(),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildActionItem(
            icon: Icons.cleaning_services_rounded,
            iconColor: Colors.orange,
            title: 'Effacer l\'historique',
            subtitle: 'Supprimer recherches et activités',
            onTap: () => _showClearHistoryDialog(),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildActionItem(
            icon: Icons.block_rounded,
            iconColor: Colors.red,
            title: 'Utilisateurs bloqués',
            subtitle: '0 utilisateur bloqué',
            onTap: () => _showBlockedUsersSheet(),
          ),
          Divider(height: 1, indent: 58, color: context.colors.divider),
          _buildActionItem(
            icon: Icons.delete_forever_rounded,
            iconColor: Colors.red,
            title: 'Supprimer mes données',
            subtitle: 'Demander la suppression de vos données',
            onTap: () => _showDeleteDataDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppInsets.h16v14,
        child: Row(
          children: [
            Container(
              padding: AppInsets.a8,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.text.labelMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: context.colors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadDataSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Padding(
        padding: AppInsets.a20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            AppGap.h20,
            Container(
              padding: AppInsets.a16,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_rounded, color: AppColors.success, size: 40),
            ),
            AppGap.h16,
            Text(
              'Télécharger mes données',
              style: context.text.headlineMedium?.copyWith(),
            ),
            AppGap.h8,
            Text(
              'Vous recevrez un fichier contenant toutes vos données personnelles dans un délai de 24 à 48 heures.',
              style: context.text.bodyMedium?.copyWith(
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h20,

            // Ce qui sera inclus
            Container(
              padding: AppInsets.a16,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Le fichier contiendra :',
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGap.h10,
                  _buildIncludedItem('Informations du profil'),
                  _buildIncludedItem('Historique des missions'),
                  _buildIncludedItem('Messages et conversations'),
                  _buildIncludedItem('Avis reçus et donnés'),
                  _buildIncludedItem('Données de paiement'),
                ],
              ),
            ),

            AppGap.h24,
            AppButton(
              label: 'Recevoir par email',
              variant: ButtonVariant.primary,
              icon: Icons.email_rounded,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            AppGap.h12,
            AppButton(
              label: 'Annuler',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: AppInsets.v4,
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          AppGap.w8,
          Text(
            text,
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showAppDialog(
      context: context,
      title: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(Icons.cleaning_services_rounded, color: Colors.orange, size: 20),
          ),
          AppGap.w12,
          const Expanded(child: Text('Effacer l\'historique')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Que souhaitez-vous effacer ?'),
          AppGap.h16,
          _ClearOptionTile(
            title: 'Historique de recherche',
            subtitle: '24 recherches',
            icon: Icons.search_rounded,
          ),
          _ClearOptionTile(
            title: 'Services consultés',
            subtitle: '56 services',
            icon: Icons.visibility_rounded,
          ),
          _ClearOptionTile(
            title: 'Historique de localisation',
            subtitle: '12 lieux',
            icon: Icons.location_on_rounded,
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Tout effacer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  void _showBlockedUsersSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Padding(
        padding: AppInsets.a20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            AppGap.h20,
            Container(
              padding: AppInsets.a16,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block_rounded, color: context.colors.textHint, size: 40),
            ),
            AppGap.h16,
            Text(
              'Aucun utilisateur bloqué',
              style: context.text.headlineSmall?.copyWith(),
            ),
            AppGap.h8,
            Text(
              'Les utilisateurs que vous bloquez ne pourront plus vous contacter ni voir votre profil.',
              style: context.text.bodyMedium?.copyWith(
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h24,
            AppButton(
              label: 'Fermer',
              variant: ButtonVariant.outline,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showAppDialog(
      context: context,
      title: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
          ),
          AppGap.w12,
          const Expanded(child: Text('Supprimer mes données')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cette action est irréversible. Conformément au RGPD, vous pouvez demander la suppression de vos données personnelles.',
          ),
          AppGap.h16,
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: Colors.red.withValues(alpha:0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seront supprimés :',
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                AppGap.h8,
                _buildDeleteItem('Votre compte et profil'),
                _buildDeleteItem('Historique des missions'),
                _buildDeleteItem('Messages et conversations'),
                _buildDeleteItem('Avis et évaluations'),
              ],
            ),
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Continuer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        Navigator.pop(context);
        _showDeleteConfirmationSheet();
      },
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.remove_circle_outline, size: 14, color: AppColors.error),
          AppGap.w8,
          Text(
            text,
            style: context.text.labelMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationSheet() {
    final TextEditingController confirmController = TextEditingController();
    
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            AppGap.h20,
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            AppGap.h16,
            Text(
              'Confirmer la suppression',
              style: context.text.headlineMedium?.copyWith(),
            ),
            AppGap.h8,
            Text(
              'Tapez "SUPPRIMER" pour confirmer la suppression définitive de vos données.',
              style: context.text.bodyMedium?.copyWith(
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h20,
            TextField(
              controller: confirmController,
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'SUPPRIMER',
                hintStyle: context.text.bodyMedium?.copyWith(color: context.colors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            AppGap.h24,
            AppButton(
              label: 'Supprimer définitivement',
              variant: ButtonVariant.destructive,
              onPressed: () {
                if (confirmController.text == 'SUPPRIMER') {
                  Navigator.pop(context);
                }
              },
            ),
            AppGap.h12,
            AppButton(
              label: 'Annuler',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        ),
      ),
    );
  }

}

/// Enum pour la visibilité du profil
enum ProfileVisibility {
  public,
  registered,
  contacts,
  hidden,
}

/// Widget pour les options d'effacement
class _ClearOptionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ClearOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_ClearOptionTile> createState() => _ClearOptionTileState();
}

class _ClearOptionTileState extends State<_ClearOptionTile> {
  bool _isSelected = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.v6,
      child: InkWell(
        onTap: () => setState(() => _isSelected = !_isSelected),
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          padding: AppInsets.a12,
          decoration: BoxDecoration(
            color: _isSelected ? AppColors.primary.withValues(alpha:0.05) : context.colors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: _isSelected ? AppColors.primary.withValues(alpha:0.3) : context.colors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: _isSelected ? AppColors.primary : context.colors.textTertiary),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _isSelected ? context.colors.textPrimary : context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: _isSelected,
                onChanged: (v) => setState(() => _isSelected = v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}