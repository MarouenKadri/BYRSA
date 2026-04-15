import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../app/app_bar/location_app_bar.dart';
import '../../../story/story.dart';
import '../../../story/presentation/widgets/stories_section.dart';
import '../../../profile/profile_provider.dart';
import '../../../mission/data/models/mission.dart';
import '../../../mission/presentation/mission_provider.dart';
import '../../../mission/presentation/widgets/shared/mission_status_ui.dart';
import '../../../mission/presentation/widgets/shared/mission_shared_widgets.dart';
import '../../../mission/presentation/widgets/cards/primitives/mission_card_frame.dart';
import '../../../mission/presentation/widgets/cards/primitives/mission_meta_row.dart';
import '../../../mission/presentation/widgets/cards/primitives/mission_status_chip.dart';
import '../../../mission/presentation/pages/client/client_mission_detail_page.dart';
import '../../../mission/presentation/pages/client/tracking_page.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../auth/data/models/freelancer.dart';
import '../../../auth/presentation/widgets/freelancer_preview_card.dart';
import 'freelancer_profile_view.dart';

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


/// ─────────────────────────────────────────────────────────────
/// 🏠 Inkern - Page d'accueil Client
/// Haut : CTA mission + catégories + accès prestataires + stories
/// Bas  : fil d'actualité
/// ─────────────────────────────────────────────────────────────
class ClientDiscoverContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  final VoidCallback? onGoToMissions;
  const ClientDiscoverContent({super.key, this.onGoToAccount, this.onGoToMissions});

  @override
  State<ClientDiscoverContent> createState() => _ClientDiscoverContentState();
}

class _ClientDiscoverContentState extends State<ClientDiscoverContent> {
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

