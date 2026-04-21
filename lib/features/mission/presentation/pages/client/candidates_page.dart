import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/candidate.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../../../notifications/notification_provider.dart';
import '../../../../notifications/data/models/app_notification.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';

class CandidatesPage extends StatefulWidget {
  final String missionId;
  final String missionTitle;
  final String missionBudget;

  const CandidatesPage({
    super.key,
    required this.missionId,
    required this.missionTitle,
    required this.missionBudget,
  });

  @override
  State<CandidatesPage> createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  List<Candidate> _candidates = [];
  bool _hasAcceptedCandidate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      final rows = await context.read<MissionProvider>().fetchCandidates(
        widget.missionId,
      );
      if (!mounted) return;
      setState(() {
        _candidates = rows.map(_candidateFromRow).toList();
        _hasAcceptedCandidate = _candidates.any(
          (c) => c.status == CandidateStatus.accepte,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _candidates = [];
        _hasAcceptedCandidate = false;
        _isLoading = false;
      });
    }
  }

  static CandidateStatus _candidateStatusFromDb(String s) => switch (s) {
    'en_attente' => CandidateStatus.enAttente,
    'accepte' => CandidateStatus.accepte,
    'refuse' => CandidateStatus.refuse,
    _ => CandidateStatus.enAttente,
  };

  static Candidate _candidateFromRow(Map<String, dynamic> row) {
    final f = row['freelancer'] is Map
        ? Map<String, dynamic>.from(row['freelancer'] as Map)
        : <String, dynamic>{};
    final createdAt = DateTime.tryParse(
      (row['applied_at'] ?? row['created_at'] ?? '').toString(),
    );
    String appliedAt = 'À l\'instant';
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inMinutes < 1) {
        appliedAt = 'À l\'instant';
      } else if (diff.inMinutes < 60)
        appliedAt = 'Il y a ${diff.inMinutes} min';
      else if (diff.inHours < 24)
        appliedAt = 'Il y a ${diff.inHours}h';
      else
        appliedAt = 'Il y a ${diff.inDays}j';
    }
    final price = _asDouble(row['proposed_price']);
    final statusStr = (row['status'] ?? 'en_attente').toString();
    final firstName = (f['first_name'] ?? '').toString().trim();
    final lastName = (f['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    return Candidate(
      id: (row['freelancer_id'] ?? row['id'] ?? '').toString(),
      name: fullName.isNotEmpty ? fullName : 'Freelancer',
      avatar: (f['avatar_url'] ?? '').toString(),
      rating: _asDouble(f['rating']),
      reviewsCount: _asInt(f['reviews_count']),
      proposedPrice: price > 0 ? '${price.toInt()} €' : 'Devis',
      message: (row['message'] ?? '').toString(),
      skills: const [],
      responseTime: '',
      completedMissions: _asInt(f['completed_missions']),
      isVerified: f['is_verified'] as bool? ?? false,
      appliedAt: appliedAt,
      status: _candidateStatusFromDb(statusStr),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  /// ─── Accepter un candidat (les autres sont rejetés) ───
  void _acceptCandidate(Candidate candidate) {
    showAppDialog(
      context: context,
      title: const Text('Confirmer votre choix'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: context.text.bodyLarge?.copyWith(height: 1.4),
              children: [
                const TextSpan(text: 'Vous allez accepter '),
                TextSpan(
                  text: candidate.name,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' pour '),
                TextSpan(
                  text: candidate.proposedPrice,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          AppGap.h12,
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: context.colors.background.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Les autres candidats seront automatiquement refusés.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Confirmer',
      onConfirm: () {
        Navigator.pop(context);
        _confirmAcceptance(candidate);
      },
    );
  }

  /// Lance le flow de paiement après confirmation du candidat
  void _confirmAcceptance(Candidate candidate) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _PaymentSheet(
        candidate: candidate,
        missionTitle: widget.missionTitle,
        onPaymentSuccess: () => _finalizeAcceptance(candidate),
      ),
    );
  }

  /// Finalise l'acceptation après paiement réussi
  void _finalizeAcceptance(Candidate acceptedCandidate) {
    // Convertir le candidat en PrestaInfo et accepter (status confirmed + assignedPresta)
    final presta = PrestaInfo(
      id: acceptedCandidate.id,
      name: acceptedCandidate.name,
      avatarUrl: acceptedCandidate.avatar,
      rating: acceptedCandidate.rating,
      reviewsCount: acceptedCandidate.reviewsCount,
      completedMissions: acceptedCandidate.completedMissions,
      isVerified: acceptedCandidate.isVerified,
      acceptedPrice: acceptedCandidate.proposedPrice,
    );
    context.read<MissionProvider>().acceptCandidate(widget.missionId, presta);

    // Notifier le prestataire
    context.read<NotificationProvider>().addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotifType.candidature,
        title: 'Candidature acceptée',
        body:
            '${acceptedCandidate.name} a été sélectionné pour "${widget.missionTitle}".',
        timeAgo: 'À l\'instant',
        avatarUrl: acceptedCandidate.avatar,
      ),
    );

    setState(() {
      _hasAcceptedCandidate = true;
      for (var candidate in _candidates) {
        if (candidate.id == acceptedCandidate.id) {
          candidate.status = CandidateStatus.accepte;
        } else {
          candidate.status = CandidateStatus.refuse;
        }
      }
      _candidates.sort((a, b) {
        if (a.status == CandidateStatus.accepte) return -1;
        if (b.status == CandidateStatus.accepte) return 1;
        return 0;
      });
    });
  }

  int _statusRank(CandidateStatus status) => switch (status) {
    CandidateStatus.enAttente => 0,
    CandidateStatus.accepte => 1,
    CandidateStatus.refuse => 2,
  };

  double? _extractPrice(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final parsed = double.tryParse(
      normalized.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return '${value.toInt()} €';
    return '${value.toStringAsFixed(1)} €';
  }

  String get _bestPriceLabel {
    final prices = _candidates
        .map((c) => _extractPrice(c.proposedPrice))
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return 'Devis';
    prices.sort();
    return _formatPrice(prices.first);
  }

  List<Candidate> get _sortedCandidates {
    final sorted = List<Candidate>.from(_candidates);
    sorted.sort((a, b) => _statusRank(a.status).compareTo(_statusRank(b.status)));
    return sorted;
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
          AppGap.h4,
          Text(
            value,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersCount = _candidates.length;
    final pendingCount = _candidates
        .where((c) => c.status == CandidateStatus.enAttente)
        .length;
    final displayCandidates = _sortedCandidates;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.snow,
      appBar: AppPageAppBar(
        title: 'Offres reçues',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.missionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    'Liste des offres reçues pour cette mission',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h16,
                  Row(
                    children: [
                      _buildSummaryMetric(
                        label: 'Offres',
                        value: '$offersCount',
                      ),
                      _buildSummaryMetric(
                        label: 'Meilleur',
                        value: _bestPriceLabel,
                      ),
                      _buildSummaryMetric(
                        label: 'En attente',
                        value: '$pendingCount',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ─── Message si accepté ───
          if (_hasAcceptedCandidate)
            AppSurfaceCard(
              margin: AppInsets.a16,
              padding: AppInsets.a12,
              color: context.colors.successLight,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Vous avez choisi votre prestataire ! Contactez-le pour finaliser les détails.',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ─── Liste des candidats ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayCandidates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 56,
                          color: context.colors.textHint,
                        ),
                        AppGap.h12,
                        Text(
                          'Aucune offre pour l\'instant',
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      _hasAcceptedCandidate ? 8 : 18,
                      16,
                      100,
                    ),
                    itemCount: displayCandidates.length,
                    separatorBuilder: (_, __) => AppGap.h12,
                    itemBuilder: (context, index) => _CandidateCard(
                      candidate: displayCandidates[index],
                      onAccept: _hasAcceptedCandidate
                          ? null
                          : () => _acceptCandidate(displayCandidates[index]),
                      onTap: () => _openProfile(displayCandidates[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openProfile(Candidate candidate) {
    final isPending = candidate.status == CandidateStatus.enAttente && !_hasAcceptedCandidate;
    final isAccepted = candidate.status == CandidateStatus.accepte;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: candidate.id,
          freelancerName: candidate.name,
          freelancerAvatar: candidate.avatar,
          rating: candidate.rating,
          reviewsCount: candidate.reviewsCount,
          missionsCount: candidate.completedMissions,
          proposedPrice: candidate.proposedPrice,
          contactMode: isPending
              ? FreelancerContactMode.pendingCandidate
              : isAccepted
                  ? FreelancerContactMode.confirmedPresta
                  : FreelancerContactMode.spontaneous,
          candidatePrice: candidate.proposedPrice,
          onCandidateAccepted: isPending
              ? () => _acceptCandidate(candidate)
              : null,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🎴 Carte Candidat
/// ─────────────────────────────────────────────────────────────
class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback? onAccept;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.candidate,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = candidate.status == CandidateStatus.accepte;
    final isRejected = candidate.status == CandidateStatus.refuse;
    final isPending = candidate.status == CandidateStatus.enAttente;
    final canAccept = onAccept != null && isPending;
    final messagePreview = candidate.message.trim().isEmpty
        ? 'Aucun message ajoute.'
        : candidate.message.trim();

    return Opacity(
      opacity: isRejected ? 0.52 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: isAccepted
              ? Border.all(color: AppColors.ink, width: 1.0)
              : Border.all(color: AppColors.gray50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.016),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.blackAlpha07,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 29,
                          backgroundColor: AppColors.gray50,
                          backgroundImage: candidate.avatar.isNotEmpty
                              ? NetworkImage(candidate.avatar)
                              : null,
                          child: candidate.avatar.isEmpty
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.gray400,
                                )
                              : null,
                        ),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    candidate.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                _OfferStatusChip(status: candidate.status),
                              ],
                            ),
                            AppGap.h6,
                            Text(
                              '★ ${candidate.rating.toStringAsFixed(1)} · ${candidate.reviewsCount} avis',
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppGap.h16,
                  Text(
                    'Tarif proposé',
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.textTertiary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    candidate.proposedPrice,
                    style: context.text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h12,
                  Text(
                    messagePreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      height: 1.5,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h14,
                  Row(
                    children: [
                      Text(
                        candidate.appliedAt,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.textPrimary,
                          textStyle: context.text.labelLarge,
                        ),
                        child: const Text('Voir profil'),
                      ),
                      if (canAccept) ...[
                        AppGap.w8,
                        IntrinsicWidth(
                          child: AppButton(
                            label: 'Accepter',
                            variant: ButtonVariant.black,
                            height: 38,
                            width: null,
                            onPressed: onAccept,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferStatusChip extends StatelessWidget {
  final CandidateStatus status;

  const _OfferStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      CandidateStatus.enAttente => (
          'EN ATTENTE',
          AppColors.gray50,
          AppColors.gray600,
        ),
      CandidateStatus.accepte => (
          'CHOISIE',
          AppColors.successBg,
          AppColors.successDark,
        ),
      CandidateStatus.refuse => (
          'REFUSÉE',
          AppColors.gray50,
          AppColors.gray400,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bg.withValues(alpha: 0.9)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: fg,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 💳 Sheet de paiement — blocage du montant
/// ─────────────────────────────────────────────────────────────
class _PaymentSheet extends StatefulWidget {
  final Candidate candidate;
  final String missionTitle;
  final VoidCallback onPaymentSuccess;

  const _PaymentSheet({
    required this.candidate,
    required this.missionTitle,
    required this.onPaymentSuccess,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _isProcessing = false;

  double get _amount =>
      double.tryParse(
        widget.candidate.proposedPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
      ) ??
      0;
  double get _presta => _amount * 0.9;
  double get _cigale => _amount * 0.1;

  int _selectedCard = 0;

  final List<({String brand, String last4, String expiry, Color color})>
  _cards = [
    (
      brand: 'Visa',
      last4: '4242',
      expiry: '12/26',
      color: AppColors.blueAction,
    ),
    (
      brand: 'Mastercard',
      last4: '8888',
      expiry: '08/25',
      color: AppColors.mastercardOrange,
    ),
  ];

  void _showAddCardDialog() {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _AddCardSheet(
        onCardAdded: (last4, expiry) {
          setState(() {
            _cards.add((
              brand: 'Carte',
              last4: last4,
              expiry: expiry,
              color: context.colors.background,
            ));
            _selectedCard = _cards.length - 1;
          });
        },
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Handle ───
          Center(
            child: Container(
              margin: AppInsets.v12,
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppRadius.micro),
              ),
            ),
          ),

          // ─── Titre ───
          Row(
            children: [
              Container(
                padding: AppInsets.a8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bloquer le paiement',
                      style: context.text.headlineSmall,
                    ),
                    Text(
                      widget.missionTitle,
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppGap.h20,

          // ─── Récapitulatif ───
          Container(
            padding: AppInsets.a16,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(widget.candidate.avatar),
                    ),
                    AppGap.w10,
                    Expanded(
                      child: Text(
                        widget.candidate.name,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      widget.candidate.proposedPrice,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: AppInsets.v12,
                  child: Divider(height: 1),
                ),

                _AmountRow(
                  label: 'Prestataire (90%)',
                  amount: _presta,
                  color: AppColors.primary,
                ),
                AppGap.h8,
                _AmountRow(
                  label: 'Commission Inkern (10%)',
                  amount: _cigale,
                  color: context.colors.textTertiary,
                ),

                const Padding(
                  padding: AppInsets.v12,
                  child: Divider(height: 1),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total bloqué',
                      style: context.text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_amount.round()} €',
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppGap.h14,

          // ─── Info escrow ───
          Container(
            padding: AppInsets.h12v10,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.info,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Le montant est bloqué (non débité) et libéré au prestataire uniquement après votre validation.',
                    style: context.text.labelMedium?.copyWith(
                      color: AppColors.secondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppGap.h20,

          // ─── Sélection carte ───
          Text(
            'MOYEN DE PAIEMENT',
            style: context.text.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          AppGap.h10,
          ...List.generate(_cards.length, (i) {
            final card = _cards[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedCard = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: AppInsets.h14v12,
                decoration: BoxDecoration(
                  color: _selectedCard == i
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : context.colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(
                    color: _selectedCard == i
                        ? AppColors.primary
                        : context.colors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        color: card.color,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Center(
                        child: Text(
                          card.brand[0],
                          style: context.text.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Text(
                        '•••• ${card.last4}  ·  ${card.expiry}',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_selectedCard == i)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),

          // ─── Ajouter une carte ───
          GestureDetector(
            onTap: _showAddCardDialog,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: AppInsets.h14v12,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Ajouter une carte bancaire',
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          AppGap.h20,

          // ─── Bouton paiement ───
          AppButton(
            label: 'Payer ${_amount.round()} € et bloquer',
            variant: ButtonVariant.primary,
            isLoading: _isProcessing,
            onPressed: _isProcessing ? null : _pay,
          ),

          AppGap.h10,

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: context.colors.textHint,
                ),
                AppGap.w4,
                Text(
                  'Paiement sécurisé par Inkern',
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.text.bodySmall),
        Text(
          '${amount.round()} €',
          style: context.text.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 💳 Formulaire ajout carte — bottom sheet redesigné
/// ─────────────────────────────────────────────────────────────
class _AddCardSheet extends StatefulWidget {
  final void Function(String last4, String expiry) onCardAdded;
  const _AddCardSheet({required this.onCardAdded});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _cvvVisible = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _previewNumber {
    final digits = _numberCtrl.text.replaceAll(' ', '');
    final padded = digits.padRight(16, '•');
    return '${padded.substring(0, 4)}  ${padded.substring(4, 8)}  ${padded.substring(8, 12)}  ${padded.substring(12, 16)}';
  }

  String get _previewExpiry =>
      _expiryCtrl.text.isEmpty ? 'MM/AA' : _expiryCtrl.text;
  String get _previewName => _nameCtrl.text.trim().isEmpty
      ? 'VOTRE NOM'
      : _nameCtrl.text.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Handle ───
              Center(
                child: Container(
                  margin: AppInsets.v12,
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.micro),
                  ),
                ),
              ),

              // ─── Titre ───
              Text(
                'Ajouter une carte',
                style: context.text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppGap.h4,
              Text(
                'Vos données sont chiffrées et sécurisées',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),

              AppGap.h22,

              // ─── Aperçu carte ───
              Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.greenForest,
                      AppColors.primary,
                      AppColors.greenMint,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inkern PAY',
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Icon(
                          Icons.contactless_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 26,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Puce
                    Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.5),
                            AppColors.gold,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: const Icon(
                        Icons.memory_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    AppGap.h14,
                    Text(
                      _previewNumber,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    AppGap.h14,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TITULAIRE',
                              style: context.text.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 1,
                              ),
                            ),
                            AppGap.h2,
                            Text(
                              _previewName,
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EXPIRE',
                              style: context.text.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 1,
                              ),
                            ),
                            AppGap.h2,
                            Text(
                              _previewExpiry,
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppGap.h24,

              // ─── Numéro ───
              _buildField(
                controller: _numberCtrl,
                label: 'Numéro de carte',
                hint: '0000  0000  0000  0000',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                maxLength: 19,
                onChanged: (v) {
                  final digits = v.replaceAll(' ', '');
                  final formatted = digits
                      .replaceAllMapped(
                        RegExp(r'.{1,4}'),
                        (m) => '${m.group(0)} ',
                      )
                      .trim();
                  if (formatted != v) {
                    _numberCtrl.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                  setState(() {});
                },
                validator: (v) =>
                    (v == null || v.replaceAll(' ', '').length < 16)
                    ? 'Numéro invalide'
                    : null,
              ),

              AppGap.h12,

              // ─── Nom ───
              _buildField(
                controller: _nameCtrl,
                label: 'Nom du titulaire',
                hint: 'Jean Dupont',
                icon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),

              AppGap.h12,

              // ─── Expiry + CVV ───
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _expiryCtrl,
                      label: 'MM/AA',
                      icon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      onChanged: (v) {
                        if (v.length == 2 && !v.contains('/')) {
                          _expiryCtrl.value = TextEditingValue(
                            text: '$v/',
                            selection: const TextSelection.collapsed(offset: 3),
                          );
                        }
                        setState(() {});
                      },
                      validator: (v) =>
                          (v == null || v.length < 5) ? 'Invalide' : null,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: !_cvvVisible,
                      decoration: AppInputDecorations.formField(
                        context,
                        fillColor: context.colors.background,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => _cvvVisible = !_cvvVisible),
                          child: Icon(
                            _cvvVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ).copyWith(
                        labelText: 'CVV',
                        counterText: '',
                      ),
                      validator: (v) =>
                          (v == null || v.length < 3) ? 'Invalide' : null,
                    ),
                  ),
                ],
              ),

              AppGap.h28,

              // ─── Bouton ───
              AppButton(
                label: 'Ajouter la carte',
                variant: ButtonVariant.primary,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final digits = _numberCtrl.text.replaceAll(' ', '');
                  final last4 = digits.substring(digits.length - 4);
                  Navigator.pop(context);
                  widget.onCardAdded(last4, _expiryCtrl.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: validator,
      decoration: AppInputDecorations.formField(
        context,
        hintText: hint,
        fillColor: context.colors.background,
        prefixIcon: Icon(icon, size: 18),
      ).copyWith(
        labelText: label,
        counterText: '',
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📊 Carte Stat
/// ─────────────────────────────────────────────────────────────
