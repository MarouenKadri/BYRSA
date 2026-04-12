import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../../features/story/story.dart';
import '../../../../../features/freelancer/presentation/widgets/home/freelancer_stories_section.dart';
import '../../../../../features/freelancer/presentation/widgets/home/freelancer_category_filter.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/cards/variants/mission_browse_card.dart';
import 'freelancer_mission_detail_page.dart';
import '../../../../../app/app_bar/app_section_bar.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((m) =>
              m.title.toLowerCase().contains(query) ||
              m.description.toLowerCase().contains(query) ||
              m.categoryName.toLowerCase().contains(query) ||
              m.address.shortAddress.toLowerCase().contains(query))
          .toList();
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: widget.showAppBar
          ? const AppSectionBar(pageTitle: 'Missions')
          : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FreelancerStoriesSection(storyGroups: storyGroups),
            ),
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: FreelancerCategoryFilter(
                selectedCategoryId: _selectedCategoryId,
                onSelect: (id) => setState(() => _selectedCategoryId = id),
              ),
            ),
            if (!_isLoading)
              SliverToBoxAdapter(child: _buildResultsHeader(filtered)),
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
                    subtitle: _selectedCategoryId != null ||
                            _searchController.text.isNotEmpty
                        ? 'Essayez de modifier vos filtres'
                        : 'Revenez plus tard pour découvrir de nouvelles missions',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final mission = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
    );
  }

  // ─── Sous-widgets locaux ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      color: context.colors.surface,
      child: Row(
        children: [
          if (widget.locationLabel != null)
            GestureDetector(
              onTap: widget.onLocationTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 16, color: context.colors.primary),
                  AppGap.w4,
                  Text(widget.locationLabel!, style: context.text.titleSmall),
                  AppGap.w2,
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: context.colors.textTertiary),
                ],
              ),
            )
          else
            Text('Explorer', style: context.text.headlineLarge),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(List<Mission> missions) {
    final count = missions.length;
    final categoryName = _selectedCategoryId != null
        ? ServiceCategory.findById(_selectedCategoryId!)?.name ?? ''
        : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            '$count mission${count > 1 ? 's' : ''}',
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (categoryName.isNotEmpty)
            Text(
              ' en $categoryName',
              style: context.text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
          const Spacer(),
          if (_selectedCategoryId != null ||
              _searchController.text.isNotEmpty)
            AppButton(
              label: 'Effacer filtres',
              variant: ButtonVariant.ghost,
              onPressed: () => setState(() {
                _selectedCategoryId = null;
                _searchController.clear();
              }),
            ),
        ],
      ),
    );
  }
}
