import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

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
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Vérification d\'identité',
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
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
      padding: AppInsets.a16,
      child: Column(
        children: [
          // Header illustration
          Container(
            width: double.infinity,
            padding: AppInsets.a32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha:0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
            ),
            child: Column(
              children: [
                Container(
                  padding: AppInsets.a20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                AppGap.h20,
                Text(
                  'Vérifiez votre identité',
                  style: context.text.displaySmall?.copyWith(color: Colors.white),
                ),
                AppGap.h8,
                Text(
                  'Augmentez la confiance des clients et accédez à toutes les fonctionnalités',
                  style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha:0.9), height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          AppGap.h24,

          // Avantages
          _buildBenefitsCard(),

          AppGap.h20,

          // Ce dont vous avez besoin
          _buildRequirementsCard(),

          AppGap.h20,

          // Informations sur le processus
          _buildProcessInfoCard(),

          AppGap.h24,

          // Bouton commencer
          AppButton(
            label: 'Commencer la vérification',
            variant: ButtonVariant.primary,
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              setState(() => _status = VerificationStatus.inProgress);
            },
          ),

          AppGap.h16,

          // Note RGPD
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded, size: 18, color: context.colors.textSecondary),
                AppGap.w10,
                Expanded(
                  child: Text(
                    'Vos données sont sécurisées et traitées conformément au RGPD. Elles ne sont utilisées que pour vérifier votre identité.',
                    style: context.text.labelMedium?.copyWith(height: 1.4),
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
      padding: AppInsets.a20,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pourquoi se faire vérifier ?',
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h16,
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
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.labelLarge,
                ),
                Text(
                  subtitle,
                  style: context.text.labelMedium,
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
      padding: AppInsets.a20,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce dont vous avez besoin',
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h16,
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
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.labelLarge,
                ),
                Text(
                  subtitle,
                  style: context.text.labelMedium,
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
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.info.withValues(alpha:0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, color: AppColors.info, size: 22),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processus rapide',
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary),
                ),
                AppGap.h4,
                Text(
                  'La vérification prend environ 2-3 minutes. Votre demande sera traitée sous 24-48 heures.',
                  style: context.text.bodySmall?.copyWith(color: AppColors.info, height: 1.4),
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
      padding: AppInsets.a16,
      child: Column(
        children: [
          AppGap.h40,

          // Animation/Illustration
          Container(
            padding: AppInsets.a32,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 80,
              color: AppColors.warning,
            ),
          ),

          AppGap.h32,

          Text(
            'Vérification en cours',
            style: context.text.displaySmall,
          ),

          AppGap.h12,

          Text(
            'Nous examinons vos documents. Vous recevrez une notification dès que la vérification sera terminée.',
            style: context.text.bodyLarge?.copyWith(color: context.colors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),

          AppGap.h32,

          // Timeline
          Container(
            padding: AppInsets.a20,
            decoration: BoxDecoration(
              color: context.colors.surface,
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
                  context.colors.textTertiary,
                ),
              ],
            ),
          ),

          AppGap.h24,

          // Info supplémentaire
          Container(
            padding: AppInsets.a16,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.info.withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.info),
                AppGap.w12,
                Expanded(
                  child: Text(
                    'Vous recevrez une notification push et un email dès que votre vérification sera terminée.',
                    style: context.text.bodySmall?.copyWith(color: AppColors.info, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          AppGap.h24,

          // Bouton support
          AppButton(
            label: 'Contacter le support',
            variant: ButtonVariant.outline,
            icon: Icons.support_agent_rounded,
            onPressed: () {},
          ),

          // Pour tester - À SUPPRIMER EN PROD
          AppGap.h32,
          AppButton(
            label: '(Test) Simuler vérification réussie',
            variant: ButtonVariant.ghost,
            onPressed: () => setState(() => _status = VerificationStatus.verified),
          ),
          AppButton(
            label: '(Test) Simuler vérification rejetée',
            variant: ButtonVariant.ghost,
            onPressed: () => setState(() => _status = VerificationStatus.rejected),
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
          padding: AppInsets.a8,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? context.colors.textPrimary : context.colors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary),
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
        color: isActive ? AppColors.warning.withValues(alpha:0.5) : context.colors.border,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ Vue: Vérifié
  // ─────────────────────────────────────────────────────────────
  Widget _buildVerifiedView() {
    return SingleChildScrollView(
      padding: AppInsets.a16,
      child: Column(
        children: [
          AppGap.h40,

          // Badge vérifié
          Container(
            padding: AppInsets.a32,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 80,
              color: AppColors.success,
            ),
          ),

          AppGap.h32,

          Text(
            'Identité vérifiée !',
            style: context.text.displaySmall,
          ),

          AppGap.h12,

          Text(
            'Félicitations ! Votre identité a été vérifiée avec succès. Vous bénéficiez maintenant de tous les avantages d\'un profil vérifié.',
            style: context.text.bodyLarge?.copyWith(color: context.colors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),

          AppGap.h32,

          // Détails de vérification
          Container(
            padding: AppInsets.a20,
            decoration: BoxDecoration(
              color: context.colors.surface,
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
                Divider(height: 24, color: context.colors.divider),
                _buildVerificationDetail(
                  'Date de vérification',
                  '15 Octobre 2024',
                  Icons.calendar_today_rounded,
                  AppColors.info,
                ),
                Divider(height: 24, color: context.colors.divider),
                _buildVerificationDetail(
                  'Document utilisé',
                  'Carte d\'identité',
                  Icons.badge_rounded,
                  AppColors.secondary,
                ),
                Divider(height: 24, color: context.colors.divider),
                _buildVerificationDetail(
                  'Validité',
                  'Permanente',
                  Icons.all_inclusive_rounded,
                  Colors.orange,
                ),
              ],
            ),
          ),

          AppGap.h24,

          // Ce que ça débloque
          Container(
            padding: AppInsets.a20,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: AppColors.primary),
                    AppGap.w10,
                    Text(
                      'Avantages débloqués',
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
                AppGap.h16,
                _buildUnlockedFeature('Badge vérifié visible sur votre profil'),
                _buildUnlockedFeature('Priorité dans les résultats de recherche'),
                _buildUnlockedFeature('Retrait des gains sans délai'),
                _buildUnlockedFeature('Accès aux missions premium'),
              ],
            ),
          ),

          AppGap.h24,

          AppButton(
            label: 'Retour au profil',
            variant: ButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationDetail(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: AppInsets.a8,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        AppGap.w14,
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium,
          ),
        ),
        Text(
          value,
          style: context.text.labelLarge,
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
          AppGap.w10,
          Expanded(
            child: Text(
              text,
              style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
      padding: AppInsets.a16,
      child: Column(
        children: [
          AppGap.h40,

          // Icône erreur
          Container(
            padding: AppInsets.a32,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_rounded,
              size: 80,
              color: AppColors.error,
            ),
          ),

          AppGap.h32,

          Text(
            'Vérification refusée',
            style: context.text.displaySmall,
          ),

          AppGap.h12,

          Text(
            'Malheureusement, nous n\'avons pas pu vérifier votre identité. Veuillez consulter les raisons ci-dessous et réessayer.',
            style: context.text.bodyLarge?.copyWith(color: context.colors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),

          AppGap.h32,

          // Raisons du refus
          Container(
            padding: AppInsets.a20,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.error),
                    AppGap.w10,
                    Text(
                      'Raisons du refus',
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                AppGap.h16,
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

          AppGap.h20,

          // Conseils pour réessayer
          Container(
            padding: AppInsets.a20,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.gold.withValues(alpha:0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppColors.gold),
                    AppGap.w10,
                    Text(
                      'Conseils pour réessayer',
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.secondary),
                    ),
                  ],
                ),
                AppGap.h12,
                _buildTipItem('Prenez les photos dans un endroit bien éclairé'),
                _buildTipItem('Assurez-vous que le document est entièrement visible'),
                _buildTipItem('Évitez les reflets et les ombres'),
                _buildTipItem('Regardez directement la caméra pour le selfie'),
              ],
            ),
          ),

          AppGap.h24,

          // Boutons d'action
          AppButton(
            label: 'Réessayer la vérification',
            variant: ButtonVariant.primary,
            icon: Icons.refresh_rounded,
            onPressed: () {
              setState(() => _status = VerificationStatus.inProgress);
            },
          ),

          AppGap.h12,

          AppButton(
            label: 'Contacter le support',
            variant: ButtonVariant.outline,
            icon: Icons.support_agent_rounded,
            onPressed: () {},
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
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.labelLarge,
                ),
                Text(
                  description,
                  style: context.text.bodySmall,
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
          AppGap.w6,
          Expanded(
            child: Text(
              text,
              style: context.text.bodySmall?.copyWith(color: context.colors.textPrimary),
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
          padding: AppInsets.a16,
          color: context.colors.surface,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Étape ${_currentStep + 1}/4',
                    style: context.text.labelLarge,
                  ),
                  const Spacer(),
                  Text(
                    _getStepTitle(_currentStep),
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
              AppGap.h12,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: context.colors.divider,
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
            padding: AppInsets.a16,
            child: _buildCurrentStep(),
          ),
        ),

        // Boutons navigation
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: AppButton(
                    label: 'Précédent',
                    variant: ButtonVariant.outline,
                    onPressed: () => setState(() => _currentStep--),
                  ),
                )
              else
                Expanded(
                  child: AppButton(
                    label: 'Annuler',
                    variant: ButtonVariant.outline,
                    onPressed: widget.onCancel,
                  ),
                ),
              AppGap.w12,
              Expanded(
                flex: 2,
                child: AppButton(
                  label: _currentStep == 3 ? 'Soumettre' : 'Continuer',
                  variant: ButtonVariant.primary,
                  isEnabled: _canProceed(),
                  onPressed: _canProceed() ? _handleNext : null,
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
        Text(
          'Choisissez votre document',
          style: context.text.headlineMedium,
        ),
        AppGap.h8,
        Text(
          'Sélectionnez le type de pièce d\'identité que vous souhaitez utiliser.',
          style: context.text.bodyMedium?.copyWith(height: 1.4),
        ),
        AppGap.h24,

        ...DocumentType.values.map((type) => _buildDocumentTypeOption(type)),

        AppGap.h24,

        // Info
        Container(
          padding: AppInsets.a14,
          decoration: BoxDecoration(
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: context.colors.textSecondary),
              AppGap.w10,
              Expanded(
                child: Text(
                  'Le document doit être valide et non expiré. Les informations doivent être lisibles.',
                  style: context.text.bodySmall?.copyWith(height: 1.4),
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
        padding: AppInsets.a16,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha:0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppInsets.a12,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha:0.1)
                    : context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? AppColors.primary : context.colors.textSecondary,
                size: 28,
              ),
            ),
            AppGap.w16,
            Expanded(
              child: Text(
                type.label,
                style: context.text.titleMedium?.copyWith(color: isSelected ? AppColors.primary : null),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.colors.textHint,
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
        Text(
          'Photographiez votre document',
          style: context.text.headlineMedium,
        ),
        AppGap.h8,
        Text(
          'Prenez une photo nette de votre ${_selectedDocType?.label.toLowerCase() ?? 'document'}.',
          style: context.text.bodyMedium,
        ),
        AppGap.h24,

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
          AppGap.h16,
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

        AppGap.h24,

        // Conseils
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 20),
                  AppGap.w8,
                  Text(
                    'Conseils pour une bonne photo',
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ],
              ),
              AppGap.h12,
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
        padding: AppInsets.a20,
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withValues(alpha:0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isUploaded ? AppColors.success : context.colors.border,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppInsets.a16,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withValues(alpha:0.1)
                    : context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                isUploaded ? Icons.check_rounded : icon,
                color: isUploaded ? AppColors.success : context.colors.textTertiary,
                size: 32,
              ),
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium?.copyWith(color: isUploaded ? AppColors.success : null),
                  ),
                  Text(
                    isUploaded ? 'Photo ajoutée ✓' : subtitle,
                    style: context.text.bodySmall?.copyWith(color: isUploaded ? AppColors.success : null),
                  ),
                ],
              ),
            ),
            if (!isUploaded)
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              )
            else
              IconButton(
                onPressed: onReset,
                icon: Icon(Icons.refresh_rounded, color: context.colors.textTertiary),
                tooltip: 'Reprendre',
              ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptionsSheet(VoidCallback onUpload) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) {
        final bottomPad = MediaQuery.of(context).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: context.colors.textPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              AppGap.h16,


              // Scanner option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showCameraPreview(onUpload);
                },
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scanner', style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            AppGap.h2,
                            Text('Prendre une photo avec la caméra', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              // Gallery option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onUpload();
                },
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.photo_library_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Galerie', style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            AppGap.h2,
                            Text('Choisir depuis vos photos', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              // Files option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onUpload();
                },
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.folder_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fichiers', style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            AppGap.h2,
                            Text('Parcourir vos documents', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fermer
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 16 + bottomPad),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Fermer',
                    style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: AppColors.gray400),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      color: context.colors.background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: AppInsets.a16,
          child: Row(
            children: [
              Container(
                padding: AppInsets.a12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              AppGap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
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
                color: context.colors.textPrimary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 80,
                        color: context.colors.textSecondary,
                      ),
                      AppGap.h16,
                      Text(
                        'Aperçu caméra',
                        style: context.text.titleMedium?.copyWith(color: context.colors.textTertiary),
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
                  padding: AppInsets.h16v12,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.7),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    'Placez votre document dans le cadre',
                    style: context.text.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
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
                          margin: AppInsets.a4,
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
        padding: AppInsets.a12,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.5),
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
          AppGap.w8,
          Text(
            text,
            style: context.text.bodySmall?.copyWith(color: context.colors.textPrimary),
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
        Text(
          'Prenez un selfie',
          style: context.text.headlineMedium,
        ),
        AppGap.h8,
        Text(
          'Nous avons besoin d\'une photo de votre visage pour confirmer votre identité.',
          style: context.text.bodyMedium,
        ),
        AppGap.h24,

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
                  ? AppColors.success.withValues(alpha:0.05)
                  : context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
              border: Border.all(
                color: _selfieUploaded ? AppColors.success : context.colors.border,
                width: _selfieUploaded ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: AppInsets.a24,
                  decoration: BoxDecoration(
                    color: _selfieUploaded
                        ? AppColors.success.withValues(alpha:0.1)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selfieUploaded ? Icons.check_rounded : Icons.face_rounded,
                    size: 64,
                    color: _selfieUploaded ? AppColors.success : context.colors.textHint,
                  ),
                ),
                AppGap.h16,
                Text(
                  _selfieUploaded ? 'Selfie ajouté !' : 'Appuyez pour prendre un selfie',
                  style: context.text.titleMedium?.copyWith(
                    color: _selfieUploaded ? AppColors.success : context.colors.textSecondary,
                  ),
                ),
                if (_selfieUploaded) ...[
                  AppGap.h8,
                  AppButton(
                    label: 'Reprendre',
                    variant: ButtonVariant.ghost,
                    icon: Icons.refresh_rounded,
                    onPressed: () => setState(() => _selfieUploaded = false),
                  ),
                ],
              ],
            ),
          ),
        ),

        AppGap.h24,

        // Instructions
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha:0.05),
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
      padding: AppInsets.v8,
      child: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.labelLarge,
                ),
                Text(
                  subtitle,
                  style: context.text.labelMedium,
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
        Text(
          'Vérifiez vos informations',
          style: context.text.headlineMedium,
        ),
        AppGap.h8,
        Text(
          'Assurez-vous que tout est correct avant de soumettre.',
          style: context.text.bodyMedium,
        ),
        AppGap.h24,

        // Résumé
        Container(
          padding: AppInsets.a20,
          decoration: BoxDecoration(
            color: context.colors.surface,
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
              Divider(height: 24, color: context.colors.divider),
              _buildConfirmationItem(
                'Photo recto',
                'Ajoutée',
                Icons.image_rounded,
                AppColors.success,
              ),
              if (_selectedDocType != DocumentType.passport) ...[
                Divider(height: 24, color: context.colors.divider),
                _buildConfirmationItem(
                  'Photo verso',
                  'Ajoutée',
                  Icons.image_rounded,
                  AppColors.success,
                ),
              ],
              Divider(height: 24, color: context.colors.divider),
              _buildConfirmationItem(
                'Selfie',
                'Ajouté',
                Icons.face_rounded,
                AppColors.success,
              ),
            ],
          ),
        ),

        AppGap.h20,

        // Consentement
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: context.colors.divider!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_rounded, color: context.colors.textSecondary, size: 20),
              AppGap.w12,
              Expanded(
                child: Text(
                  'En soumettant ces documents, vous acceptez que Inkern traite vos données personnelles à des fins de vérification d\'identité conformément à notre politique de confidentialité.',
                  style: context.text.labelMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),

        AppGap.h20,

        // Délai
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.info.withValues(alpha:0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, color: AppColors.info),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Délai de traitement',
                      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                    Text(
                      'Votre demande sera traitée sous 24 à 48 heures.',
                      style: context.text.bodySmall?.copyWith(color: AppColors.info),
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
          padding: AppInsets.a10,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        AppGap.w14,
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: context.text.labelLarge,
            ),
            AppGap.w6,
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          ],
        ),
      ],
    );
  }
}