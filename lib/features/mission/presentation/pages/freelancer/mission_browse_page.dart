import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../features/story/story.dart';
import '../../../../../features/story/presentation/widgets/stories_section.dart';
import '../../../../../features/client/presentation/pages/freelancer_profile_view.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/cards/variants/mission_browse_card.dart';
import 'freelancer_mission_detail_page.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../core/design/tokens/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔍 Inkern - Page Explorer Missions (Freelancer)
/// Orchestrateur : délègue stories, filtres et tri à leurs widgets dédiés.
/// ═══════════════════════════════════════════════════════════════════════════

class MissionBrowsePage extends StatefulWidget {
  final List<Mission>? missions;
  final bool showAppBar;
  final String? locationLabel;
  final VoidCallback? onLocationTap;

  const MissionBrowsePage({
    super.key,
    this.missions,
    this.showAppBar = false,
    this.locationLabel,
    this.onLocationTap,
  });

  @override
  State<MissionBrowsePage> createState() => _MissionBrowsePageState();
}

class _MissionBrowsePageState extends State<MissionBrowsePage> {
  bool _isLoading = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // ─── Filtrage & tri ────────────────────────────────────────────────────────

  List<Mission> _filtered(List<Mission> all) {
    var list = all
        .where((m) =>
            m.status == MissionStatus.waitingCandidates ||
            m.status == MissionStatus.candidateReceived)
        .toList();

    if (_selectedCategoryId != null) {
      list = list.where((m) => m.categoryId == _selectedCategoryId).toList();
    }

    // Tri : aujourd'hui en premier (urgent), puis futur proche, puis passé
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int _rank(Mission m) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      if (d == today) return 0;          // aujourd'hui
      if (d.isAfter(today)) return 1;    // futur
      return 2;                          // passé
    }

    list.sort((a, b) {
      final rankCmp = _rank(a).compareTo(_rank(b));
      if (rankCmp != 0) return rankCmp;
      // Même groupe : futur → le plus proche en premier ; passé → le plus récent en premier
      return _rank(a) == 1
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date);
    });

    return list;
  }


  Future<void> _refresh() async {
    await context.read<MissionProvider>().refresh();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final allMissions = context.watch<MissionProvider>().publicMissions;
    final filtered = _filtered(allMissions);
    final appliedIds = context
        .watch<MissionProvider>()
        .freelancerMissions
        .map((m) => m.id)
        .toSet();
    final storyGroups = context.watch<StoryProvider>().storyGroups;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool _isToday(Mission m) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      return d == today;
    }

    final todayMissions = filtered.where(_isToday).toList();
    final otherMissions = filtered.where((m) => !_isToday(m)).toList();

    // Construit la liste fusionnée : [header?, ...missions]
    final List<Object> items = [
      if (todayMissions.isNotEmpty) ...[
        'Aujourd\'hui',
        ...todayMissions,
      ],
      if (otherMissions.isNotEmpty) ...[
        if (todayMissions.isNotEmpty) 'À venir',
        ...otherMissions,
      ],
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: widget.showAppBar
          ? const AppSectionBar(pageTitle: 'Missions')
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.inkDark,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: StoriesSection(
                  storyGroups: storyGroups,
                  isFreelancer: true,
                  onProfileTap: (group) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FreelancerProfileView(
                        freelancerId: group.groupId,
                        freelancerName: group.groupName,
                        freelancerAvatar: group.avatarUrl,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildHeader()),
              if (_isLoading)
                SliverToBoxAdapter(
                  child: SizedBox(height: 380, child: SkeletonList()),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Aucune mission trouvée',
                      subtitle:
                          'Revenez plus tard pour découvrir de nouvelles missions',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      // En-tête de section
                      if (item is String) {
                        final isToday = item == 'Aujourd\'hui';
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Row(
                            children: [
                              if (isToday) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.inkDark,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded,
                                          size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Aujourd\'hui',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      // Carte mission
                      final mission = item as Mission;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MissionBrowseCard(
                          mission: mission,
                          isApplied: appliedIds.contains(mission.id),
                          onTap: () => Navigator.push(
                            context,
                            slideUpRoute(
                              page: FreelancerMissionDetailPage(mission: mission),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: AppGap.h24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sous-widgets locaux ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(
            'Explorer',
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _selectedCategoryId != null
                    ? AppColors.inkDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedCategoryId != null
                      ? AppColors.inkDark
                      : context.colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: _selectedCategoryId != null
                    ? Colors.white
                    : context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catégorie',
                    style: context.text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (_selectedCategoryId != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = null);
                        setSheet(() {});
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Réinitialiser',
                        style: context.text.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterPill(
                    label: 'Toutes',
                    selected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      setSheet(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                  ...ServiceCategory.all.map(
                    (cat) => _FilterPill(
                      label: cat.name,
                      icon: cat.icon,
                      color: cat.color,
                      selected: _selectedCategoryId == cat.id,
                      onTap: () {
                        setState(() => _selectedCategoryId = cat.id);
                        setSheet(() {});
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ─── Pill de filtre (bottom sheet) ────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.inkDark : AppColors.gray50,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.blackAlpha09,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? Colors.white : accent,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.inkDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
