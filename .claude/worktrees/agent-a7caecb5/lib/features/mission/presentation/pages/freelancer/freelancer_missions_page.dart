import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/service_category.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import '../../widgets/freelancer/freelancer_widgets.dart';
import 'freelancer_mission_detail_page.dart';
import '../../../../../app/widgets/cigale_app_bar.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔍 Inkern - Page Explorer Missions (Freelancer)
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerMissionsPage extends StatefulWidget {
  final List<Mission>? missions;
  final bool showAppBar;
  const FreelancerMissionsPage({super.key, this.missions, this.showAppBar = false});

  @override
  State<FreelancerMissionsPage> createState() => _FreelancerMissionsPageState();
}

class _FreelancerMissionsPageState extends State<FreelancerMissionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _sortBy = 'recent';
  bool _showFilters = false;
  bool _isLoading = true;

  List<Mission> _getFilteredMissions(List<Mission> allMissions) {
    var missions = allMissions.where((m) => m.status == MissionStatus.waitingCandidates || m.status == MissionStatus.candidateReceived).toList();
    if (_selectedCategoryId != null) missions = missions.where((m) => m.categoryId == _selectedCategoryId).toList();
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      missions = missions.where((m) =>
        m.title.toLowerCase().contains(query) ||
        m.description.toLowerCase().contains(query) ||
        m.categoryName.toLowerCase().contains(query) ||
        m.address.shortAddress.toLowerCase().contains(query)
      ).toList();
    }
    switch (_sortBy) {
      case 'distance': missions.sort((a, b) => _parseDistance(a.address.distance).compareTo(_parseDistance(b.address.distance))); break;
      case 'budget': missions.sort((a, b) => b.budget.averageAmount.compareTo(a.budget.averageAmount)); break;
      default: missions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return missions;
  }

  double _parseDistance(String? distance) {
    if (distance == null) return double.infinity;
    final match = RegExp(r'[\d.]+').firstMatch(distance);
    return match != null ? double.tryParse(match.group(0)!) ?? 0 : 0;
  }

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

  @override
  Widget build(BuildContext context) {
    final allMissions = context.watch<MissionProvider>().publicMissions;
    final filtered = _getFilteredMissions(allMissions);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? const CigaleAppBar(pageTitle: 'Missions')
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilters(),
            if (_showFilters) _buildSortOptions(),
            if (!_isLoading) _buildResultsHeader(filtered),
            Expanded(child: _isLoading ? const SkeletonList() : _buildMissionsList(filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.white,
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explorer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Trouvez des missions près de chez vous', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
              color: _showFilters ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Rechercher une mission...',
          hintStyle: TextStyle(color: AppColors.textHint),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: Icon(Icons.clear_rounded, color: AppColors.textHint), onPressed: () { _searchController.clear(); setState(() {}); })
              : null,
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            _buildCategoryChip(id: null, label: 'Toutes', icon: Icons.apps_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            ...ServiceCategory.all.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(id: cat.id, label: cat.name, icon: cat.icon, color: cat.color),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({required String? id, required String label, required IconData icon, required Color color}) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: isSelected ? color : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? color : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(children: [
        const Text('Trier par :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        _buildSortChip('recent', 'Plus récentes', Icons.schedule_rounded),
        const SizedBox(width: 8),
        _buildSortChip('distance', 'Distance', Icons.near_me_rounded),
        const SizedBox(width: 8),
        _buildSortChip('budget', 'Budget', Icons.euro_rounded),
      ]),
    );
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildResultsHeader(List<Mission> missions) {
    final count = missions.length;
    final categoryName = _selectedCategoryId != null ? ServiceCategory.findById(_selectedCategoryId!)?.name ?? '' : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text('$count mission${count > 1 ? 's' : ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (categoryName.isNotEmpty) Text(' en $categoryName', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const Spacer(),
          if (_selectedCategoryId != null || _searchController.text.isNotEmpty)
            TextButton(
              onPressed: () => setState(() { _selectedCategoryId = null; _searchController.clear(); }),
              child: const Text('Effacer filtres', style: TextStyle(fontSize: 13, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(List<Mission> missions) {
    if (missions.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Aucune mission trouvée',
        subtitle: _selectedCategoryId != null || _searchController.text.isNotEmpty
            ? 'Essayez de modifier vos filtres'
            : 'Revenez plus tard pour découvrir de nouvelles missions',
      );
    }
    final appliedIds = context.watch<MissionProvider>().freelancerMissions.map((m) => m.id).toSet();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FreelancerMissionCard(
            mission: mission,
            isApplied: appliedIds.contains(mission.id),
            onTap: () => _openMissionDetail(mission),
          ),
        );
      },
    );
  }

  void _openMissionDetail(Mission mission) {
    Navigator.push(context, slideUpRoute(page: FreelancerMissionDetailPage(mission: mission)));
  }
}

// ─── Freelancer Mission Card ──────────────────────────────────────────────────

class FreelancerMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final bool isApplied;

  const FreelancerMissionCard({super.key, required this.mission, required this.onTap, this.isApplied = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isApplied ? 0.55 : 1.0,
      child: Container(
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
                      Row(children: [
                        CategoryChip(icon: mission.categoryIcon, label: mission.categoryName, color: mission.categoryColor, compact: true),
                        const Spacer(),
                        if (isApplied)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.check_rounded, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('Déjà postulé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ]),
                          )
                        else if (mission.address.distance != null)
                          DistanceBadge(distance: mission.address.distance!, compact: true),
                      ]),
                      const SizedBox(height: 12),
                      Text(mission.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(mission.description, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(children: [
                        InfoChip(icon: Icons.calendar_today_rounded, text: mission.formattedDate, compact: true),
                        const SizedBox(width: 12),
                        InfoChip(icon: Icons.schedule_rounded, text: mission.timeSlot, compact: true),
                        const SizedBox(width: 12),
                        Flexible(child: InfoChip(icon: Icons.location_on_outlined, text: mission.address.shortAddress, compact: true)),
                      ]),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          BudgetText(budget: mission.budget),
                          const SizedBox(width: 16),
                          if (mission.client != null) ...[
                            UserAvatar(imageUrl: mission.client!.avatarUrl, radius: 14, showVerified: mission.client!.isVerified),
                            const SizedBox(width: 8),
                            Flexible(child: Text(mission.client!.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                          ],
                          const Spacer(),
                          Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${mission.candidatesCount}', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
