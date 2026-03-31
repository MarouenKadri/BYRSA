import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../data/models/candidate.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../../notifications/notification_provider.dart';
import '../../../../notifications/data/models/app_notification.dart';

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
    final rows = await context.read<MissionProvider>().fetchCandidates(widget.missionId);
    if (!mounted) return;
    setState(() {
      _candidates = rows.map(_candidateFromRow).toList();
      _hasAcceptedCandidate = _candidates.any((c) => c.status == CandidateStatus.accepte);
      _isLoading = false;
    });
  }

  static CandidateStatus _candidateStatusFromDb(String s) => switch (s) {
    'en_attente' => CandidateStatus.enAttente,
    'accepte'    => CandidateStatus.accepte,
    'refuse'     => CandidateStatus.refuse,
    _            => CandidateStatus.enAttente,
  };

  static Candidate _candidateFromRow(Map<String, dynamic> row) {
    final f = row['freelancer'] as Map<String, dynamic>? ?? {};
    final createdAt = DateTime.tryParse(row['applied_at'] as String? ?? row['created_at'] as String? ?? '');
    String appliedAt = 'À l\'instant';
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inMinutes < 1) appliedAt = 'À l\'instant';
      else if (diff.inMinutes < 60) appliedAt = 'Il y a ${diff.inMinutes} min';
      else if (diff.inHours < 24) appliedAt = 'Il y a ${diff.inHours}h';
      else appliedAt = 'Il y a ${diff.inDays}j';
    }
    final price = (row['proposed_price'] as num?)?.toDouble() ?? 0;
    final statusStr = row['status'] as String? ?? 'en_attente';
    return Candidate(
      id: row['freelancer_id'] as String? ?? (row['id'] as String? ?? ''),
      name: '${f['first_name'] ?? ''} ${f['last_name'] ?? ''}'.trim(),
      avatar: f['avatar_url'] as String? ?? '',
      rating: (f['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: f['reviews_count'] as int? ?? 0,
      proposedPrice: price > 0 ? '${price.toInt()} €' : 'Devis',
      message: row['message'] as String? ?? '',
      skills: const [],
      responseTime: '',
      completedMissions: f['completed_missions'] as int? ?? 0,
      isVerified: f['is_verified'] as bool? ?? false,
      appliedAt: appliedAt,
      status: _candidateStatusFromDb(statusStr),
    );
  }

  /// ─── Accepter un candidat (les autres sont rejetés) ───
  void _acceptCandidate(Candidate candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: const Text('Confirmer votre choix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Vous allez accepter '),
                  TextSpan(
                    text: candidate.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' pour '),
                  TextSpan(
                    text: candidate.proposedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Color(0xFFFF9500),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Les autres candidats seront automatiquement refusés.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAcceptance(candidate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  /// Lance le flow de paiement après confirmation du candidat
  void _confirmAcceptance(Candidate candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
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
    context.read<NotificationProvider>().addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.candidature,
      title: 'Candidature acceptée',
      body: '${acceptedCandidate.name} a été sélectionné pour "${widget.missionTitle}".',
      timeAgo: 'À l\'instant',
      avatarUrl: acceptedCandidate.avatar,
    ));

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

  /// ─── Ouvrir le chat avec un candidat ───
  void _openChat(Candidate candidate) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          contactName: candidate.name,
          contactAvatar: candidate.avatar,
          isOnline: true,
          isVerified: candidate.isVerified,
          missionTitle: widget.missionTitle,
          // Mode candidat : permet d'accepter depuis le chat
          candidateMode: true,
          candidatePrice: candidate.proposedPrice,
          onAcceptCandidate: () {
            // Callback quand accepté depuis le chat
            Navigator.pop(context, true);
          },
        ),
      ),
    );

    // Si accepté depuis le chat
    if (result == true) {
      _confirmAcceptance(candidate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _candidates
        .where((c) => c.status == CandidateStatus.enAttente)
        .length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Candidatures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.missionTitle,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          if (!_hasAcceptedCandidate)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$pendingCount en attente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ─── Info Budget ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget proposé : ',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                Text(
                  widget.missionBudget,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ─── Message si accepté ───
          if (_hasAcceptedCandidate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verifiedBg,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vous avez choisi votre prestataire ! Contactez-le pour finaliser les détails.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
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
                : _candidates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text('Aucune candidature pour l\'instant', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          _hasAcceptedCandidate ? 0 : 16,
                          16,
                          100,
                        ),
                        itemCount: _candidates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _CandidateCard(
                          candidate: _candidates[index],
                          onAccept: _hasAcceptedCandidate
                              ? null
                              : () => _acceptCandidate(_candidates[index]),
                          onChat: _hasAcceptedCandidate
                              ? null
                              : () => _openChat(_candidates[index]),
                          onTap: () => _showCandidateDetails(_candidates[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// ─── Détail candidat (bottom sheet) ───
  void _showCandidateDetails(Candidate candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CandidateDetailsSheet(
        candidate: candidate,
        onAccept:
            _hasAcceptedCandidate ||
                candidate.status != CandidateStatus.enAttente
            ? null
            : () {
                Navigator.pop(context);
                _acceptCandidate(candidate);
              },
        onChat:
            _hasAcceptedCandidate ||
                candidate.status != CandidateStatus.enAttente
            ? null
            : () {
                Navigator.pop(context);
                _openChat(candidate);
              },
        onViewProfile: () {
          Navigator.pop(context);
          Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (_) => FreelancerProfileView(
                freelancerId: candidate.id,
                freelancerName: candidate.name,
                freelancerAvatar: candidate.avatar,
                rating: candidate.rating,
                reviewsCount: candidate.reviewsCount,
                missionsCount: candidate.completedMissions,
                responseTime: candidate.responseTime,
              ),
            ),
          );
        },
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
  final VoidCallback? onChat;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.candidate,
    required this.onAccept,
    required this.onChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = candidate.status == CandidateStatus.accepte;
    final isRejected = candidate.status == CandidateStatus.refuse;

    return Opacity(
      opacity: isRejected ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isAccepted ? AppColors.verifiedBg : AppColors.chipBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: isAccepted
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───
                  Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(candidate.avatar),
                          ),
                          if (candidate.isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    candidate.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAccepted) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(AppRadius.input),
                                    ),
                                    child: const Text(
                                      '✓ CHOISI',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isRejected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textHint,
                                      borderRadius: BorderRadius.circular(AppRadius.input),
                                    ),
                                    child: const Text(
                                      'REFUSÉ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.background,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${candidate.rating}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  ' (${candidate.reviewsCount} avis)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 12),

                  // ─── Tarif proposé ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tarif proposé',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Text(
                          candidate.proposedPrice,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Footer ───
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        candidate.appliedAt,
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
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

/// ─────────────────────────────────────────────────────────────
/// 📋 Bottom Sheet Détails Candidat
/// ─────────────────────────────────────────────────────────────
class _CandidateDetailsSheet extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback? onAccept;
  final VoidCallback? onChat;
  final VoidCallback? onViewProfile;

  const _CandidateDetailsSheet({
    required this.candidate,
    required this.onAccept,
    required this.onChat,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ─── Handle ───
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ─── Contenu scrollable ───
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── Header ───
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(candidate.avatar),
                          ),
                          if (candidate.isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${candidate.rating}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  ' (${candidate.reviewsCount} avis)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Prix proposé ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tarif proposé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          candidate.proposedPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Stats ───
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${candidate.completedMissions}',
                        label: 'Missions',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.schedule_rounded,
                        value: candidate.responseTime.replaceAll(
                          'Répond en ',
                          '',
                        ),
                        label: 'Réponse',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.star_rounded,
                        value: '${candidate.rating}',
                        label: 'Note',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Message ───
                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Text(
                      candidate.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Compétences ───
                  const Text(
                    'Compétences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(AppRadius.cardLg),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // ─── Bouton voir profil ───
                  OutlinedButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.person_outline_rounded),
                    label: const Text('Voir le profil complet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ─── Boutons fixes en bas ───
            if (onAccept != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Bouton Chat
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onChat,
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text(
                          'Chat',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.info,
                          side: BorderSide(color: AppColors.info.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton Accepter
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Accepter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
      double.tryParse(widget.candidate.proposedPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  double get _presta => _amount * 0.9;
  double get _cigale => _amount * 0.1;

  int _selectedCard = 0;

  final List<({String brand, String last4, String expiry, Color color})> _cards = [
    (brand: 'Visa', last4: '4242', expiry: '12/26', color: Color(0xFF2563EB)),
    (brand: 'Mastercard', last4: '8888', expiry: '08/25', color: Color(0xFFEA580C)),
  ];

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCardSheet(
        onCardAdded: (last4, expiry) {
          setState(() {
            _cards.add((brand: 'Carte', last4: last4, expiry: expiry, color: AppColors.background));
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Handle ───
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ─── Titre ───
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.badge)),
              child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bloquer le paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(widget.missionTitle,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]),

          const SizedBox(height: 20),

          // ─── Récapitulatif ───
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.button)),
            child: Column(children: [
              Row(children: [
                CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.candidate.avatar)),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.candidate.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text(widget.candidate.proposedPrice,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ]),

              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

              _AmountRow(label: 'Prestataire (90%)', amount: _presta, color: AppColors.primary),
              const SizedBox(height: 8),
              _AmountRow(label: 'Commission Inkern (10%)', amount: _cigale, color: Colors.grey),

              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total bloqué', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('${_amount.round()} €',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),

          const SizedBox(height: 14),

          // ─── Info escrow ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.badge)),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 15, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Le montant est bloqué (non débité) et libéré au prestataire uniquement après votre validation.',
                style: TextStyle(fontSize: 12, color: AppColors.secondary, height: 1.4),
              )),
            ]),
          ),

          const SizedBox(height: 20),

          // ─── Sélection carte ───
          const Text('MOYEN DE PAIEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ...List.generate(_cards.length, (i) {
            final card = _cards[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedCard = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedCard == i ? AppColors.primary.withOpacity(0.06) : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: _selectedCard == i ? AppColors.primary : AppColors.divider),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 24,
                    decoration: BoxDecoration(color: card.color, borderRadius: BorderRadius.circular(4)),
                    child: Center(child: Text(card.brand[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('•••• ${card.last4}  ·  ${card.expiry}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  if (_selectedCard == i) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                ]),
              ),
            );
          }),

          // ─── Ajouter une carte ───
          GestureDetector(
            onTap: _showAddCardDialog,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), style: BorderStyle.solid, width: 1.5),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 24,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Ajouter une carte bancaire',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))),
                Icon(Icons.chevron_right_rounded, color: AppColors.primary.withOpacity(0.6), size: 20),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Bouton paiement ───
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('Payer ${_amount.round()} € et bloquer'),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('Paiement sécurisé par Inkern',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            ]),
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
  const _AmountRow({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text('${amount.round()} €', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ]);
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

  String get _previewExpiry => _expiryCtrl.text.isEmpty ? 'MM/AA' : _expiryCtrl.text;
  String get _previewName => _nameCtrl.text.trim().isEmpty ? 'VOTRE NOM' : _nameCtrl.text.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // ─── Titre ───
              const Text('Ajouter une carte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Vos données sont chiffrées et sécurisées', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),

              const SizedBox(height: 22),

              // ─── Aperçu carte ───
              Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), AppColors.primary, Color(0xFF66BB6A)],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Inkern PAY', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      Icon(Icons.contactless_rounded, color: Colors.white.withOpacity(0.85), size: 26),
                    ]),
                    const Spacer(),
                    // Puce
                    Container(
                      width: 38, height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.5), AppColors.gold]),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.memory_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _previewNumber,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('TITULAIRE', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text(_previewName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('EXPIRE', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text(_previewExpiry, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                  final formatted = digits.replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m.group(0)} ').trim();
                  if (formatted != v) {
                    _numberCtrl.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
                  }
                  setState(() {});
                },
                validator: (v) => (v == null || v.replaceAll(' ', '').length < 16) ? 'Numéro invalide' : null,
              ),

              const SizedBox(height: 12),

              // ─── Nom ───
              _buildField(
                controller: _nameCtrl,
                label: 'Nom du titulaire',
                hint: 'Jean Dupont',
                icon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),

              const SizedBox(height: 12),

              // ─── Expiry + CVV ───
              Row(children: [
                Expanded(
                  child: _buildField(
                    controller: _expiryCtrl,
                    label: 'MM/AA',
                    icon: Icons.calendar_today_rounded,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: (v) {
                      if (v.length == 2 && !v.contains('/')) {
                        _expiryCtrl.value = TextEditingValue(text: '$v/', selection: const TextSelection.collapsed(offset: 3));
                      }
                      setState(() {});
                    },
                    validator: (v) => (v == null || v.length < 5) ? 'Invalide' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: !_cvvVisible,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: AppColors.divider)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: AppColors.divider)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.urgent)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.urgent, width: 1.5)),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _cvvVisible = !_cvvVisible),
                        child: Icon(_cvvVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textTertiary),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 3) ? 'Invalide' : null,
                  ),
                ),
              ]),

              const SizedBox(height: 28),

              // ─── Bouton ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final digits = _numberCtrl.text.replaceAll(' ', '');
                    final last4 = digits.substring(digits.length - 4);
                    Navigator.pop(context);
                    widget.onCardAdded(last4, _expiryCtrl.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Ajouter la carte'),
                ),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: AppColors.divider)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.urgent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.urgent, width: 1.5)),
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📊 Carte Stat
/// ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

