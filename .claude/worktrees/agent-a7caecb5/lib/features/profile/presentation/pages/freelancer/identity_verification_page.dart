import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

/// Statut de vérification
enum VerificationStatus {
  notStarted,
  inProgress,
  pending,
  verified,
  rejected,
}

/// Type de document d'identité
enum DocumentType {
  idCard,
  passport,
  drivingLicense,
}

extension DocumentTypeExtension on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.idCard:
        return 'Carte d\'identité';
      case DocumentType.passport:
        return 'Passeport';
      case DocumentType.drivingLicense:
        return 'Permis de conduire';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.idCard:
        return Icons.badge_rounded;
      case DocumentType.passport:
        return Icons.menu_book_rounded;
      case DocumentType.drivingLicense:
        return Icons.directions_car_rounded;
    }
  }
}

/// Page Vérification d'identité
class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  // Simuler un statut (changer pour tester différents états)
  VerificationStatus _status = VerificationStatus.notStarted;

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
          'Vérification d\'identité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBodyForStatus(),
    );
  }

  Widget _buildBodyForStatus() {
    switch (_status) {
      case VerificationStatus.notStarted:
        return _buildNotStartedView();
      case VerificationStatus.inProgress:
        return _buildInProgressView();
      case VerificationStatus.pending:
        return _buildPendingView();
      case VerificationStatus.verified:
        return _buildVerifiedView();
      case VerificationStatus.rejected:
        return _buildRejectedView();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🆕 Vue: Non commencé
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotStartedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Vérifiez votre identité',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Augmentez la confiance des clients et accédez à toutes les fonctionnalités',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Avantages
          _buildBenefitsCard(),

          const SizedBox(height: 20),

          // Ce dont vous avez besoin
          _buildRequirementsCard(),

          const SizedBox(height: 20),

          // Informations sur le processus
          _buildProcessInfoCard(),

          const SizedBox(height: 24),

          // Bouton commencer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _status = VerificationStatus.inProgress);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Commencer la vérification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Note RGPD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos données sont sécurisées et traitées conformément au RGPD. Elles ne sont utilisées que pour vérifier votre identité.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pourquoi se faire vérifier ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.trending_up_rounded,
            AppColors.success,
            'Plus de missions',
            'Les clients préfèrent les profils vérifiés',
          ),
          _buildBenefitItem(
            Icons.workspace_premium_rounded,
            Colors.amber,
            'Badge vérifié',
            'Affichez un badge de confiance sur votre profil',
          ),
          _buildBenefitItem(
            Icons.payments_rounded,
            AppColors.info,
            'Paiements plus rapides',
            'Retirez vos gains plus rapidement',
          ),
          _buildBenefitItem(
            Icons.security_rounded,
            AppColors.secondary,
            'Sécurité renforcée',
            'Protégez votre compte contre les usurpations',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label,
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
        ],
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ce dont vous avez besoin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildRequirementItem(
            Icons.badge_rounded,
            'Pièce d\'identité',
            'Carte d\'identité, passeport ou permis de conduire',
          ),
          _buildRequirementItem(
            Icons.face_rounded,
            'Selfie',
            'Une photo de votre visage pour confirmer votre identité',
          ),
          _buildRequirementItem(
            Icons.lightbulb_rounded,
            'Bonne luminosité',
            'Un endroit bien éclairé pour des photos nettes',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label,
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
        ],
      ),
    );
  }

  Widget _buildProcessInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, color: AppColors.info, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processus rapide',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La vérification prend environ 2-3 minutes. Votre demande sera traitée sous 24-48 heures.',
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

  // ─────────────────────────────────────────────────────────────
  // 🔄 Vue: En cours (étapes)
  // ─────────────────────────────────────────────────────────────
  Widget _buildInProgressView() {
    return _VerificationStepsView(
      onComplete: () {
        setState(() => _status = VerificationStatus.pending);
      },
      onCancel: () {
        setState(() => _status = VerificationStatus.notStarted);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ⏳ Vue: En attente
  // ─────────────────────────────────────────────────────────────
  Widget _buildPendingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Animation/Illustration
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 80,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Vérification en cours',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Nous examinons vos documents. Vous recevrez une notification dès que la vérification sera terminée.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Timeline
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _buildTimelineItem(
                  'Documents soumis',
                  'Aujourd\'hui à 14:32',
                  Icons.check_circle_rounded,
                  AppColors.success,
                  isCompleted: true,
                ),
                _buildTimelineConnector(isActive: true),
                _buildTimelineItem(
                  'Vérification en cours',
                  'Délai estimé : 24-48h',
                  Icons.pending_rounded,
                  Colors.orange,
                  isActive: true,
                ),
                _buildTimelineConnector(isActive: false),
                _buildTimelineItem(
                  'Résultat',
                  'En attente',
                  Icons.circle_outlined,
                  Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info supplémentaire
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous recevrez une notification push et un email dès que votre vérification sera terminée.',
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

          const SizedBox(height: 24),

          // Bouton support
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contacter le support'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
            ),
          ),

          // Pour tester - À SUPPRIMER EN PROD
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => setState(() => _status = VerificationStatus.verified),
            child: const Text('(Test) Simuler vérification réussie'),
          ),
          TextButton(
            onPressed: () => setState(() => _status = VerificationStatus.rejected),
            child: const Text('(Test) Simuler vérification rejetée', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
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
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(
        width: 2,
        height: 30,
        color: isActive ? AppColors.warning.withOpacity(0.5) : AppColors.border,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ Vue: Vérifié
  // ─────────────────────────────────────────────────────────────
  Widget _buildVerifiedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Badge vérifié
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 80,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Identité vérifiée !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Félicitations ! Votre identité a été vérifiée avec succès. Vous bénéficiez maintenant de tous les avantages d\'un profil vérifié.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Détails de vérification
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _buildVerificationDetail(
                  'Statut',
                  'Vérifié',
                  Icons.check_circle_rounded,
                  AppColors.success,
                ),
                Divider(height: 24, color: AppColors.divider),
                _buildVerificationDetail(
                  'Date de vérification',
                  '15 Octobre 2024',
                  Icons.calendar_today_rounded,
                  AppColors.info,
                ),
                Divider(height: 24, color: AppColors.divider),
                _buildVerificationDetail(
                  'Document utilisé',
                  'Carte d\'identité',
                  Icons.badge_rounded,
                  AppColors.secondary,
                ),
                Divider(height: 24, color: AppColors.divider),
                _buildVerificationDetail(
                  'Validité',
                  'Permanente',
                  Icons.all_inclusive_rounded,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ce que ça débloque
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Avantages débloqués',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUnlockedFeature('Badge vérifié visible sur votre profil'),
                _buildUnlockedFeature('Priorité dans les résultats de recherche'),
                _buildUnlockedFeature('Retrait des gains sans délai'),
                _buildUnlockedFeature('Accès aux missions premium'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
              child: const Text('Retour au profil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationDetail(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label,
        ),
      ],
    );
  }

  Widget _buildUnlockedFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ❌ Vue: Rejeté
  // ─────────────────────────────────────────────────────────────
  Widget _buildRejectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icône erreur
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_rounded,
              size: 80,
              color: AppColors.error,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Vérification refusée',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Malheureusement, nous n\'avons pas pu vérifier votre identité. Veuillez consulter les raisons ci-dessous et réessayer.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Raisons du refus
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.error),
                    const SizedBox(width: 10),
                    const Text(
                      'Raisons du refus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRejectionReason(
                  'Document illisible',
                  'La photo de votre document n\'était pas assez nette.',
                ),
                _buildRejectionReason(
                  'Selfie non conforme',
                  'Le visage n\'était pas entièrement visible sur le selfie.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Conseils pour réessayer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Text(
                      'Conseils pour réessayer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem('Prenez les photos dans un endroit bien éclairé'),
                _buildTipItem('Assurez-vous que le document est entièrement visible'),
                _buildTipItem('Évitez les reflets et les ombres'),
                _buildTipItem('Regardez directement la caméra pour le selfie'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Boutons d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _status = VerificationStatus.inProgress);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer la vérification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contacter le support'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReason(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right_rounded, size: 20, color: AppColors.gold),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📋 Widget: Étapes de vérification
// ─────────────────────────────────────────────────────────────
class _VerificationStepsView extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _VerificationStepsView({
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<_VerificationStepsView> createState() => _VerificationStepsViewState();
}

class _VerificationStepsViewState extends State<_VerificationStepsView> {
  int _currentStep = 0;
  DocumentType? _selectedDocType;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _selfieUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Étape ${_currentStep + 1}/4',
                    style: AppTextStyles.label,
                  ),
                  const Spacer(),
                  Text(
                    _getStepTitle(_currentStep),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // Contenu de l'étape
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCurrentStep(),
          ),
        ),

        // Boutons navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                    ),
                    child: const Text('Précédent'),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  child: Text(_currentStep == 3 ? 'Soumettre' : 'Continuer'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Type de document';
      case 1:
        return 'Photo du document';
      case 2:
        return 'Selfie';
      case 3:
        return 'Confirmation';
      default:
        return '';
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedDocType != null;
      case 1:
        return _frontUploaded && (_selectedDocType == DocumentType.passport || _backUploaded);
      case 2:
        return _selfieUploaded;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildDocumentTypeStep();
      case 1:
        return _buildDocumentPhotoStep();
      case 2:
        return _buildSelfieStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  // Étape 1: Choix du type de document
  Widget _buildDocumentTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisissez votre document',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez le type de pièce d\'identité que vous souhaitez utiliser.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        ...DocumentType.values.map((type) => _buildDocumentTypeOption(type)),

        const SizedBox(height: 24),

        // Info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Le document doit être valide et non expiré. Les informations doivent être lisibles.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeOption(DocumentType type) {
    final isSelected = _selectedDocType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedDocType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                type.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Étape 2: Photo du document
  Widget _buildDocumentPhotoStep() {
    final needsBack = _selectedDocType != DocumentType.passport;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photographiez votre document',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Prenez une photo nette de votre ${_selectedDocType?.label.toLowerCase() ?? 'document'}.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Recto
        _buildUploadCard(
          title: 'Recto du document',
          subtitle: 'Face avec la photo',
          icon: Icons.credit_card_rounded,
          isUploaded: _frontUploaded,
          onUpload: () {
            setState(() => _frontUploaded = true);
          },
          onReset: () {
            setState(() => _frontUploaded = false);
          },
        ),

        if (needsBack) ...[
          const SizedBox(height: 16),
          // Verso
          _buildUploadCard(
            title: 'Verso du document',
            subtitle: 'Face arrière',
            icon: Icons.credit_card_rounded,
            isUploaded: _backUploaded,
            onUpload: () {
              setState(() => _backUploaded = true);
            },
            onReset: () {
              setState(() => _backUploaded = false);
            },
          ),
        ],

        const SizedBox(height: 24),

        // Conseils
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Conseils pour une bonne photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPhotoTip('Document entièrement visible'),
              _buildPhotoTip('Bonne luminosité, sans reflets'),
              _buildPhotoTip('Texte lisible et net'),
              _buildPhotoTip('Fond uni de préférence'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onReset,
  }) {
    return GestureDetector(
      onTap: isUploaded ? null : () => _showUploadOptionsSheet(onUpload),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.border,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                isUploaded ? Icons.check_rounded : icon,
                color: isUploaded ? AppColors.success : AppColors.textTertiary,
                size: 32,
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
                      color: isUploaded ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isUploaded ? 'Photo ajoutée ✓' : subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUploaded ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUploaded)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              )
            else
              IconButton(
                onPressed: onReset,
                icon: Icon(Icons.refresh_rounded, color: AppColors.textTertiary),
                tooltip: 'Reprendre',
              ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptionsSheet(VoidCallback onUpload) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
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
              
              const Text(
                'Ajouter une photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez comment ajouter votre document',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Option Scanner
              _buildUploadOptionTile(
                icon: Icons.camera_alt_rounded,
                title: 'Scanner',
                subtitle: 'Prendre une photo avec la caméra',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showCameraPreview(onUpload);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Option Galerie
              _buildUploadOptionTile(
                icon: Icons.photo_library_rounded,
                title: 'Galerie',
                subtitle: 'Choisir depuis vos photos',
                color: AppColors.info,
                onTap: () {
                  Navigator.pop(context);
                  onUpload();
                },
              ),
              
              const SizedBox(height: 12),
              
              // Option Fichiers
              _buildUploadOptionTile(
                icon: Icons.folder_rounded,
                title: 'Fichiers',
                subtitle: 'Parcourir vos documents',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  onUpload();
                },
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  void _showCameraPreview(VoidCallback onUpload) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Simuler un preview caméra
              Container(
                color: AppColors.textPrimary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aperçu caméra',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Cadre de scan
              Center(
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Stack(
                    children: [
                      // Coins décoratifs
                      Positioned(
                        top: -2,
                        left: -2,
                        child: _buildCorner(true, true),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: _buildCorner(true, false),
                      ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: _buildCorner(false, true),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: _buildCorner(false, false),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Instructions en haut
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: const Text(
                    'Placez votre document dans le cadre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              // Bouton fermer
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
              
              // Boutons en bas
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Flash
                    _buildCameraButton(
                      icon: Icons.flash_off_rounded,
                      onTap: () {},
                    ),
                    
                    // Capture
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onUpload();
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Retourner caméra
                    _buildCameraButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          left: isLeft ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          right: !isLeft ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildPhotoTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Étape 3: Selfie
  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prenez un selfie',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nous avons besoin d\'une photo de votre visage pour confirmer votre identité.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Zone selfie
        GestureDetector(
          onTap: () {
            setState(() => _selfieUploaded = true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: _selfieUploaded
                  ? AppColors.success.withOpacity(0.05)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
              border: Border.all(
                color: _selfieUploaded ? AppColors.success : AppColors.border,
                width: _selfieUploaded ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selfieUploaded
                        ? AppColors.success.withOpacity(0.1)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selfieUploaded ? Icons.check_rounded : Icons.face_rounded,
                    size: 64,
                    color: _selfieUploaded ? AppColors.success : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selfieUploaded ? 'Selfie ajouté !' : 'Appuyez pour prendre un selfie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selfieUploaded ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                if (_selfieUploaded) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _selfieUploaded = false),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reprendre'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Column(
            children: [
              _buildSelfieInstruction(
                Icons.wb_sunny_rounded,
                'Bonne luminosité',
                'Placez-vous face à une source de lumière',
              ),
              _buildSelfieInstruction(
                Icons.face_rounded,
                'Visage dégagé',
                'Retirez lunettes, chapeau, masque...',
              ),
              _buildSelfieInstruction(
                Icons.center_focus_strong_rounded,
                'Cadrage centré',
                'Gardez votre visage au centre de l\'écran',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelfieInstruction(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label,
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
        ],
      ),
    );
  }

  // Étape 4: Confirmation
  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vérifiez vos informations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Assurez-vous que tout est correct avant de soumettre.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Résumé
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              _buildConfirmationItem(
                'Type de document',
                _selectedDocType?.label ?? '',
                _selectedDocType?.icon ?? Icons.badge_rounded,
                AppColors.info,
              ),
              Divider(height: 24, color: AppColors.divider),
              _buildConfirmationItem(
                'Photo recto',
                'Ajoutée',
                Icons.image_rounded,
                AppColors.success,
              ),
              if (_selectedDocType != DocumentType.passport) ...[
                Divider(height: 24, color: AppColors.divider),
                _buildConfirmationItem(
                  'Photo verso',
                  'Ajoutée',
                  Icons.image_rounded,
                  AppColors.success,
                ),
              ],
              Divider(height: 24, color: AppColors.divider),
              _buildConfirmationItem(
                'Selfie',
                'Ajouté',
                Icons.face_rounded,
                AppColors.success,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Consentement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.divider!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_rounded, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'En soumettant ces documents, vous acceptez que Inkern traite vos données personnelles à des fins de vérification d\'identité conformément à notre politique de confidentialité.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Délai
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Délai de traitement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Votre demande sera traitée sous 24 à 48 heures.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTextStyles.label,
            ),
            const SizedBox(width: 6),
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          ],
        ),
      ],
    );
  }
}