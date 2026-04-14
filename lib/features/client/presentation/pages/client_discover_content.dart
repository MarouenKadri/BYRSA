import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../app/widgets/app_category_filter_bar.dart';
import '../../../../app/app_bar/location_app_bar.dart';
import '../../../story/story.dart';
import '../../../profile/profile_provider.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';
import '../../../mission/presentation/pages/client/client_mission_detail_page.dart';
import '../../../mission/presentation/mission_provider.dart';
import '../../../mission/data/models/mission.dart';
import '../../../mission/data/models/service_category.dart';
import '../../../mission/presentation/widgets/cards/variants/mission_focus_card.dart';
import '../../../auth/data/models/freelancer.dart';
import '../../../auth/presentation/widgets/freelancer_preview_card.dart';
import 'freelancer_profile_view.dart';

List<AppCategoryItem> _categoryItems() => [
  const AppCategoryItem(
    id: null,
    label: ServiceCategory.allFilterLabel,
    icon: Icons.apps_outlined,
    color: Color(0xFF64748B),
  ),
  ...ServiceCategory.ordered.map(
    (category) => AppCategoryItem(
      id: category.id,
      label: category.chipLabel,
      icon: category.icon,
      color: category.color,
    ),
  ),
];

Map<String, dynamic> _normalizeFreelancerRow(Map<String, dynamic> row) {
  final firstName = (row['first_name'] ?? '') as String;
  final lastName = (row['last_name'] ?? '') as String;
  final fullName = '$firstName $lastName'.trim();
  final rawHourlyRate = row['hourly_rate'];
  final hourlyRate = rawHourlyRate is num
      ? rawHourlyRate.toInt()
      : int.tryParse('$rawHourlyRate') ?? 0;
  final categoryIds = ServiceCategory.resolveIds(row['service_categories']);
  final categoryNames = ServiceCategory.resolveNames(row['service_categories']);

  return {
    'id': row['id'] ?? '',
    'name': fullName.isEmpty ? 'Prestataire' : fullName,
    'avatar': (row['avatar_url'] ?? '') as String,
    'category': categoryNames.isNotEmpty ? categoryNames.first : 'Multi-services',
    'categoryIds': categoryIds,
    'services': categoryNames,
    'rating': 0.0,
    'reviewsCount': 0,
    'hourlyRate': hourlyRate,
    'isVerified': (row['is_verified'] ?? false) as bool,
    'isOnline': false,
    'missionsCount': 0,
    'responseTime': '2h',
    'experienceLevel': categoryNames.isNotEmpty ? 'Spécialisé' : 'Pro',
    'zone': (row['address'] ?? '') as String,
  };
}

bool _matchesCategoryFilter(
  Map<String, dynamic> freelancer,
  String? selectedCategoryId,
) {
  if (selectedCategoryId == null) return true;
  final ids = (freelancer['categoryIds'] as List?)?.cast<String>() ?? const [];
  return ids.contains(selectedCategoryId);
}

/// ─────────────────────────────────────────────────────────────
/// 🏠 Inkern - Page d'accueil Client
/// Haut : CTA mission + catégories + accès prestataires + stories
/// Bas  : fil d'actualité
/// ─────────────────────────────────────────────────────────────
class ClientDiscoverContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  const ClientDiscoverContent({super.key, this.onGoToAccount});

  @override
  State<ClientDiscoverContent> createState() => _ClientDiscoverContentState();
}

