import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../widgets/client/client_widgets.dart';
import 'candidates_page.dart';
import 'create_mission_page.dart';
import 'tracking_screen.dart';
import 'mission_validation_screen.dart';
import '../shared/mission_map_page.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📄 Inkern - Page Détail Mission (Client)
/// ═══════════════════════════════════════════════════════════════════════════

class ClientMissionDetailPage extends StatefulWidget {
  final Mission mission;
  final Function(PrestaInfo)? onCandidateAccepted;

  const ClientMissionDetailPage({super.key, required this.mission, this.onCandidateAccepted});

  @override
  State<ClientMissionDetailPage> createState() => _ClientMissionDetailPageState();
}

class _ClientMissionDetailPageState extends State<ClientMissionDetailPage> {
  late Mission _mission;
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();

  bool get canModify =>
      _mission.status == MissionStatus.waitingCandidates ||
      _mission.status == MissionStatus.candidateReceived ||
      _mission.status == MissionStatus.draft;

  bool get canCancel =>
      _mission.status == MissionStatus.waitingCandidates ||
      _mission.status == MissionStatus.candidateReceived ||
      _mission.status == MissionStatus.prestaChosen ||
      _mission.status == MissionStatus.confirmed ||
      _mission.status == MissionStatus.draft;

  bool get isReadOnly => _mission.status == MissionStatus.closed;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync live depuis le provider → se met à jour quand le freelancer change le statut
    final liveMissions = context.watch<MissionProvider>().clientMissions;
    final live = liveMissions.firstWhere((m) => m.id == widget.mission.id, orElse: () => _mission);
    if (live.status != _mission.status) _mission = live;

