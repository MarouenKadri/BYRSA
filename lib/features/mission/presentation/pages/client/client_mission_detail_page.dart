import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/detail/mission_detail_primitives.dart';
import '../../widgets/detail/mission_detail_template.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import 'candidates_page.dart';
import '../../widgets/detail/client_detail_sections.dart';
import 'create_mission_page.dart';
import 'mission_validation_page.dart';
import 'tracking_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ClientMissionDetailPage — rôle client
/// Extends MissionDetailBase (Template Method) + délègue les sections à
/// client_detail_sections.dart
/// ═══════════════════════════════════════════════════════════════════════════

class ClientMissionDetailPage extends StatefulWidget {
  final Mission mission;
  final Function(PrestaInfo)? onCandidateAccepted;

  const ClientMissionDetailPage({
    super.key,
    required this.mission,
    this.onCandidateAccepted,
  });

  @override
  State<ClientMissionDetailPage> createState() =>
      _ClientMissionDetailPageState();
}

class _ClientMissionDetailPageState
    extends MissionDetailBase<ClientMissionDetailPage> {
  bool _menuOpen = false;

  // ─── Computed flags ─────────────────────────────────────────────────────────

  bool get canModify =>
      mission.status == MissionStatus.waitingCandidates ||
      mission.status == MissionStatus.candidateReceived ||
      mission.status == MissionStatus.draft;

  bool get canCancel =>
      mission.status == MissionStatus.waitingCandidates ||
      mission.status == MissionStatus.candidateReceived ||
      mission.status == MissionStatus.prestaChosen ||
      mission.status == MissionStatus.confirmed ||
      mission.status == MissionStatus.draft;

  // ─── MissionDetailBase — abstract overrides ──────────────────────────────

  @override
  Mission get widgetMission => widget.mission;

  @override
  Mission syncMission(BuildContext ctx) {
    return ctx.watch<MissionProvider>().clientMissions.firstWhere(
          (m) => m.id == widget.mission.id,
          orElse: () => mission,
        );
  }

  @override
  bool get showTimeline => mission.status != MissionStatus.draft;

  @override
  bool get isBottomHidden => mission.status == MissionStatus.closed;

  @override
  Widget? buildHeroMenu(BuildContext ctx) {
    if (!canModify && !canCancel) return null;
    return DetailCircleBtn(
      icon: Icons.more_horiz_rounded,
      isActive: _menuOpen,
      onTap: _showMissionOptions,
    );
  }

  @override
  Widget buildTagsPrice(BuildContext ctx) {
    final daysLeft = mission.date.difference(DateTime.now()).inDays;
    final daysLabel = daysLeft > 0 ? '+$daysLeft jours' : "Aujourd'hui";

    return Row(
      children: [
        DetailLuxuryPill(label: daysLabel),
        AppGap.w10,
        DetailLuxuryPill(
          label:
              '${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}',
        ),
        const Spacer(),
        Text(
          mission.budget.displayText,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  @override
  StatusBannerConfig? resolveBanner() {
    switch (mission.status) {
      case MissionStatus.onTheWay:
        return StatusBannerConfig(
          color: AppColors.iosBlue,
          icon: Icons.directions_car_rounded,
          title: mission.assignedPresta != null
              ? '${mission.assignedPresta!.name} est en route'
              : 'Votre prestataire est en route',
          subtitle: 'Suivez son arrivee en temps reel depuis cette page.',
        );
      case MissionStatus.inProgress:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.handyman_rounded,
          title: 'Mission en cours',
          subtitle: mission.assignedPresta != null
              ? '${mission.assignedPresta!.name} est actuellement sur place.'
              : 'Le prestataire est actuellement sur place.',
          pulse: true,
        );
      case MissionStatus.completionRequested:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: 'Le prestataire a signale la fin',
          subtitle:
              'Confirmez la mission ou signalez un probleme pour bloquer le paiement.',
        );
      case MissionStatus.completed:
      case MissionStatus.waitingPayment:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: 'Validation en attente',
          subtitle:
              'Vous disposez de 12h pour valider ou signaler un probleme avant le deblocage automatique.',
        );
      case MissionStatus.closed:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.check_circle_outline_rounded,
          title: 'Mission terminee',
          subtitle:
              'Le paiement a ete libere et la mission est maintenant cloturee.',
        );
      case MissionStatus.cancelled:
        return StatusBannerConfig(
          color: AppColors.error,
          icon: Icons.close_rounded,
          title: 'Mission annulee',
          subtitle:
              "Cette mission est closee et aucune action supplementaire n'est requise.",
        );
      default:
        return null;
    }
  }

  @override
  Widget buildRoleSection(BuildContext ctx) {
    if (mission.status == MissionStatus.candidateReceived ||
        mission.status == MissionStatus.waitingCandidates) {
      return ClientCandidatesCard(
        count: mission.candidatesCount,
        onViewCandidates: _openCandidates,
      );
    }
    if (mission.assignedPresta != null) {
      final presta = mission.assignedPresta!;
      final contactable = mission.status != MissionStatus.waitingPayment &&
          mission.status != MissionStatus.closed;
      return Column(
        children: [
          ClientPrestaCard(
            presta: presta,
            status: mission.status,
            rating: mission.rating,
            onPhone: contactable ? () => _openPhone(presta) : null,
            onChat: contactable ? () => _openChat(presta) : null,
            onViewProfile: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => FreelancerProfileView(
                  freelancerId: presta.id,
                  freelancerName: presta.name,
                  freelancerAvatar: presta.avatarUrl,
                  rating: presta.rating,
                  reviewsCount: presta.reviewsCount,
                  missionsCount: presta.completedMissions,
                ),
              ),
            ),
          ),
          if (mission.status == MissionStatus.completionRequested)
            ClientCompletionRequestedCard(
              mission: mission,
              onConfirm: _openValidationScreen,
              onDispute: _openCompletionDispute,
            ),
          if (mission.status == MissionStatus.confirmed ||
              mission.status == MissionStatus.onTheWay ||
              mission.status == MissionStatus.inProgress)
            ClientTrackingCard(
              mission: mission,
              onOpenTracking: _openTracking,
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget buildBottom(BuildContext ctx) {
    if (mission.status == MissionStatus.waitingPayment) {
      return DetailBottomArea(
        child: DetailTealButton(
          label: 'Valider et libérer le paiement',
          icon: Icons.check_circle_rounded,
          onTap: _openValidationScreen,
        ),
      );
    }

    if (mission.status == MissionStatus.completionRequested) {
      return DetailBottomArea(
        caption: 'Le prestataire a demande la cloture de la mission',
        child: DetailTealButton(
          label: 'Verifier et confirmer la mission',
          icon: Icons.verified_rounded,
          onTap: _openValidationScreen,
        ),
      );
    }

    if (mission.status == MissionStatus.onTheWay ||
        mission.status == MissionStatus.inProgress) {
      return DetailBottomArea(
        child: DetailTealButton(
          label: mission.status == MissionStatus.onTheWay
              ? "Suivre l'arrivée du prestataire"
              : 'Voir la progression en direct',
          icon: Icons.location_on_rounded,
          color: AppColors.iosBlue,
          onTap: _openTracking,
        ),
      );
    }

    if (mission.status == MissionStatus.candidateReceived) {
      return DetailBottomArea(
        caption: 'Choisissez votre prestataire',
        child: DetailTealButton(
          label:
              'Voir les ${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}',
          icon: Icons.people_alt_rounded,
          onTap: _openCandidates,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _showMissionOptions() async {
    setState(() => _menuOpen = true);
    await showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: ClientActionSheet(
        canModify: canModify,
        canCancel: canCancel,
        onEdit: () {
          Navigator.pop(context);
          _editMission();
        },
        onShare: () {
          Navigator.pop(context);
          _shareMission();
        },
        onCancel: () {
          Navigator.pop(context);
          _showCancelDialog();
        },
      ),
    );
    if (mounted) setState(() => _menuOpen = false);
  }

  void _openPhone(PrestaInfo presta) {
    showAppSnackBar(
      context,
      'Appel vers ${presta.name}...',
      icon: Icons.phone_rounded,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _shareMission() async {
    final shareText = [
      mission.title,
      mission.address.fullAddress,
      '${mission.formattedDate} · ${mission.timeSlot}',
      'Budget: ${mission.budget.displayText}',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Details de la mission copies',
      icon: Icons.share_outlined,
      duration: const Duration(seconds: 2),
    );
  }

  void _openCandidates() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CandidatesPage(
            missionId: mission.id,
            missionTitle: mission.title,
            missionBudget: mission.budget.displayText,
          ),
        ),
      );

  void _openTracking() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrackingPage(mission: mission)),
      );

  Future<void> _openValidationScreen() async => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionValidationPage(mission: mission),
        ),
      );

  void _openChat(PrestaInfo presta) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            contactName: presta.name,
            contactAvatar: presta.avatarUrl,
            isVerified: presta.isVerified,
            missionTitle: mission.title,
          ),
        ),
      );

  Future<void> _editMission() async => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostMissionFlow(mission: mission)),
      );

  void _showCancelDialog() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: ClientCancelSheet(
        missionTitle: mission.title,
        onConfirm: () {
          context.read<MissionProvider>().updateMissionStatus(
                mission.id,
                MissionStatus.cancelled,
              );
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openCompletionDispute() {
    showAppDialog(
      context: context,
      title: const Text('Signaler un problème'),
      content: const Text(
        'Le paiement restera bloque pendant l analyse du litige par l equipe support.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Signaler',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        context.read<MissionProvider>().updateMissionStatus(
              mission.id,
              MissionStatus.dispute,
            );
        Navigator.pop(context);
      },
    );
  }
}