class _ClientDiscoverContentState extends State<ClientDiscoverContent> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().loadFreelancers(),
      context.read<StoryProvider>().refresh(),
    ]);
  }

  void _openFreelancerProfile(Map<String, dynamic> f) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: f['id'] as String?,
          freelancerName: f['name'] as String,
          freelancerAvatar: f['avatar'] as String,
          hourlyRate: (f['hourlyRate'] as int).toDouble(),
          experienceLevel: f['experienceLevel'] as String,
          rating: f['rating'] as double,
          reviewsCount: f['reviewsCount'] as int,
          missionsCount: f['missionsCount'] as int,
          responseTime: 'Répond en ${f['responseTime']}',
        ),
      ),
    );
  }

  void _goToDiscovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FreelancerDiscoveryPage()),
    );
  }

  void _goToCreateMission() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostMissionFlow()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: LocationAppBar(onGoToAccount: widget.onGoToAccount),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: context.colors.primary,
        child: CustomScrollView(
          slivers: [
            // ── CTA création mission ─────────────────────────────
            SliverToBoxAdapter(
              child: _MissionCtaSection(onTap: _goToCreateMission),
            ),

            // ── Catégories ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategoriesRow(
                selectedCategoryId: _selectedCategoryId,
                onSelect: (categoryId) =>
                    setState(() => _selectedCategoryId = categoryId),
              ),
            ),

            // ── Entrée vers la découverte prestataires ───────────
            SliverToBoxAdapter(
              child: _FreelancerDiscoveryEntryCta(onTap: _goToDiscovery),
            ),

            // ── Stories des freelancers ──────────────────────────
            SliverToBoxAdapter(
              child: Consumer<StoryProvider>(
                builder: (context, storyProvider, _) => _ClientStoriesWidget(
                  storyGroups: storyProvider.storyGroups,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stories des freelancers (client view)
// ─────────────────────────────────────────────────────────────
class _ClientStoriesWidget extends StatefulWidget {
  final List<StoryGroup> storyGroups;
  const _ClientStoriesWidget({required this.storyGroups});
  @override
  State<_ClientStoriesWidget> createState() => _ClientStoriesWidgetState();
}

class _ClientStoriesWidgetState extends State<_ClientStoriesWidget> {
  final Set<String> _viewed = {};

  @override
  Widget build(BuildContext context) {
    final groups = widget.storyGroups
        .where((group) => group.stories.isNotEmpty)
        .take(8)
        .toList();
    if (groups.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 194,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final group = groups[index];
          final story = group.stories.first;
          final isViewed = group.stories.every(
            (item) => _viewed.contains(item.id),
          );
          return GestureDetector(
            onTap: () => _openViewer(context, groups, index),
            child: Container(
              width: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isViewed
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFFDADFE6),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  story.imageUrl.isNotEmpty
                      ? Image.network(
                          story.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _ClientStoryPhotoFallback(
                                label: story.serviceCategory,
                              ),
                        )
                      : _ClientStoryPhotoFallback(label: story.serviceCategory),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.54),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Expertise',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.92),
                              width: 1.2,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: group.avatarUrl.isNotEmpty
                              ? Image.network(
                                  group.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _ClientStoryAvatarFallback(
                                        name: group.groupName,
                                      ),
                                )
                              : _ClientStoryAvatarFallback(
                                  name: group.groupName,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            group.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: index,
          onViewed: (id) => setState(() => _viewed.add(id)),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _ClientStoryPhotoFallback extends StatelessWidget {
  final String label;
  const _ClientStoryPhotoFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    final icon = normalized.contains('jardin')
        ? Icons.yard_outlined
        : normalized.contains('plomb')
        ? Icons.plumbing_outlined
        : normalized.contains('menage')
        ? Icons.bed_outlined
        : Icons.home_repair_service_outlined;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCE6DB), Color(0xFFC8D6D8)],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 30, color: const Color(0xFF6E7781)),
      ),
    );
  }
}

class _ClientStoryAvatarFallback extends StatelessWidget {
  final String name;
  const _ClientStoryAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      color: const Color(0xFFE9EEF2),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4A4F55),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section CTA mission
// ─────────────────────────────────────────────────────────────
class _MissionCtaSection extends StatelessWidget {
  final VoidCallback onTap;

  const _MissionCtaSection({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Créer une mission',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Publiez votre besoin en moins d’une minute',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: context.colors.textTertiary,
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

// ─────────────────────────────────────────────────────────────
// Catégories horizontales
// ─────────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final String? selectedCategoryId;
  final void Function(String?) onSelect;

  const _CategoriesRow({
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      color: context.colors.surface,
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCategoryFilterBar(
        items: _categoryItems(),
        selectedId: selectedCategoryId,
        onSelect: onSelect,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        spacing: 10,
        height: 50,
      ),
    );
  }
}

class _FreelancerDiscoveryEntryCta extends StatelessWidget {
  final VoidCallback onTap;

  const _FreelancerDiscoveryEntryCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.travel_explore_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Voir tous les prestataires',
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section freelancers — scroll horizontal (style home page)
// ─────────────────────────────────────────────────────────────
class _FreelancersSection extends StatelessWidget {
  final Mission? nextMission;
  final bool isLoading;
  final List<Map<String, dynamic>> freelancers;
  final void Function(Map<String, dynamic>) onTap;
  final VoidCallback onSeeAll;

  const _FreelancersSection({
    required this.nextMission,
    required this.isLoading,
    required this.freelancers,
    required this.onTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          AppSectionHeader(
            title: 'Prestataires recommandés',
            trailing: GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir plus',
                    style: context.text.labelLarge?.copyWith(
                      fontSize: AppFontSize.md,
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGap.w4,
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
          AppGap.h12,
          if (nextMission != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MissionFocusCard(
                mission: nextMission!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ClientMissionDetailPage(mission: nextMission!),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pas de mission publiee',
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.base,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          AppGap.h14,

          if (isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (freelancers.isEmpty)
            Padding(
              padding: AppInsets.h20,
              child: Text(
                'Aucun prestataire disponible',
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.base,
                  color: context.colors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppInsets.h16,
                itemCount: freelancers.length,
                itemBuilder: (context, index) {
                  final f = freelancers[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < freelancers.length - 1 ? 12 : 0,
                    ),
                    child: FreelancerPreviewCard(
                      freelancer: Freelancer(
                        name: f['name'] as String,
                        imageUrl: f['avatar'] as String,
                        rating: f['rating'] as double,
                        job: '${f['hourlyRate']}€/h',
                        subtitle: '',
                        isVerified: f['isVerified'] as bool,
                      ),
                      onTap: () => onTap(f),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Page découverte freelancers (standalone via "Voir plus")
// ─────────────────────────────────────────────────────────────
class FreelancerDiscoveryPage extends StatelessWidget {
  const FreelancerDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Prestataires',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: const _FreelancerDiscoveryView(),
    );
  }
}

/// Page d'accueil du client — recherche et filtrage des Freelancers
class _FreelancerDiscoveryView extends StatefulWidget {
  const _FreelancerDiscoveryView();

  @override
  State<_FreelancerDiscoveryView> createState() =>
      _FreelancerDiscoveryViewState();
}

class _FreelancerDiscoveryViewState extends State<_FreelancerDiscoveryView> {
  static const double _priceMin = 0;
  static const double _priceMax = 500;

  final _searchController = TextEditingController();
  String _sortBy = 'recommended';
  RangeValues _priceRange = const RangeValues(_priceMin, _priceMax);
  double _minRating = 0;
  bool _onlineOnly = false;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  List<Map<String, dynamic>> get _filteredFreelancers {
    final rawList = context.watch<ProfileProvider>().freelancers;
    final normalized = rawList.map(_normalizeFreelancerRow).toList();

    return normalized.where((f) {
      // Filtre par recherche (côté client sur le nom)
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final name = (f['name'] as String).toLowerCase();
        final services = (f['services'] as List).join(' ').toLowerCase();
        if (!name.contains(query) && !services.contains(query)) {
          return false;
        }
      }

      // Filtre par prix
      final rate = f['hourlyRate'] as int;
      if (rate < _priceRange.start || rate > _priceRange.end) {
        return false;
      }

      // Filtre par note (toujours 0.0 en l'absence de données DB)
      if ((f['rating'] as double) < _minRating) {
        return false;
      }

      // Filtre en ligne
      if (_onlineOnly && !(f['isOnline'] as bool)) {
        return false;
      }

      // Filtre vérifié
      if (_verifiedOnly && !(f['isVerified'] as bool)) {
        return false;
      }

      return true;
    }).toList()..sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return (a['hourlyRate'] as int).compareTo(b['hourlyRate'] as int);
        case 'price_high':
          return (b['hourlyRate'] as int).compareTo(a['hourlyRate'] as int);
        case 'rating':
          return (b['rating'] as double).compareTo(a['rating'] as double);
        case 'reviews':
          return (b['reviewsCount'] as int).compareTo(a['reviewsCount'] as int);
        default: // recommended
          return (b['missionsCount'] as int).compareTo(
            a['missionsCount'] as int,
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                      context.read<ProfileProvider>().loadFreelancers(
                        search: _searchController.text,
                      );
                    },
                    decoration: AppInputDecorations.formField(
                      context,
                      hintText: 'Rechercher un service, un nom...',
                      hintStyle: context.text.bodyMedium?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.colors.textTertiary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: context.colors.textTertiary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context
                                    .read<ProfileProvider>()
                                    .loadFreelancers();
                              },
                            )
                          : null,
                      contentPadding: AppInsets.h16v14,
                      noBorder: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                AppGap.h4,
              ],
            ),
          ),

          // Filter bar
          Container(
            padding: AppInsets.h16v10,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(bottom: BorderSide(color: context.colors.divider)),
            ),
            child: Row(
              children: [
                // Filter button
                GestureDetector(
                  onTap: () => _showFiltersSheet(),
                  child: Container(
                    padding: AppInsets.h12v8,
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.border),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: context.colors.textSecondary,
                        ),
                        AppGap.w6,
                        Text(
                          'Filtres',
                          style: context.text.bodySmall?.copyWith(
                            fontSize: AppFontSize.md,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        if (_hasActiveFilters()) ...[
                          AppGap.w6,
                          AppCountBadge(
                            label: _countActiveFilters().toString(),
                            padding: AppInsets.a4,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                AppGap.w10,

                // Sort dropdown
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showSortSheet(),
                    child: Container(
                      padding: AppInsets.h12v8,
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.border),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: context.colors.textSecondary,
                          ),
                          AppGap.w6,
                          Expanded(
                            child: Text(
                              _getSortLabel(),
                              style: context.text.bodySmall?.copyWith(
                                fontSize: AppFontSize.md,
                                color: context.colors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: context.colors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AppGap.w10,

                // Results count
                Text(
                  '${_filteredFreelancers.length} résultats',
                  style: context.text.bodySmall?.copyWith(
                    fontSize: AppFontSize.sm,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Freelancers list
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingFreelancers) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = _filteredFreelancers;
                if (items.isEmpty) return _buildEmptyState();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    final crossAxisCount = isWide ? 3 : 2;
                    return GridView.builder(
                      padding: AppInsets.a16,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isWide ? 0.74 : 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final f = items[index];
                        return FreelancerPreviewCard(
                          freelancer: Freelancer(
                            name: f['name'] as String,
                            imageUrl: f['avatar'] as String,
                            rating: f['rating'] as double,
                            job: '${f['hourlyRate']}€/h',
                            subtitle: '',
                            isVerified: f['isVerified'] as bool,
                          ),
                          onTap: () => _openFreelancerProfile(f),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: context.colors.border,
          ),
          AppGap.h16,
          Text(
            'Aucun freelancer trouvé',
            style: context.text.titleMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          AppGap.h8,
          Text(
            'Essayez de modifier vos filtres',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          AppGap.h24,
          AppButton(
            label: 'Réinitialiser les filtres',
            variant: ButtonVariant.ghost,
            icon: Icons.refresh_rounded,
            onPressed: _resetFilters,
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _priceRange.start > _priceMin ||
        _priceRange.end < _priceMax ||
        _minRating > 0 ||
        _onlineOnly ||
        _verifiedOnly;
  }

  int _countActiveFilters() {
    int count = 0;
    if (_priceRange.start > _priceMin || _priceRange.end < _priceMax) count++;
    if (_minRating > 0) count++;
    if (_onlineOnly) count++;
    if (_verifiedOnly) count++;
    return count;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Prix croissant';
      case 'price_high':
        return 'Prix décroissant';
      case 'rating':
        return 'Meilleures notes';
      case 'reviews':
        return 'Plus d\'avis';
      default:
        return 'Recommandés';
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _priceRange = const RangeValues(_priceMin, _priceMax);
      _minRating = 0;
      _onlineOnly = false;
      _verifiedOnly = false;
      _sortBy = 'recommended';
    });
    context.read<ProfileProvider>().loadFreelancers();
  }

  void _showFiltersSheet() {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => _FiltersSheet(
        priceRange: _priceRange,
        minPrice: _priceMin,
        maxPrice: _priceMax,
        minRating: _minRating,
        onlineOnly: _onlineOnly,
        verifiedOnly: _verifiedOnly,
        onApply: (priceRange, minRating, onlineOnly, verifiedOnly) {
          setState(() {
            _priceRange = priceRange;
            _minRating = minRating;
            _onlineOnly = onlineOnly;
            _verifiedOnly = verifiedOnly;
          });
        },
        onReset: _resetFilters,
      ),
    );
  }

  void _showSortSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) => _SortSheet(
        currentSort: _sortBy,
        onSelect: (sort) {
          setState(() => _sortBy = sort);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openFreelancerProfile(Map<String, dynamic> freelancer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: freelancer['id'] as String?,
          freelancerName: freelancer['name'] as String,
          freelancerAvatar: freelancer['avatar'] as String,
          hourlyRate: (freelancer['hourlyRate'] as int).toDouble(),
          experienceLevel: freelancer['experienceLevel'] as String,
          rating: freelancer['rating'] as double,
          reviewsCount: freelancer['reviewsCount'] as int,
          missionsCount: freelancer['missionsCount'] as int,
          responseTime: 'Répond en ${freelancer['responseTime']}',
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🎛️ Sheet Filtres
/// ─────────────────────────────────────────────────────────────
class _FiltersSheet extends StatefulWidget {
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool onlineOnly;
  final bool verifiedOnly;
  final Function(RangeValues, double, bool, bool) onApply;
  final VoidCallback onReset;

  const _FiltersSheet({
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.onlineOnly,
    required this.verifiedOnly,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late RangeValues _priceRange;
  late double _minRating;
  late bool _onlineOnly;
  late bool _verifiedOnly;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.priceRange;
    _minRating = widget.minRating;
    _onlineOnly = widget.onlineOnly;
    _verifiedOnly = widget.verifiedOnly;
  }

  @override
  Widget build(BuildContext context) {
    final priceDivisions = ((widget.maxPrice - widget.minPrice) / 5).round();
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.cardLg),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: const AppBottomSheetHandle(),
          ),

          // Header
          Padding(
            padding: AppInsets.a16,
            child: Row(
              children: [
                Text('Filtres', style: context.text.headlineSmall?.copyWith()),
                const Spacer(),
                AppButton(
                  label: 'Réinitialiser',
                  variant: ButtonVariant.ghost,
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: AppInsets.a20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix
                  Text(
                    'Tarif horaire',
                    style: context.text.titleSmall?.copyWith(),
                  ),
                  AppGap.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_priceRange.start.round()} €',
                        style: context.text.bodyMedium,
                      ),
                      Text(
                        '${_priceRange.end.round()} €',
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: widget.minPrice,
                    max: widget.maxPrice,
                    divisions: priceDivisions > 0 ? priceDivisions : null,
                    activeColor: AppColors.primary,
                    inactiveColor: context.colors.border,
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),

                  AppGap.h24,

                  // Note minimale
                  Text(
                    'Note minimale',
                    style: context.text.titleSmall?.copyWith(),
                  ),
                  AppGap.h12,
                  Row(
                    children: [0.0, 3.0, 3.5, 4.0, 4.5].map((rating) {
                      final isSelected = _minRating == rating;
                      return AppPillChip(
                        label: rating == 0 ? 'Tous' : rating.toString(),
                        selected: isSelected,
                        onTap: () => setState(() => _minRating = rating),
                        icon: rating > 0 ? Icons.star_rounded : null,
                        foregroundColor: rating > 0
                            ? AppColors.amber
                            : context.colors.textSecondary,
                        margin: const EdgeInsets.only(right: 8),
                        padding: AppInsets.h12v8,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      );
                    }).toList(),
                  ),

                  AppGap.h24,

                  // Autres filtres
                  Text(
                    'Autres options',
                    style: context.text.titleSmall?.copyWith(),
                  ),
                  AppGap.h12,

                  _FilterSwitch(
                    icon: Icons.circle,
                    iconColor: Colors.green,
                    label: 'Disponibles maintenant',
                    value: _onlineOnly,
                    onChanged: (v) => setState(() => _onlineOnly = v),
                  ),

                  _FilterSwitch(
                    icon: Icons.verified_rounded,
                    iconColor: AppColors.primary,
                    label: 'Profils vérifiés uniquement',
                    value: _verifiedOnly,
                    onChanged: (v) => setState(() => _verifiedOnly = v),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.divider)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Appliquer les filtres',
                variant: ButtonVariant.primary,
                onPressed: () {
                  widget.onApply(
                    _priceRange,
                    _minRating,
                    _onlineOnly,
                    _verifiedOnly,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitch({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          AppGap.w12,
          Expanded(child: Text(label, style: context.text.bodyMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📊 Sheet Tri
/// ─────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSelect;

  const _SortSheet({required this.currentSort, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'value': 'recommended',
        'label': 'Recommandés',
        'icon': Icons.recommend_rounded,
      },
      {
        'value': 'rating',
        'label': 'Meilleures notes',
        'icon': Icons.star_rounded,
      },
      {
        'value': 'reviews',
        'label': 'Plus d\'avis',
        'icon': Icons.reviews_rounded,
      },
      {
        'value': 'price_low',
        'label': 'Prix croissant',
        'icon': Icons.arrow_upward_rounded,
      },
      {
        'value': 'price_high',
        'label': 'Prix décroissant',
        'icon': Icons.arrow_downward_rounded,
      },
    ];

    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBottomSheetHandle(),
          AppGap.h16,

          // Header
          Padding(
            padding: AppInsets.h20,
            child: Row(
              children: [
                AppIconCircle(
                  icon: Icons.sort_rounded,
                  size: 48,
                  iconSize: 22,
                  backgroundColor: context.colors.surfaceAlt,
                  iconColor: AppColors.primary,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trier par',
                        style: context.text.titleMedium?.copyWith(
                          fontSize: AppFontSize.lg,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      AppGap.h2,
                      Text(
                        'Choisissez un ordre de tri',
                        style: context.text.bodySmall?.copyWith(
                          fontSize: AppFontSize.sm,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppGap.h20,

          // Section label
          Padding(
            padding: AppInsets.h20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OPTIONS',
                style: context.text.labelSmall?.copyWith(
                  fontSize: AppFontSize.xs,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          AppGap.h8,

          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = currentSort == option['value'];
            return Column(
              children: [
                InkWell(
                  onTap: () => onSelect(option['value'] as String),
                  child: Padding(
                    padding: AppInsets.h20v12,
                    child: Row(
                      children: [
                        AppIconCircle(
                          icon: option['icon'] as IconData,
                          size: 42,
                          iconSize: 20,
                          backgroundColor: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : context.colors.surfaceAlt,
                          iconColor: isSelected
                              ? AppColors.primary
                              : context.colors.textSecondary,
                        ),
                        AppGap.w14,
                        Expanded(
                          child: Text(
                            option['label'] as String,
                            style: context.text.titleSmall?.copyWith(
                              fontSize: AppFontSize.body,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
                if (index < options.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.divider,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),

          // Fermer
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16 + bottomPad),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