  void _goToDiscovery({String? categoryId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerDiscoveryPage(initialCategoryId: categoryId),
      ),
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
            // ── Catégories ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategoryPillsStrip(
                onCategoryTap: (categoryId) => _goToDiscovery(categoryId: categoryId),
              ),
            ),

            // ── Stories des freelancers ──────────────────────────
            SliverToBoxAdapter(
              child: Consumer<StoryProvider>(
                builder: (context, storyProvider, _) => StoriesSection(
                  storyGroups: storyProvider.storyGroups,
                  isFreelancer: false,
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
            ),

            // ── Missions en cours — remplit l'espace restant ─────
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ActiveMissionsSection(
                onGoToMissions: widget.onGoToMissions,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section missions du jour — masquée si vide, remplit l'espace
// ─────────────────────────────────────────────────────────────
class _ActiveMissionsSection extends StatelessWidget {
  final VoidCallback? onGoToMissions;
  const _ActiveMissionsSection({this.onGoToMissions});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final missions = context
        .watch<MissionProvider>()
        .clientMissions
        .where((m) =>
            MissionStatusUi.belongsToTab(
              status: m.status,
              role: MissionUiRole.client,
              tab: MissionUiTab.inProgress,
            ) &&
            m.date.year == today.year &&
            m.date.month == today.month &&
            m.date.day == today.day)
        .toList();

    if (missions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Aujourd'hui",
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${missions.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...missions.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActiveMissionCard(mission: m),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  final Mission mission;
  const _ActiveMissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final status = mission.status;
    final statusLabel = MissionStatusUi.badgeLabel(
      status: status,
      role: MissionUiRole.client,
    );
    final presta = mission.assignedPresta;
    final startCode = mission.startCode;
    final showCode = startCode != null &&
        (status == MissionStatus.confirmed || status == MissionStatus.onTheWay);
    final showTracking =
        status == MissionStatus.confirmed ||
        status == MissionStatus.onTheWay ||
        status == MissionStatus.inProgress;

    return MissionCardFrame(
      onTap: () => Navigator.push(
        context,
        slideUpRoute(page: ClientMissionDetailPage(mission: mission)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MissionCardFrame.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Catégorie + titre + statut ─────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.categoryName, style: MissionCardFrame.titleStyle),
                      const SizedBox(height: 6),
                      Text(
                        mission.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MissionCardFrame.subtitleStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MissionStatusChip.summary(label: statusLabel),
              ],
            ),

            const SizedBox(height: 16),

            // ── Heure + adresse ────────────────────────────────────
            MissionMetaRow(items: [
              MissionMetaItem(icon: Icons.schedule_outlined, text: mission.timeSlot),
              MissionMetaItem(icon: Icons.location_on_outlined, text: mission.address.shortAddress),
            ]),

            // ── Prestataire ────────────────────────────────────────
            if (presta != null) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFEEF0F2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  UserAvatar(imageUrl: presta.avatarUrl, radius: 20, showVerified: presta.isVerified),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(presta.name, style: MissionCardFrame.captionStyle),
                        Text('Prestataire assigné', style: MissionCardFrame.metaStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // ── Code de démarrage ──────────────────────────────────
            if (showCode) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2433),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 13, color: Colors.white60),
                    const SizedBox(width: 8),
                    const Text(
                      'Code de démarrage',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white60),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${startCode.substring(0, 3)} ${startCode.substring(3)}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 3),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: startCode));
                        if (context.mounted) showAppSnackBar(context, 'Code copié', icon: Icons.copy_rounded);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEEF0F2)),
            const SizedBox(height: 12),

            // ── Actions ────────────────────────────────────────────
            Row(
              children: [
                if (showTracking) ...[
                  Expanded(
                    flex: 2,
                    child: _CardAction(
                      icon: Icons.my_location_rounded,
                      label: 'Voir le suivi',
                      primary: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrackingPage(mission: mission)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (presta != null) ...[
                  Expanded(
                    child: _CardAction(
                      icon: Icons.phone_rounded,
                      label: 'Appeler',
                      onTap: () => showAppSnackBar(
                        context,
                        'Appel vers ${presta.name}...',
                        icon: Icons.phone_rounded,
                        duration: const Duration(seconds: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CardAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Message',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            contactName: presta.name,
                            contactAvatar: presta.avatarUrl,
                            isVerified: presta.isVerified,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = primary
        ? AppColors.primary.withValues(alpha: 0.08)
        : const Color(0xFFF7F7F8);
    final fg = primary ? AppColors.primary : const Color(0xFF4A4F55);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pills catégories — cliquables, ouvrent la découverte filtrée
// ─────────────────────────────────────────────────────────────
class _CategoryPillsStrip extends StatelessWidget {
  final void Function(String categoryId) onCategoryTap;

  const _CategoryPillsStrip({required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final categories = ServiceCategory.all;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategoryTap(cat.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.07),
                  border: Border.all(
                    color: cat.color.withValues(alpha: 0.22),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 13, color: cat.color),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Page découverte freelancers (standalone via "Voir plus")
// ─────────────────────────────────────────────────────────────
class FreelancerDiscoveryPage extends StatelessWidget {
  final String? initialCategoryId;

  const FreelancerDiscoveryPage({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Prestataires',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: _FreelancerDiscoveryView(initialCategoryId: initialCategoryId),
    );
  }
}

/// Page d'accueil du client — recherche et filtrage des Freelancers
class _FreelancerDiscoveryView extends StatefulWidget {
  final String? initialCategoryId;

  const _FreelancerDiscoveryView({this.initialCategoryId});

  @override
  State<_FreelancerDiscoveryView> createState() =>
      _FreelancerDiscoveryViewState();
}

class _FreelancerDiscoveryViewState extends State<_FreelancerDiscoveryView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFreelancers {
    final rawList = context.watch<ProfileProvider>().freelancers;
    final normalized = rawList.map(_normalizeFreelancerRow).toList();

    return normalized.where((f) {
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final name = (f['name'] as String).toLowerCase();
        final services = (f['services'] as List).join(' ').toLowerCase();
        if (!name.contains(query) && !services.contains(query)) return false;
      }
      if (_selectedCategoryId != null) {
        final categoryIds = f['categoryIds'] as List<String>;
        if (!categoryIds.contains(_selectedCategoryId)) return false;
      }
      return true;
    }).toList();
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

                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'Tous',
                        selected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                      ...ServiceCategory.all.map(
                        (cat) => _CategoryChip(
                          label: cat.name,
                          icon: cat.icon,
                          color: cat.color,
                          selected: _selectedCategoryId == cat.id,
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                        ),
                      ),
                    ],
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

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
    });
    context.read<ProfileProvider>().loadFreelancers();
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.45)
                : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? accent : context.colors.textTertiary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accent : context.colors.textSecondary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

