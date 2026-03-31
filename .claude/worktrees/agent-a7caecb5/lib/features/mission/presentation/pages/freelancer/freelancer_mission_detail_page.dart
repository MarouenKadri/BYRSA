import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../widgets/freelancer/freelancer_widgets.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import '../shared/mission_map_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📄 Inkern - Page Détail Mission (Freelancer)
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerMissionDetailPage extends StatefulWidget {
  final Mission mission;
  /// true = mission du freelancer (postulée / en cours / archivée) → pas de nouvelle proposition
  /// false = mission publique depuis l'explorer → peut postuler
  final bool isOwn;
  const FreelancerMissionDetailPage({super.key, required this.mission, this.isOwn = false});

  @override
  State<FreelancerMissionDetailPage> createState() => _FreelancerMissionDetailPageState();
}

class _FreelancerMissionDetailPageState extends State<FreelancerMissionDetailPage> {
  late Mission _mission;

  bool get _isAccepted => const {
    MissionStatus.prestaChosen,
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.waitingPayment,
    MissionStatus.completed,
    MissionStatus.closed,
  }.contains(_mission.status);
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _priceController.text = _mission.budget.averageAmount.toInt().toString();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync live depuis le provider (missions propres) ou publicMissions (explorer)
    if (widget.isOwn) {
      final live = context.watch<MissionProvider>().freelancerMissions
          .firstWhere((m) => m.id == widget.mission.id, orElse: () => _mission);
      if (live.status != _mission.status) _mission = live;
    }

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
                Positioned.fill(child: hasImages ? _buildImageGallery() : _buildGradientHeader()),
                Positioned(
                  top: topPadding + 4,
                  left: 4,
                  child: _buildCircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
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
                  if (widget.isOwn) StatusTimeline(status: _mission.status),
                  _buildMainInfo(),
                  _buildDescription(),
                  _buildLocation(),
                  _buildBudget(),
                  _buildPaymentStatusBanner(),
                  if (_mission.client != null) ClientSection(
                    client: _mission.client!,
                    missionBudget: _mission.budget.displayText,
                    canViewProfile: true,
                    onMessage: _isAccepted ? _openChat : null,
                    onPhone: _isAccepted ? _openPhone : null,
                  ),
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
            if (_mission.address.distance != null) DistanceBadge(distance: _mission.address.distance!),
          ]),
          const SizedBox(height: 16),
          Text(_mission.title, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(_mission.postedAtText, style: AppTextStyles.caption),
            const SizedBox(width: 16),
            Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('${_mission.candidatesCount} candidat${_mission.candidatesCount > 1 ? 's' : ''}', style: AppTextStyles.caption),
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Budget proposé', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(_mission.budget.displayText, style: AppTextStyles.priceLarge),
          ])),
        ],
      ),
    );
  }

  // ─── Payment Status Banner ────────────────────────────────────────────────

  Widget _buildPaymentStatusBanner() {
    final presta = _mission.budget.averageAmount * 0.9;

    if (_mission.status == MissionStatus.prestaChosen || _mission.status == MissionStatus.confirmed) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'Vous recevrez ~${presta.round()} € à la validation client',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          )),
        ]),
      );
    }
    if (_mission.status == MissionStatus.onTheWay || _mission.status == MissionStatus.inProgress) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.info.withOpacity(0.3)!),
        ),
        child: Row(children: [
          Icon(Icons.payments_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mission en cours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 2),
            Text('Vous recevrez ${presta.round()} € à la validation client',
                style: TextStyle(fontSize: 12, color: AppColors.info)),
          ])),
        ]),
      );
    }
    if (_mission.status == MissionStatus.completed || _mission.status == MissionStatus.waitingPayment) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)!),
        ),
        child: Row(children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('En attente de validation client', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
            const SizedBox(height: 2),
            Text('Validation automatique dans 48h si aucune action du client',
                style: TextStyle(fontSize: 12, color: AppColors.warning)),
          ])),
        ]),
      );
    }
    return const SizedBox.shrink();
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────
  //
  // Logique :
  //   isOwn = false (explorer public) → peut postuler
  //   isOwn = true :
  //     candidates / pending  → candidature déjà envoyée, pas de nouvelle
  //     assigned / inProgress → en cours, contacter le client
  //     completed             → archivée, aucun bouton

  Widget _buildBottomBar() {
    final bottom = MediaQuery.of(context).padding.bottom;

    // ── Mission publique : peut postuler (sauf si déjà postulé) ─────────────
    if (!widget.isOwn) {
      final alreadyApplied = context.watch<MissionProvider>()
          .freelancerMissions.any((m) => m.id == _mission.id);
      if (alreadyApplied) {
        return _BottomBarShell(
          bottom: bottom,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20),
                SizedBox(width: 10),
                Text('Candidature envoyée · En attente de réponse',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
              ],
            ),
          ),
        );
      }
      return _BottomBarShell(
        bottom: bottom,
        child: ElevatedButton.icon(
          onPressed: _openProposalSheet,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Envoyer ma proposition'),
          style: _primaryBtn,
        ),
      );
    }

    // ── Mission du freelancer : comportement selon statut ────────────────────
    return switch (_mission.status) {

      // Postulée — candidature déjà envoyée, on informe sans permettre de repostuler
      MissionStatus.candidateReceived || MissionStatus.waitingCandidates => _BottomBarShell(
        bottom: bottom,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 10),
              Text('Candidature envoyée · En attente de réponse',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
            ],
          ),
        ),
      ),

      // En cours / Confirmée — contacter le client uniquement
      MissionStatus.prestaChosen || MissionStatus.confirmed || MissionStatus.onTheWay || MissionStatus.inProgress => _BottomBarShell(
        bottom: bottom,
        child: ElevatedButton.icon(
          onPressed: _mission.client != null ? _openChat : null,
          icon: const Icon(Icons.chat_rounded),
          label: const Text('Contacter le client'),
          style: _primaryBtn,
        ),
      ),

      // Archivée — mission terminée, aucune action disponible
      MissionStatus.completed || MissionStatus.waitingPayment || MissionStatus.closed => _BottomBarShell(
        bottom: bottom,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, color: AppColors.textTertiary, size: 18),
              const SizedBox(width: 10),
              Text('Mission archivée', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              if (_mission.rating != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                const SizedBox(width: 4),
                Text('${_mission.rating}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ],
            ],
          ),
        ),
      ),

      _ => const SizedBox.shrink(),
    };
  }

  ButtonStyle get _primaryBtn => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    minimumSize: const Size(double.infinity, 0),
  );

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _openPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text('Appel vers ${_mission.client?.name ?? 'le client'}...'),
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

  void _openChat() {
    if (_mission.client == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          contactName: _mission.client!.name,
          contactAvatar: _mission.client!.avatarUrl,
          isVerified: _mission.client!.isVerified,
          missionTitle: _mission.title,
        ),
      ),
    );
  }

  void _openProposalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProposalSheet(
        mission: _mission,
        priceController: _priceController,
        messageController: _messageController,
        onSubmit: (double price, String message) {
          context.read<MissionProvider>().submitProposal(
            _mission,
            price: price,
            message: message,
          ).catchError((e) => debugPrint('submitProposal UI error: $e'));
          Navigator.pop(context); // ferme le sheet
          ApplicationSuccessDialog.show(
            context,
            clientName: _mission.client?.name ?? 'le client',
            onContinue: () {
              Navigator.pop(context); // ferme le dialog
              Navigator.pop(context); // retourne à la liste
            },
          );
        },
      ),
    );
  }
}

