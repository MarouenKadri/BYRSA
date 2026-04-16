import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/mission_status_ui.dart';
import '../../widgets/cards/variants/mission_summary_card.dart';
import 'freelancer_mission_detail_page.dart';

class FreelancerEngagementsContent extends StatelessWidget {
  final VoidCallback? onGoToAccount;

  const FreelancerEngagementsContent({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppSectionBar(
          pageTitle: 'Mes missions',
          onGoToAccount: onGoToAccount,
        ),
        body: const Column(
          children: [
            AppSegmentedTabBar(
              tabs: [
                AppSegmentedTab(icon: Icons.send_rounded, label: 'Postulées'),
                AppSegmentedTab(icon: Icons.check_circle_outline_rounded, label: 'Confirmées'),
                AppSegmentedTab(icon: Icons.play_circle_outline_rounded, label: 'En cours'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MissionTab(filter: _TabFilter.applied),
                  _MissionTab(filter: _TabFilter.confirmed),
                  _MissionTab(filter: _TabFilter.inProgress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TabFilter { applied, confirmed, inProgress }

extension _TabFilterX on _TabFilter {
  MissionUiTab get uiTab => switch (this) {
    _TabFilter.applied    => MissionUiTab.applied,
    _TabFilter.confirmed  => MissionUiTab.confirmed,
    _TabFilter.inProgress => MissionUiTab.inProgress,
  };
}

class _MissionTab extends StatefulWidget {
  final _TabFilter filter;

  const _MissionTab({required this.filter});

  @override
  State<_MissionTab> createState() => _MissionTabState();
}

class _MissionTabState extends State<_MissionTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  List<Mission> _filter(List<Mission> all) {
    return all
        .where(
          (m) => MissionStatusUi.missionBelongsToTab(
            mission: m,
            role: MissionUiRole.freelancer,
            tab: widget.filter.uiTab,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SkeletonList(key: ValueKey('skeleton'));
    }

    final missions = _filter(
      context.watch<MissionProvider>().freelancerMissions,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: missions.isEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              icon: _emptyIcon,
              title: _emptyTitle,
              subtitle: _emptySubtitle,
            )
          : ListView.separated(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return MissionSummaryCard(
                  mission: mission,
                  role: MissionUiRole.freelancer,
                  showDescription: false,
                  onTap: () => Navigator.push(
                    context,
                    slideUpRoute(
                      page: FreelancerMissionDetailPage(
                        mission: mission,
                        isOwn: true,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData get _emptyIcon => switch (widget.filter) {
    _TabFilter.applied    => Icons.send_outlined,
    _TabFilter.confirmed  => Icons.check_circle_outline_rounded,
    _TabFilter.inProgress => Icons.work_outline_rounded,
  };

  String get _emptyTitle => switch (widget.filter) {
    _TabFilter.applied    => 'Aucune candidature',
    _TabFilter.confirmed  => 'Aucune mission confirmée',
    _TabFilter.inProgress => 'Aucune mission en cours',
  };

  String get _emptySubtitle => switch (widget.filter) {
    _TabFilter.applied    => 'Explorez les missions disponibles et postulez',
    _TabFilter.confirmed  => 'Les missions où vous avez été sélectionné apparaîtront ici',
    _TabFilter.inProgress => 'Vos missions démarrées apparaîtront ici',
  };
}
