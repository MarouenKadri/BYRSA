import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import 'client_mission_detail_page.dart';
import 'create_mission_page.dart';
import '../../../../../app/widgets/cigale_app_bar.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📋 Inkern - Page Mes Missions (Client)
/// Tabs : Publiées · En cours · Archivées
/// ═══════════════════════════════════════════════════════════════════════════

class ClientMissionsPage extends StatelessWidget {
  final VoidCallback? onGoToAccount;
  const ClientMissionsPage({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CigaleAppBar(
          pageTitle: 'Mes missions',
          onGoToAccount: onGoToAccount,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Publiées'),
              Tab(text: 'En cours'),
              Tab(text: 'Archivées'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ClientMissionTab(filter: _ClientTabFilter.published),
            _ClientMissionTab(filter: _ClientTabFilter.inProgress),
            _ClientMissionTab(filter: _ClientTabFilter.archived),
          ],
        ),
      ),
    );
  }
}

enum _ClientTabFilter { published, inProgress, archived }

class _ClientMissionTab extends StatefulWidget {
  final _ClientTabFilter filter;
  const _ClientMissionTab({required this.filter});

  @override
  State<_ClientMissionTab> createState() => _ClientMissionTabState();
}

class _ClientMissionTabState extends State<_ClientMissionTab> {
  bool _isLoading = true;

  static const _inProgressStatuses = {
    MissionStatus.prestaChosen,
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completed,
    MissionStatus.waitingPayment,
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<Mission> _filter(List<Mission> all) {
    switch (widget.filter) {
      case _ClientTabFilter.published:
        return all.where((m) =>
          m.status == MissionStatus.draft ||
          m.status == MissionStatus.waitingCandidates ||
          m.status == MissionStatus.candidateReceived).toList();
      case _ClientTabFilter.inProgress:
        return all.where((m) => _inProgressStatuses.contains(m.status)).toList();
      case _ClientTabFilter.archived:
        return all.where((m) =>
          m.status == MissionStatus.closed ||
          m.status == MissionStatus.cancelled ||
          m.status == MissionStatus.dispute ||
          m.status == MissionStatus.expired).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SkeletonList(key: ValueKey('skeleton'));

    final missions = _filter(context.watch<MissionProvider>().clientMissions);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: missions.isEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              icon: _emptyIcon,
              title: _emptyTitle,
              subtitle: _emptySubtitle,
              buttonText: widget.filter == _ClientTabFilter.published ? 'Créer une mission' : null,
              onButtonPressed: widget.filter == _ClientTabFilter.published
                  ? () => Navigator.push(context, slideUpRoute(page: const PostMissionFlow()))
                  : null,
            )
          : ListView.builder(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: missions.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClientMissionCard(
                  mission: missions[index],
                  onTap: () => Navigator.push(
                    context,
                    slideUpRoute(page: ClientMissionDetailPage(mission: missions[index])),
                  ),
                ),
              ),
            ),
    );
  }

  IconData get _emptyIcon => switch (widget.filter) {
    _ClientTabFilter.published   => Icons.assignment_outlined,
    _ClientTabFilter.inProgress  => Icons.work_outline_rounded,
    _ClientTabFilter.archived    => Icons.inventory_2_outlined,
  };

  String get _emptyTitle => switch (widget.filter) {
    _ClientTabFilter.published   => 'Aucune mission publiée',
    _ClientTabFilter.inProgress  => 'Aucune mission en cours',
    _ClientTabFilter.archived    => 'Aucune mission archivée',
  };

  String get _emptySubtitle => switch (widget.filter) {
    _ClientTabFilter.published   => 'Créez une mission pour trouver un prestataire',
    _ClientTabFilter.inProgress  => 'Vos missions acceptées apparaîtront ici',
    _ClientTabFilter.archived    => 'Vos missions terminées apparaîtront ici',
  };
}

// ─── Client Mission Card ──────────────────────────────────────────────────────

class ClientMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;

  const ClientMissionCard({super.key, required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mission.status == MissionStatus.inProgress)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.card),
                      topRight: Radius.circular(AppRadius.card),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('Mission en cours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Spacer(),
                      const Icon(Icons.handyman_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                )
              else if (mission.status == MissionStatus.onTheWay)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.card),
                      topRight: Radius.circular(AppRadius.card),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_car_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Prestataire en route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              if (mission.images.isNotEmpty)
                MissionImageHeader(images: mission.images, fallbackIcon: mission.categoryIcon, heroTag: 'mission-img-${mission.id}'),
              Padding(
                padding: AppPadding.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CategoryChip(icon: mission.categoryIcon, label: mission.categoryName, color: mission.categoryColor, compact: true),
                      const Spacer(),
                      MissionStatusBadge(status: mission.status, compact: true),
                    ]),
                    const SizedBox(height: 12),
                    Text(mission.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(mission.description, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(children: [
                      InfoChip(icon: Icons.calendar_today_rounded, text: mission.formattedDate, compact: true),
                      const SizedBox(width: 10),
                      InfoChip(icon: Icons.schedule_rounded, text: mission.timeSlot, compact: true),
                    ]),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                    Row(children: [
                      BudgetText(budget: mission.budget),
                      const Spacer(),
                      _buildFooterRight(),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterRight() {
    switch (mission.status) {
      case MissionStatus.candidateReceived:
        if (mission.candidatesCount > 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
            ]),
          );
        }
        return const SizedBox.shrink();
      case MissionStatus.prestaChosen:
      case MissionStatus.confirmed:
      case MissionStatus.onTheWay:
      case MissionStatus.inProgress:
      case MissionStatus.completed:
      case MissionStatus.waitingPayment:
        if (mission.assignedPresta != null) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            UserAvatar(imageUrl: mission.assignedPresta!.avatarUrl, radius: 13, showVerified: mission.assignedPresta!.isVerified),
            const SizedBox(width: 6),
            Text(mission.assignedPresta!.name, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ]);
        }
        return const SizedBox.shrink();
      case MissionStatus.closed:
        if (mission.rating != null) return RatingWidget(rating: mission.rating!.toDouble(), showStars: true, compact: true);
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