// ─── Shell commun bottom bar ──────────────────────────────────────────────────

class _BottomBarShell extends StatelessWidget {
  final double bottom;
  final Widget child;
  const _BottomBarShell({required this.bottom, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: child,
    );
  }
}

// ─── Bottom Sheet Proposition ────────────────────────────────────────────────

class _ProposalSheet extends StatefulWidget {
  final Mission mission;
  final TextEditingController priceController;
  final TextEditingController messageController;
  final void Function(double price, String message) onSubmit;

  const _ProposalSheet({
    required this.mission,
    required this.priceController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  State<_ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends State<_ProposalSheet> {
  // Quick tarif chips (±20% autour du budget)
  late final List<int> _quickAmounts;
  int _messageLength = 0;

  @override
  void initState() {
    super.initState();
    final base = widget.mission.budget.totalAmount.toInt();
    if (base > 0) {
      _quickAmounts = [
        (base * 0.8).round(),
        (base * 0.9).round(),
        base,
        (base * 1.1).round(),
        (base * 1.2).round(),
      ];
    } else {
      _quickAmounts = [50, 80, 100, 120, 150];
    }
    _messageLength = widget.messageController.text.length;
    widget.messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (mounted) setState(() => _messageLength = widget.messageController.text.length);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onMessageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final priceText = widget.priceController.text;
    final canSubmit = priceText.isNotEmpty && int.tryParse(priceText) != null && int.parse(priceText) > 0;

    return SizedBox(
      height: screenHeight * 0.90,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ─── Handle ───
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),

            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Votre proposition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ─── Mission summary ───
            Container(
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.mission.categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.mission.categoryIcon, color: widget.mission.categoryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.mission.title, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(widget.mission.formattedDate, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.mission.budget.displayText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),

            // ─── Formulaire scrollable ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label tarif ──
                    Row(
                      children: [
                        const Text('Votre tarif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Obligatoire', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: widget.priceController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.border),
                        prefixIcon: const Icon(Icons.euro_rounded, color: AppColors.primary, size: 22),
                        suffixText: '€',
                        suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.primary.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),

                    // ── Quick amounts ──
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickAmounts.map((amount) {
                          final isActive = widget.priceController.text == amount.toString();
                          return GestureDetector(
                            onTap: () {
                              widget.priceController.text = amount.toString();
                              setState(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                                border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: 1.5),
                              ),
                              child: Text(
                                '$amount €',
                                style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 20),

                    // ── Message ──
                    Row(
                      children: [
                        const Text('Message au client', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                          child: Text('Optionnel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                        ),
                        const Spacer(),
                        Text('$_messageLength/400', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: widget.messageController,
                      maxLines: 5,
                      maxLength: 400,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(
                        hintText: 'Présentez-vous, vos atouts, votre expérience... Donnez envie au client de vous choisir !',
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ─── Bouton Envoyer (fixe en bas) ───
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canSubmit ? () => widget.onSubmit(
                    double.parse(widget.priceController.text),
                    widget.messageController.text,
                  ) : null,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(
                    canSubmit ? 'Envoyer ma proposition · ${widget.priceController.text} €' : 'Envoyer ma proposition',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    disabledForegroundColor: AppColors.textHint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.label.copyWith(fontSize: 15)),
        ])),
        if (showMapIcon) const Icon(Icons.map_rounded, color: AppColors.primary, size: 22),
      ],
    );
  }
}