    final hasImages = _mission.images.isNotEmpty;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Image fixe ───
          SizedBox(
            height: hasImages ? 280 : 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasImages
                      ? Hero(tag: 'mission-img-${widget.mission.id}', child: _buildImageGallery())
                      : _buildGradientHeader(),
                ),
                Positioned(
                  top: topPadding + 4, left: 4,
                  child: _buildCircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                ),
                if (canModify || canCancel)
                  Positioned(
                    top: topPadding + 4, right: 4,
                    child: _buildMenuButton(),
                  ),
              ],
            ),
          ),
          // ─── Header fixe ───
          _buildHeader(),
          // ─── Contenu scrollable ───
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_mission.status != MissionStatus.draft)
                    StatusTimeline(status: _mission.status),
                  _buildMissionStartedAlert(),
                  _buildMainInfo(),
                  _buildDescription(),
                  _buildLocation(),
                  _buildBudget(),
                  _buildPaymentStatusBanner(),
                  if (_mission.status == MissionStatus.candidateReceived || _mission.status == MissionStatus.waitingCandidates)
                    CandidatesSection(candidatesCount: _mission.candidatesCount, onViewCandidates: _openCandidates)
                  else if (_mission.assignedPresta != null)
                    SelectedPrestaSection(
                      presta: _mission.assignedPresta!,
                      status: _mission.status,
                      rating: _mission.rating,
                      onContact: (_mission.status != MissionStatus.waitingPayment && _mission.status != MissionStatus.closed) ? () => _openChat(_mission.assignedPresta!) : null,
                      onPhone: (_mission.status != MissionStatus.waitingPayment && _mission.status != MissionStatus.closed) ? () => _openPhone(_mission.assignedPresta!) : null,
                      onViewProfile: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreelancerProfileView(
                            freelancerId: _mission.assignedPresta!.id,
                            freelancerName: _mission.assignedPresta!.name,
                            freelancerAvatar: _mission.assignedPresta!.avatarUrl,
                            rating: _mission.assignedPresta!.rating,
                            reviewsCount: _mission.assignedPresta!.reviewsCount,
                            missionsCount: _mission.assignedPresta!.completedMissions,
                          ),
                        ),
                      ),
                    ),
                  if (!isReadOnly) _buildActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── Header image fixe ────────────────────────────────────────────────────

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.button),
      child: IconButton(icon: Icon(icon, color: AppColors.textPrimary), onPressed: onTap),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.button),
      child: IconButton(
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
        onPressed: () => _showMissionOptions(context),
      ),
    );
  }

  void _showMissionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MissionActionSheet(
        title: _mission.title,
        canModify: canModify,
        canCancel: canCancel,
        onEdit: () { Navigator.pop(context); _editMission(); },
        onCancel: () { Navigator.pop(context); _showCancelDialog(); },
      ),
    );
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        PageView.builder(
          controller: _imageController,
          itemCount: _mission.images.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            final src = _mission.images[index];
            final isLocal = !src.startsWith('http');
            final errorWidget = (_, __, ___) => Container(color: AppColors.divider, child: Icon(_mission.categoryIcon, size: 64, color: AppColors.textHint));
            return isLocal
                ? Image.file(File(src), fit: BoxFit.cover, errorBuilder: errorWidget)
                : Image.network(src, fit: BoxFit.cover, errorBuilder: errorWidget);
          },
        ),
        if (_mission.images.length > 1) ...[
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_mission.images.length, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          Positioned(
            bottom: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
              child: Text('${_currentImageIndex + 1}/${_mission.images.length}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_mission.categoryColor.withOpacity(0.8), _mission.categoryColor.withOpacity(0.6)],
        ),
      ),
      child: Center(child: Icon(_mission.categoryIcon, size: 64, color: Colors.white.withOpacity(0.5))),
    );
  }

  // ─── Sections ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: AppPadding.cardLarge,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CategoryChip(icon: _mission.categoryIcon, label: _mission.categoryName, color: _mission.categoryColor),
            const Spacer(),
            MissionStatusBadge(status: _mission.status),
          ]),
          const SizedBox(height: 16),
          Text(_mission.title, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(_mission.postedAtText, style: AppTextStyles.caption),
          ]),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return CardContainer(
      child: Row(children: [
        _InfoTile(icon: Icons.calendar_today_rounded, label: 'Date', value: _mission.formattedDate),
        _VerticalDivider(),
        _InfoTile(icon: Icons.schedule_rounded, label: 'Horaire', value: _mission.timeSlot),
        _VerticalDivider(),
        _InfoTile(icon: Icons.timer_rounded, label: 'Durée', value: _mission.duration),
      ]),
    );
  }

  Widget _buildDescription() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.description_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Text(_mission.description, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return CardContainer(
      onTap: _openMap,
      child: _LocationRow(
        icon: Icons.location_on_rounded, iconColor: AppColors.urgent,
        label: 'Lieu d\'intervention', value: _mission.address.fullAddress,
        showMapIcon: true,
      ),
    );
  }

  Widget _buildBudget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.button)),
            child: const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _mission.budget.type == BudgetType.hourly ? 'Tarif horaire' : 'Budget total',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(_mission.budget.displayText, style: AppTextStyles.priceLarge),
              if (_mission.budget.type == BudgetType.hourly && _mission.budget.totalAmount > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Total estimé : ${_mission.budget.totalAmount.round()} €',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary.withOpacity(0.75)),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final actions = <Widget>[];
    if (canModify) {
      actions.add(ActionTile(icon: Icons.edit_rounded, title: 'Modifier la mission', subtitle: 'Changer les détails ou le budget', onTap: _editMission));
    }
    if (canCancel) {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 8));
      actions.add(ActionTile(icon: Icons.cancel_rounded, title: 'Annuler la mission', subtitle: 'La mission sera supprimée définitivement', isDestructive: true, onTap: _showCancelDialog));
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Column(children: actions));
  }

  // ─── Bannière "Mission démarrée" (inProgress) ────────────────────────────

  Widget _buildMissionStartedAlert() {
    if (_mission.status == MissionStatus.inProgress) {
      final presta = _mission.assignedPresta;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.greenActive, AppColors.greenActiveDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [BoxShadow(color: AppColors.greenActive.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            const _PulsingDot(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mission démarrée !',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    presta != null
                        ? '${presta.name} est sur place et travaille actuellement'
                        : 'Votre prestataire est sur place et travaille actuellement',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.88), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.handyman_rounded, color: Colors.white, size: 26),
          ],
        ),
      );
    }

    if (_mission.status == MissionStatus.onTheWay) {
      final presta = _mission.assignedPresta;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.blueTrackingBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_car_rounded, color: AppColors.blueTracking, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                presta != null
                    ? '${presta.name} est en route vers vous'
                    : 'Votre prestataire est en route',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blueTrackingText),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ─── Payment Status Banner ────────────────────────────────────────────────

  Widget _buildPaymentStatusBanner() {
    final escrowAmount = _mission.budget.averageAmount * 0.9;
    if (_mission.status == MissionStatus.confirmed ||
        _mission.status == MissionStatus.onTheWay ||
        _mission.status == MissionStatus.inProgress ||
        _mission.status == MissionStatus.completed) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(Icons.lock_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${_mission.budget.averageAmount.round()} € sécurisés par Inkern',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 2),
            Text('Sera libéré au prestataire à la validation',
                style: TextStyle(fontSize: 12, color: AppColors.success)),
          ])),
        ]),
      );
    }
    if (_mission.status == MissionStatus.waitingPayment) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)!),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.pending_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Text('Validation requise', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
          ]),
          const SizedBox(height: 6),
          Text(
            '${escrowAmount.round()} € en attente de libération au prestataire. Validez la mission pour confirmer le paiement.',
            style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.4),
          ),
        ]),
      );
    }
    return const SizedBox.shrink();
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget? _buildBottomBar() {
    if (isReadOnly) return null;

    final bottom = MediaQuery.of(context).padding.bottom;

    if (_mission.status == MissionStatus.waitingPayment) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openValidationScreen,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Valider et libérer le paiement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    if (_mission.status == MissionStatus.onTheWay || _mission.status == MissionStatus.inProgress) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openTracking,
            icon: const Icon(Icons.location_on_rounded),
            label: Text(_mission.status == MissionStatus.onTheWay ? 'Suivre l\'arrivée du prestataire' : 'Voir la progression en direct'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iosBlue, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget', style: AppTextStyles.caption),
              Text(_mission.budget.displayText, style: AppTextStyles.priceLarge.copyWith(fontSize: 22)),
            ],
          ),
          const Spacer(),
          if (_mission.status == MissionStatus.candidateReceived)
            ElevatedButton.icon(
              onPressed: _openCandidates,
              icon: const Icon(Icons.people_alt_rounded),
              label: Text('${_mission.candidatesCount} candidat${_mission.candidatesCount > 1 ? 's' : ''}'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button))),
            )
          else if (_mission.assignedPresta != null && _mission.status != MissionStatus.waitingPayment && _mission.status != MissionStatus.closed)
            ElevatedButton.icon(
              onPressed: () => _openChat(_mission.assignedPresta!),
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Contacter'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button))),
            ),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _openPhone(PrestaInfo presta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text('Appel vers ${presta.name}...'),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MissionMapPage(address: _mission.address)),
    );
  }
  void _openCandidates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CandidatesPage(
          missionId: _mission.id,
          missionTitle: _mission.title,
          missionBudget: _mission.budget.displayText,
        ),
      ),
    );
  }
  void _openTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackingScreen(mission: _mission)),
    );
  }
  Future<void> _openValidationScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MissionValidationScreen(mission: _mission)),
    );
  }
  void _openChat(PrestaInfo presta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          contactName: presta.name,
          contactAvatar: presta.avatarUrl,
          isVerified: presta.isVerified,
          missionTitle: _mission.title,
        ),
      ),
    );
  }
  Future<void> _editMission() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostMissionFlow(mission: _mission)),
    );
  }

  void _showCancelDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelConfirmSheet(
        missionTitle: _mission.title,
        onConfirm: () {
          context.read<MissionProvider>().updateMissionStatus(_mission.id, MissionStatus.cancelled);
          Navigator.pop(context); // ferme sheet
          Navigator.pop(context); // ferme detail page
        },
      ),
    );
  }
}

