import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import 'freelancer_missions_page.dart';
import 'freelancer_mission_detail_page.dart';
import 'active_mission_screen.dart';
import '../../../../../app/widgets/cigale_app_bar.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📋 Inkern - Mes Missions (Freelancer)
/// Tabs : Postulées · En cours · Archivées
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerMyMissionsPage extends StatelessWidget {
  final VoidCallback? onGoToAccount;
  const FreelancerMyMissionsPage({super.key, this.onGoToAccount});

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
              Tab(text: 'Postulées'),
              Tab(text: 'En cours'),
              Tab(text: 'Archivées'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MissionTab(filter: _TabFilter.applied),
            _MissionTab(filter: _TabFilter.inProgress),
            _MissionTab(filter: _TabFilter.archived),
          ],
        ),
      ),
    );
  }
}

enum _TabFilter { applied, inProgress, archived }

class _MissionTab extends StatefulWidget {
  final _TabFilter filter;
  const _MissionTab({required this.filter});

  @override
  State<_MissionTab> createState() => _MissionTabState();
}

class _MissionTabState extends State<_MissionTab> {
  bool _isLoading = true;

  static const _activeStatuses = {
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completed,
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
      case _TabFilter.applied:
        return all.where((m) => m.status == MissionStatus.candidateReceived || m.status == MissionStatus.waitingCandidates || m.status == MissionStatus.prestaChosen).toList();
      case _TabFilter.inProgress:
        return all.where((m) => _activeStatuses.contains(m.status)).toList();
      case _TabFilter.archived:
        return all.where((m) => m.status == MissionStatus.closed || m.status == MissionStatus.waitingPayment || m.status == MissionStatus.cancelled || m.status == MissionStatus.dispute || m.status == MissionStatus.expired).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SkeletonList(key: ValueKey('skeleton'));

    final missions = _filter(context.watch<MissionProvider>().freelancerMissions);

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
            )
          : ListView.builder(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: missions.length,
              itemBuilder: (context, index) {
                final mission = missions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MyMissionCard(
                    mission: mission,
                    filter: widget.filter,
                    onTap: () => Navigator.push(
                      context,
                      slideUpRoute(
                        page: _activeStatuses.contains(mission.status)
                            ? ActiveMissionScreen(mission: mission)
                            : FreelancerMissionDetailPage(mission: mission, isOwn: true),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData get _emptyIcon => switch (widget.filter) {
    _TabFilter.applied   => Icons.send_rounded,
    _TabFilter.inProgress => Icons.work_outline_rounded,
    _TabFilter.archived  => Icons.inventory_2_outlined,
  };

  String get _emptyTitle => switch (widget.filter) {
    _TabFilter.applied   => 'Aucune candidature',
    _TabFilter.inProgress => 'Aucune mission en cours',
    _TabFilter.archived  => 'Aucune mission archivée',
  };

  String get _emptySubtitle => switch (widget.filter) {
    _TabFilter.applied   => 'Explorez les missions disponibles et postulez',
    _TabFilter.inProgress => 'Vos missions acceptées apparaîtront ici',
    _TabFilter.archived  => 'Vos missions terminées apparaîtront ici',
  };
}

// ─── Carte mission personnalisée ──────────────────────────────────────────────

class _MyMissionCard extends StatelessWidget {
  final Mission mission;
  final _TabFilter filter;
  final VoidCallback onTap;

  const _MyMissionCard({required this.mission, required this.filter, required this.onTap});

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
              if (mission.images.isNotEmpty)
                MissionImageHeader(images: mission.images, fallbackIcon: mission.categoryIcon, heroTag: 'mission-img-${mission.id}'),
              Padding(
                padding: AppPadding.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header : catégorie + statut ───
                    Row(children: [
                      CategoryChip(icon: mission.categoryIcon, label: mission.categoryName, color: mission.categoryColor, compact: true),
                      const Spacer(),
                      _StatusBadge(filter: filter, mission: mission),
                    ]),
                    const SizedBox(height: 12),
                    Text(mission.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(mission.description, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    // ─── Infos ───
                    Row(children: [
                      InfoChip(icon: Icons.calendar_today_rounded, text: mission.formattedDate, compact: true),
                      const SizedBox(width: 10),
                      InfoChip(icon: Icons.schedule_rounded, text: mission.timeSlot, compact: true),
                    ]),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                    // ─── Footer : budget + client + note ───
                    Row(children: [
                      BudgetText(budget: mission.budget),
                      const Spacer(),
                      if (mission.client != null) ...[
                        UserAvatar(imageUrl: mission.client!.avatarUrl, radius: 13, showVerified: mission.client!.isVerified),
                        const SizedBox(width: 6),
                        Text(mission.client!.name, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                      if (filter == _TabFilter.archived && mission.rating != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text('${mission.rating}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
                          ]),
                        ),
                      ],
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
}

class _StatusBadge extends StatelessWidget {
  final _TabFilter filter;
  final Mission mission;
  const _StatusBadge({required this.filter, required this.mission});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (filter) {
      _TabFilter.applied   => ('Postulée', AppColors.blueTracking, AppColors.lightBlue),
      _TabFilter.inProgress => switch (mission.status) {
        MissionStatus.inProgress => ('En cours', AppColors.primary, AppColors.greenActiveLight),
        MissionStatus.onTheWay   => ('En route', AppColors.iosBlue, AppColors.lightBlue),
        MissionStatus.completed  => ('Terminée', AppColors.greenSystem, AppColors.greenActiveLight),
        _                        => ('Confirmée', AppColors.purple, AppColors.purpleLight),
      },
      _TabFilter.archived  => mission.status == MissionStatus.waitingPayment
        ? ('Validation', AppColors.warning, AppColors.warningLight)
        : mission.status == MissionStatus.closed
          ? ('Clôturée', AppColors.textSecondary, AppColors.surfaceAlt)
          : ('Annulée', AppColors.cancelRed, AppColors.errorLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
