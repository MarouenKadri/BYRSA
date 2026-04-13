import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/candidate.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
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
  }

  static CandidateStatus _candidateStatusFromDb(String s) => switch (s) {
    'en_attente' => CandidateStatus.enAttente,
    'accepte' => CandidateStatus.accepte,
    'refuse' => CandidateStatus.refuse,
    _ => CandidateStatus.enAttente,
  };

  static Candidate _candidateFromRow(Map<String, dynamic> row) {
    final f = row['freelancer'] as Map<String, dynamic>? ?? {};
    final createdAt = DateTime.tryParse(
      row['applied_at'] as String? ?? row['created_at'] as String? ?? '',
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
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF9099A4),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          'Candidatures: ${widget.missionTitle}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (!_hasAcceptedCandidate)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '$pendingCount en attente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9AA3AE),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF9AA3AE),
                    size: 18,
                  ),
                  AppGap.w10,
                  Text(
                    'Budget propose: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5D6672),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.missionBudget,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
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
                : _candidates.isEmpty
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
                          'Aucune candidature pour l\'instant',
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
                    itemCount: _candidates.length,
                    separatorBuilder: (_, __) => AppGap.h12,
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
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
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
      opacity: isRejected ? 0.52 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isAccepted
              ? Border.all(color: AppColors.ink, width: 1.0)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
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
                              color: Color(0x12000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 29,
                          backgroundColor: const Color(0xFFF2F3F5),
                          backgroundImage: candidate.avatar.isNotEmpty
                              ? NetworkImage(candidate.avatar)
                              : null,
                          child: candidate.avatar.isEmpty
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF9AA3AE),
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
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                if (isAccepted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFE8EBEF),
                                      ),
                                    ),
                                    child: Text(
                                      'CHOISI',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.3,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                if (isRejected)
                                  Text(
                                    'REFUSE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.3,
                                      color: const Color(0xFFA0A8B2),
                                    ),
                                  ),
                              ],
                            ),
                            AppGap.h6,
                            Text(
                              '${candidate.rating.toStringAsFixed(1)} (${candidate.reviewsCount} avis)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8F98A3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppGap.h18,
                  Text(
                    'Tarif propose',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF98A1AC),
                      letterSpacing: 0.2,
                    ),
                  ),
                  AppGap.h6,
                  Text(
                    candidate.proposedPrice,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: AppColors.ink,
                    ),
                  ),
                  AppGap.h14,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      candidate.appliedAt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFB0B8C2),
                      ),
                    ),
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
    final replyValue = candidate.responseTime.isEmpty
        ? 'Rapide'
        : candidate.responseTime.replaceAll('Répond en ', '');
    final messageText = candidate.message.trim().isEmpty
        ? "Ce freelance n'a pas laisse de message pour le moment."
        : candidate.message.trim();

    return AppScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.52,
      maxChildSize: 0.94,
      trailing: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            size: 16,
            color: Color(0xFF9AA3AE),
          ),
        ),
      ),
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: candidate.avatar.isNotEmpty
                      ? NetworkImage(candidate.avatar)
                      : null,
                  child: candidate.avatar.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF9AA3AE),
                        )
                      : null,
                ),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    AppGap.h6,
                    Text(
                      '${candidate.rating.toStringAsFixed(1)} (${candidate.reviewsCount} avis)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF97A0AB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h24,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gray50,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                _ProfileInfoRow(
                  icon: Icons.edit_outlined,
                  label: 'Tarif propose',
                  trailing: Text(
                    candidate.proposedPrice,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: AppColors.ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const _SheetSectionDivider(),
                _ProfileInfoRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Message',
                  trailing: Flexible(
                    child: Text(
                      messageText,
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8F98A3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h18,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gray50,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                AppGap.h14,
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.work_outline_rounded,
                      value: '${candidate.completedMissions}',
                      label: 'Missions',
                    ),
                    AppGap.w10,
                    _StatCard(
                      icon: Icons.schedule_rounded,
                      value: replyValue,
                      label: 'Reponse',
                    ),
                    AppGap.w10,
                    _StatCard(
                      icon: Icons.star_border_rounded,
                      value: candidate.rating.toStringAsFixed(1),
                      label: 'Note',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onViewProfile != null) ...[
            AppGap.h18,
            OutlinedButton.icon(
              onPressed: onViewProfile,
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text(
                'Voir le profil complet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: Color(0xFFE5E8EC)),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
      footer: onAccept == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onChat != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8EBEF)),
                    ),
                    child: _ProfileInfoRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Message',
                      compact: true,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFFB5BDC7),
                      ),
                      onTap: onChat,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool compact;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 14 : 18,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.ink),
          AppGap.w12,
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _SheetSectionDivider extends StatelessWidget {
  const _SheetSectionDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    color: AppColors.gray50,
    indent: 16,
    endIndent: 16,
  );
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
        padding: AppInsets.v14,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            AppGap.h6,
            Text(
              value,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppGap.h2,
            Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
