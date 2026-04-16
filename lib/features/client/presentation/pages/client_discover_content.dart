import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../app/app_bar/location_app_bar.dart';
import '../../../../app/widgets/app_segmented_tab_bar.dart';
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

class _ClientDiscoverContentState extends State<ClientDiscoverContent>
    with SingleTickerProviderStateMixin {
  late final TabController _discoverTabController;

  @override
  void initState() {
    super.initState();
    _discoverTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  @override
  void dispose() {
    _discoverTabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().loadFreelancers(),
      context.read<StoryProvider>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: LocationAppBar(
        onGoToAccount: widget.onGoToAccount,
        bottom: AppSegmentedTabBar(
          controller: _discoverTabController,
          tabs: const [
            AppSegmentedTab(icon: Icons.home_rounded, label: 'Home'),
            AppSegmentedTab(icon: Icons.search_rounded, label: 'Freelancer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _discoverTabController,
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: context.colors.primary,
            child: CustomScrollView(
              slivers: [
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
          const _FreelancerDiscoveryView(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section missions du jour — masquée si vide, remplit l'espace
// ─────────────────────────────────────────────────────────────
// ─── Couleur accent selon statut ─────────────────────────────────────────────

Color _statusAccentColor(MissionStatus status) {
  switch (status) {
    case MissionStatus.prestaChosen:
    case MissionStatus.confirmed:
      return const Color(0xFFF59E0B);
    case MissionStatus.onTheWay:
      return const Color(0xFF3B82F6);
    case MissionStatus.inProgress:
      return const Color(0xFF10B981);
    case MissionStatus.completionRequested:
      return const Color(0xFF8B5CF6);
    case MissionStatus.completed:
    case MissionStatus.paymentHeld:
    case MissionStatus.awaitingRelease:
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF9CA3AF);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section missions du jour
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveMissionsSection extends StatelessWidget {
  final VoidCallback? onGoToMissions;
  const _ActiveMissionsSection({this.onGoToMissions});

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final missions = context
        .watch<MissionProvider>()
        .clientMissions
        .where((m) {
          final mDay = DateTime(m.date.year, m.date.month, m.date.day);
          if (mDay != todayDate) return false;
          // Utilise la règle de promotion : confirmed+aujourd'hui → En cours
          return MissionStatusUi.missionBelongsToTab(
            mission: m,
            role: MissionUiRole.client,
            tab: MissionUiTab.inProgress,
          );
        })
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête impactant ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aujourd'hui",
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _todayLabel(),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (missions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${missions.length} mission${missions.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Contenu ───────────────────────────────────────────
          if (missions.isEmpty)
            _EmptyTodayCard(onGoToMissions: onGoToMissions)
          else
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyTodayCard extends StatelessWidget {
  final VoidCallback? onGoToMissions;
  const _EmptyTodayCard({this.onGoToMissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Pas de mission aujourd'hui",
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Publiez une mission pour trouver un prestataire rapidement.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onGoToMissions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.inkDark,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Créer une mission',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte mission active ─────────────────────────────────────────────────────

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
    final showTracking = status == MissionStatus.confirmed ||
        status == MissionStatus.onTheWay ||
        status == MissionStatus.inProgress;
    final accent = _statusAccentColor(status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        slideUpRoute(page: ClientMissionDetailPage(mission: mission)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Barre accent gauche ──────────────────────────
              Container(width: 5, color: accent),

              // ── 2. Contenu ──────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Catégorie + titre + statut
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mission.categoryName,
                                    style: MissionCardFrame.titleStyle),
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

                      // Heure + adresse
                      MissionMetaRow(items: [
                        MissionMetaItem(
                            icon: Icons.schedule_outlined,
                            text: mission.timeSlot),
                        MissionMetaItem(
                            icon: Icons.location_on_outlined,
                            text: mission.address.shortAddress),
                      ]),

                      // ── 3. Prestataire — avatar 48px ────────────
                      if (presta != null) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF0F2F5)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            UserAvatar(
                              imageUrl: presta.avatarUrl,
                              radius: 24,
                              showVerified: presta.isVerified,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(presta.name,
                                      style: MissionCardFrame.captionStyle),
                                  const SizedBox(height: 2),
                                  Text('Prestataire assigné',
                                      style: MissionCardFrame.metaStyle),
                                ],
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── 5. Code de démarrage — gradient proéminent
                      if (showCode) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lock_open_rounded,
                                    size: 13, color: Colors.white70),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Code de démarrage',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white54),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${startCode.substring(0, 3)} ${startCode.substring(3)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: startCode));
                                  if (context.mounted) {
                                    showAppSnackBar(context, 'Code copié',
                                        icon: Icons.copy_rounded);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.copy_rounded,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF0F2F5)),
                      const SizedBox(height: 12),

                      // ── 4. Boutons pill-shaped ──────────────────
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
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TrackingPage(mission: mission)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bouton action pill ───────────────────────────────────────────────────────

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
        : const Color(0xFFF5F6F7);
    final fg = primary ? AppColors.primary : const Color(0xFF4A4F55);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
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

  const _FreelancerDiscoveryView({super.key, this.initialCategoryId});

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
    return Column(
      children: [
        // Search & Filters Header — iOS pill style
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Pill search field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFEEEFF1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 16,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                      context.read<ProfileProvider>().loadFreelancers(
                        search: _searchController.text,
                      );
                    },
                    style: context.text.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service, un nom...',
                      hintStyle: context.text.bodyMedium?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: context.colors.textTertiary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context.read<ProfileProvider>().loadFreelancers();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter button — rounded square
              GestureDetector(
                onTap: _showFilterSheet,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedCategoryId != null
                        ? AppColors.inkDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedCategoryId != null
                          ? AppColors.inkDark
                          : const Color(0xFFEEEFF1),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 16,
                        offset: Offset(0, 3),
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
                      childAspectRatio: isWide ? 0.65 : 0.62,
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
                          subtitle: f['category'] as String,
                          isVerified: f['isVerified'] as bool,
                        ),
                        missionsCount: f['missionsCount'] as int,
                        reviewsCount: f['reviewsCount'] as int,
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
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E2E6),
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
                  _CategoryChip(
                    label: 'Tous',
                    selected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      setSheet(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                  ...ServiceCategory.all.map(
                    (cat) => _CategoryChip(
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