// ─── Action Sheet Mission ─────────────────────────────────────────────────────

class _MissionActionSheet extends StatelessWidget {
  final String title;
  final bool canModify;
  final bool canCancel;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _MissionActionSheet({
    required this.title,
    required this.canModify,
    required this.canCancel,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          // Titre mission
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Actions
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                if (canModify)
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: canCancel ? Radius.zero : const Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        const Text('Modifier la mission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ]),
                    ),
                  ),
                if (canModify && canCancel)
                  Divider(height: 1, color: AppColors.divider, indent: 68),
                if (canCancel)
                  InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.vertical(
                      top: canModify ? Radius.zero : const Radius.circular(16),
                      bottom: const Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppColors.urgent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.cancel_rounded, size: 20, color: AppColors.urgent),
                        ),
                        const SizedBox(width: 14),
                        const Text('Annuler la mission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.urgent)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Fermer
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Fermer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirmation Annulation ──────────────────────────────────────────────────

class _CancelConfirmSheet extends StatelessWidget {
  final String missionTitle;
  final VoidCallback onConfirm;

  const _CancelConfirmSheet({required this.missionTitle, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          // Icône d'avertissement
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.urgent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded, color: AppColors.urgent, size: 32),
          ),
          const SizedBox(height: 16),

          // Titre
          const Text(
            'Annuler la mission ?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          // Nom de la mission
          Text(
            '"$missionTitle"',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.urgent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.urgent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.urgent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cette action est irréversible. La mission sera définitivement supprimée.',
                    style: TextStyle(fontSize: 13, color: AppColors.urgent, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bouton confirmer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.cancel_rounded, size: 18),
              label: const Text('Oui, annuler la mission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bouton garder
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Non, garder la mission',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliaires ─────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 50, color: AppColors.divider);
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(_anim.value),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(_anim.value * 0.5), blurRadius: 6, spreadRadius: 2)],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showMapIcon;

  const _LocationRow({required this.icon, required this.iconColor, required this.label, required this.value, this.showMapIcon = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.button)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.label.copyWith(fontSize: 15)),
          ]),
        ),
        if (showMapIcon) const Icon(Icons.map_rounded, color: AppColors.primary, size: 22),
      ],
    );
  }
}
