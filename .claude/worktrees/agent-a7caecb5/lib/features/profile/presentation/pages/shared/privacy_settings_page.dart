import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confidentialité',
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
          // Info card
          _buildInfoCard(),

          const SizedBox(height: 20),

          // Visibilité du profil
          _buildSectionTitle('Visibilité du profil'),
          const SizedBox(height: 12),
          _buildVisibilityCard(),

          const SizedBox(height: 20),

          // Informations visibles
          _buildSectionTitle('Informations visibles'),
          const SizedBox(height: 12),
          _buildVisibleInfoCard(),

          const SizedBox(height: 20),

          // Interactions
          _buildSectionTitle('Interactions'),
          const SizedBox(height: 12),
          _buildInteractionsCard(),

          const SizedBox(height: 20),

          // Données et personnalisation
          _buildSectionTitle('Données et personnalisation'),
          const SizedBox(height: 12),
          _buildDataCard(),

          const SizedBox(height: 20),

          // Actions sur les données
          _buildSectionTitle('Mes données'),
          const SizedBox(height: 12),
          _buildDataActionsCard(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shield_rounded, color: AppColors.info, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données sont protégées',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contrôlez qui peut voir vos informations et comment vos données sont utilisées.',
                  style: TextStyle(
                    fontSize: 13,
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildVisibilityCard() {
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
          _buildVisibilityOption(
            ProfileVisibility.public,
            'Public',
            'Tout le monde peut voir votre profil',
            Icons.public_rounded,
            AppColors.success,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
          _buildVisibilityOption(
            ProfileVisibility.registered,
            'Membres uniquement',
            'Seuls les utilisateurs inscrits peuvent vous voir',
            Icons.people_rounded,
            AppColors.info,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
          _buildVisibilityOption(
            ProfileVisibility.contacts,
            'Contacts uniquement',
            'Seuls vos contacts peuvent voir votre profil',
            Icons.person_rounded,
            Colors.orange,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
                  color: isSelected ? AppColors.primary : AppColors.textHint,
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
          _buildSwitchItem(
            icon: Icons.circle,
            iconColor: AppColors.success,
            title: 'Statut en ligne',
            subtitle: 'Afficher quand vous êtes connecté',
            value: _showOnlineStatus,
            onChanged: (v) => setState(() => _showOnlineStatus = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildSwitchItem(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.info,
            title: 'Dernière connexion',
            subtitle: 'Afficher votre dernière activité',
            value: _showLastSeen,
            onChanged: (v) => setState(() => _showLastSeen = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildSwitchItem(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red,
            title: 'Localisation',
            subtitle: 'Afficher votre ville sur votre profil',
            value: _showLocation,
            onChanged: (v) => setState(() => _showLocation = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildSwitchItem(
            icon: Icons.phone_rounded,
            iconColor: Colors.purple,
            title: 'Numéro de téléphone',
            subtitle: 'Visible uniquement après acceptation',
            value: _showPhone,
            onChanged: (v) => setState(() => _showPhone = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
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
          _buildSwitchItem(
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.primary,
            title: 'Messages',
            subtitle: 'Autoriser les autres à vous contacter',
            value: _allowMessages,
            onChanged: (v) => setState(() => _allowMessages = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
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
          _buildSwitchItem(
            icon: Icons.analytics_rounded,
            iconColor: AppColors.secondary,
            title: 'Données analytiques',
            subtitle: 'Aider à améliorer l\'application',
            value: _shareAnalytics,
            onChanged: (v) => setState(() => _shareAnalytics = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildSwitchItem(
            icon: Icons.ads_click_rounded,
            iconColor: Colors.pink,
            title: 'Publicités personnalisées',
            subtitle: 'Recevoir des annonces adaptées à vos intérêts',
            value: _personalizedAds,
            onChanged: (v) => setState(() => _personalizedAds = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildSwitchItem(
            icon: Icons.history_rounded,
            iconColor: Colors.teal,
            title: 'Historique de localisation',
            subtitle: 'Enregistrer vos déplacements pour les missions',
            value: _locationHistory,
            onChanged: (v) => setState(() => _locationHistory = v),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
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
          _buildActionItem(
            icon: Icons.download_rounded,
            iconColor: AppColors.success,
            title: 'Télécharger mes données',
            subtitle: 'Exporter toutes vos informations',
            onTap: () => _showDownloadDataSheet(),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildActionItem(
            icon: Icons.cleaning_services_rounded,
            iconColor: Colors.orange,
            title: 'Effacer l\'historique',
            subtitle: 'Supprimer recherches et activités',
            onTap: () => _showClearHistoryDialog(),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
          _buildActionItem(
            icon: Icons.block_rounded,
            iconColor: Colors.red,
            title: 'Utilisateurs bloqués',
            subtitle: '0 utilisateur bloqué',
            onTap: () => _showBlockedUsersSheet(),
          ),
          Divider(height: 1, indent: 58, color: AppColors.divider),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
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
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadDataSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_rounded, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Télécharger mes données',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous recevrez un fichier contenant toutes vos données personnelles dans un délai de 24 à 48 heures.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Ce qui sera inclus
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Le fichier contiendra :',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildIncludedItem('Informations du profil'),
                  _buildIncludedItem('Historique des missions'),
                  _buildIncludedItem('Messages et conversations'),
                  _buildIncludedItem('Avis reçus et donnés'),
                  _buildIncludedItem('Données de paiement'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.email_rounded, size: 20),
                label: const Text('Recevoir par email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cleaning_services_rounded, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Effacer l\'historique')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Que souhaitez-vous effacer ?'),
            const SizedBox(height: 16),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block_rounded, color: AppColors.textHint, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun utilisateur bloqué',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les utilisateurs que vous bloquez ne pourront plus vous contacter ni voir votre profil.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seront supprimés :',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDeleteItem('Votre compte et profil'),
                  _buildDeleteItem('Historique des missions'),
                  _buildDeleteItem('Messages et conversations'),
                  _buildDeleteItem('Avis et évaluations'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationSheet();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.remove_circle_outline, size: 14, color: AppColors.error),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationSheet() {
    final TextEditingController confirmController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Confirmer la suppression',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tapez "SUPPRIMER" pour confirmer la suppression définitive de vos données.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'SUPPRIMER',
                hintStyle: TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (confirmController.text == 'SUPPRIMER') {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Supprimer définitivement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _isSelected = !_isSelected),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: _isSelected ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}