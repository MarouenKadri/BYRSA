import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../mission/data/models/mission.dart';
import '../../../mission/data/models/service_category.dart';
import '../../../mission/presentation/mission_provider.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';
import '../../../mission/presentation/widgets/detail/mission_detail_primitives.dart';
import '../../../story/story.dart';
import '../providers/freelancer_public_profile_provider.dart';
import 'freelancer_reviews_page.dart';

enum CancellationLevel { never, rarely, sometimes, often }

extension CancellationLevelExtension on CancellationLevel {
  String get label {
    switch (this) {
      case CancellationLevel.never:
        return "N'annule jamais";
      case CancellationLevel.rarely:
        return 'Annule rarement';
      case CancellationLevel.sometimes:
        return 'Annule parfois';
      case CancellationLevel.often:
        return 'Annule souvent';
    }
  }

  int get reliabilityScore {
    switch (this) {
      case CancellationLevel.never:
        return 100;
      case CancellationLevel.rarely:
        return 96;
      case CancellationLevel.sometimes:
        return 88;
      case CancellationLevel.often:
        return 74;
    }
  }
}

class FreelancerProfileView extends StatefulWidget {
  final String freelancerName;
  final String freelancerAvatar;
  final double hourlyRate;
  final String experienceLevel;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final String memberSince;
  final CancellationLevel cancellationLevel;
  final String? proposedPrice;
  final String? responseTime;
  final String? freelancerId;

  const FreelancerProfileView({
    super.key,
    this.freelancerName = 'Thomas',
    this.freelancerAvatar = 'https://i.pravatar.cc/150?img=3',
    this.hourlyRate = 25,
    this.experienceLevel = 'Ambassadeur',
    this.rating = 5.0,
    this.reviewsCount = 40,
    this.missionsCount = 142,
    this.memberSince = 'Janvier 2022',
    this.cancellationLevel = CancellationLevel.rarely,
    this.proposedPrice,
    this.responseTime,
    this.freelancerId,
  });

  @override
  State<FreelancerProfileView> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfileView> {
  late final FreelancerPublicProfileProvider _profileProvider;

  String get _name => _profileProvider.profile?.fullName ?? widget.freelancerName;
  String get _avatar =>
      _profileProvider.profile?.avatarUrl ?? widget.freelancerAvatar;
  double get _rate => _profileProvider.profile?.hourlyRate ?? widget.hourlyRate;
  String get _bio => _profileProvider.profile?.bio ?? '';
  String get _address => _profileProvider.profile?.address ?? '';
  double get _rating => _profileProvider.profile?.rating ?? widget.rating;
  int get _reviewsCount =>
      _profileProvider.profile?.reviewsCount ?? widget.reviewsCount;
  int get _missionsCount =>
      _profileProvider.profile?.missionsCount ?? widget.missionsCount;
  List<String> get _serviceCategories =>
      _profileProvider.profile?.serviceCategories ?? const [];
  double? get _latitude => _profileProvider.profile?.latitude;
  double? get _longitude => _profileProvider.profile?.longitude;
  double get _zoneRadius => _profileProvider.profile?.zoneRadius ?? 10;
  bool get _loadingProfile => _profileProvider.isLoading;

  String get _memberSince =>
      _formatMemberSince(_profileProvider.profile?.createdAt) ?? widget.memberSince;

  String get _experienceStat {
    final createdAt = _profileProvider.profile?.createdAt;
    if (createdAt != null) {
      final years = DateTime.now().difference(createdAt).inDays ~/ 365;
      return years <= 1 ? '1 an' : '$years ans';
    }

    final match = RegExp(r'(20\d{2})').firstMatch(widget.memberSince);
    if (match == null) return '2 ans';
    final year = int.tryParse(match.group(1)!);
    if (year == null) return '2 ans';
    final years = DateTime.now().year - year;
    return years <= 1 ? '1 an' : '$years ans';
  }

  CancellationLevel get _cancellationLevel {
    final rate = _profileProvider.profile?.cancellationRate;
    if (rate == null) return widget.cancellationLevel;
    if (rate <= 0) return CancellationLevel.never;
    if (rate <= 0.05) return CancellationLevel.rarely;
    if (rate <= 0.12) return CancellationLevel.sometimes;
    return CancellationLevel.often;
  }

  String get _missionsStat => '$_missionsCount';

  String get _responseStat {
    final dbRaw = _profileProvider.profile?.responseTime?.trim();
    if (dbRaw != null && dbRaw.isNotEmpty) return dbRaw;

    final raw = widget.responseTime?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return '15 min';
  }

  @override
  void initState() {
    super.initState();
    _profileProvider = FreelancerPublicProfileProvider();
    _profileProvider.load(widget.freelancerId);
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  String? _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return null;
    const months = <String>[
      'Janvier',
      'Fevrier',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Aout',
      'Septembre',
      'Octobre',
      'Novembre',
      'Decembre',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  void _openInvite(BuildContext context) {
    final missions = context
        .read<MissionProvider>()
        .clientMissions
        .where((m) =>
            m.status == MissionStatus.waitingCandidates ||
            m.status == MissionStatus.draft)
        .toList();

    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (_) => _InviteMissionSheet(
        freelancerName: _name,
        missions: missions,
        onCreateMission: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostMissionFlow()),
          );
        },
      ),
    );
  }

  void _openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerReviewsPage(
          freelancerName: _name,
          freelancerAvatar: _avatar,
          reviewsCount: _reviewsCount,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FreelancerPublicProfileProvider>.value(
      value: _profileProvider,
      child: Consumer<FreelancerPublicProfileProvider>(
        builder: (context, _, __) => Scaffold(
          backgroundColor: context.colors.background,
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: context.colors.background,
                border: Border(
                  top: BorderSide(color: context.colors.divider),
                ),
              ),
              child: AppButton(
                label: 'Inviter à une mission',
                variant: ButtonVariant.black,
                icon: Icons.add_task_rounded,
                onPressed: () => _openInvite(context),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                _buildProposalCard(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
                  child: _ServicesStoriesSection(
                    freelancerId: widget.freelancerId,
                    serviceCategories: _serviceCategories,
                  ),
                ),
                _AboutSection(
                  memberSince: _memberSince,
                  missionsCount: _missionsCount,
                  cancellationLevel: _cancellationLevel,
                  bio: _bio,
                  address: _address,
                  latitude: _latitude,
                  longitude: _longitude,
                  zoneRadius: _zoneRadius,
                ),
                AppGap.h32,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loadingProfile)
          const LinearProgressIndicator(minHeight: 2),
        SizedBox(
          height: 290,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  _avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF23272D), Color(0xFF3A4048)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xC7000000),
                          Color(0x52000000),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.28, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPad + 4,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    DetailCircleBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                    AppGap.h10,
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFE6E9ED),
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              '${_rate.toInt()}€/h',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          AppGap.w8,
                          _LevelPill(level: widget.experienceLevel),
                        ],
                      ),
                    ),
                    AppGap.h12,
                    GestureDetector(
                      onTap: () => _openReviews(context),
                      child: Row(
                        children: [
                          Text(
                            '${_rating.toStringAsFixed(1)} · $_reviewsCount avis',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: DetailMetaChip(
                  icon: Icons.workspace_premium_rounded,
                  label: '$_experienceStat d\'experience',
                ),
              ),
              const DetailInlineDivider(),
              Expanded(
                child: DetailMetaChip(
                  icon: Icons.assignment_turned_in_outlined,
                  label: '$_missionsStat missions',
                ),
              ),
              const DetailInlineDivider(),
              Expanded(
                child: DetailMetaChip(
                  icon: Icons.schedule_outlined,
                  label: 'Repond en $_responseStat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProposalCard(BuildContext context) {
    if (widget.proposedPrice == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tarif proposé',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9AA3AE),
              ),
            ),
            Text(
              widget.proposedPrice!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String memberSince;
  final int missionsCount;
  final CancellationLevel cancellationLevel;
  final String bio;
  final String address;
  final double? latitude;
  final double? longitude;
  final double zoneRadius;

  const _AboutSection({
    required this.memberSince,
    required this.missionsCount,
    required this.cancellationLevel,
    this.bio = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.zoneRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final center = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : const LatLng(48.8566, 2.3522);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Présentation'),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: bio.isNotEmpty
                ? Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: Color(0xFF5F6975),
                    ),
                  )
                : Text(
                    "Ce prestataire n'a pas encore rédigé sa présentation.",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: Color(0xFF9AA3AE),
                    ),
                  ),
          ),
          AppGap.h24,
          const _SectionTitle(title: 'Informations vérifiées'),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const _VerificationItem(
                  label: "Pièce d'identité vérifiée",
                  verified: true,
                ),
                const Divider(height: 1, color: AppColors.gray50, indent: 31),
                const _VerificationItem(
                  label: 'Adresse e-mail vérifiée',
                  verified: true,
                ),
                const Divider(height: 1, color: AppColors.gray50, indent: 31),
                const _VerificationItem(
                  label: 'Numéro de téléphone vérifié',
                  verified: true,
                ),
                const Divider(height: 1, color: AppColors.gray50, indent: 31),
                _VerificationItem(
                  label: cancellationLevel.label,
                  verified: cancellationLevel == CancellationLevel.never ||
                      cancellationLevel == CancellationLevel.rarely,
                  warning: cancellationLevel == CancellationLevel.sometimes,
                ),
              ],
            ),
          ),
          AppGap.h24,
          const _SectionTitle(title: 'Localisation'),
          AppGap.h12,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 182,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8EBEF)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 12,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.example.homservice',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: center,
                              width: 40,
                              height: 40,
                              child: const _MapMarker(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (address.isNotEmpty) ...[
                    AppGap.h14,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF9AA3AE),
                          ),
                        ),
                        AppGap.w8,
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppGap.h10,
          Text(
            "Zone d'intervention : ${zoneRadius.toInt()} km autour de ${address.isNotEmpty ? address : 'sa position'}",
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF5F6975),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesStoriesSection extends StatefulWidget {
  final String? freelancerId;
  final List<String> serviceCategories;

  const _ServicesStoriesSection({
    this.freelancerId,
    this.serviceCategories = const [],
  });

  @override
  State<_ServicesStoriesSection> createState() => _ServicesStoriesSectionState();
}

class _ServicesStoriesSectionState extends State<_ServicesStoriesSection> {
  final Set<String> _viewed = {};

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final groups = widget.freelancerId != null
        ? storyProvider.storyGroupsForFreelancer(widget.freelancerId!)
        : <StoryGroup>[];

    final activeIds = {for (final g in groups) g.categoryId};

    final allIds = <String>{
      ...widget.serviceCategories,
      ...activeIds,
    }.toList();

    if (allIds.isEmpty) return const SizedBox.shrink();

    allIds.sort((a, b) {
      final aActive = activeIds.contains(a) ? 0 : 1;
      final bActive = activeIds.contains(b) ? 0 : 1;
      return aActive.compareTo(bActive);
    });

    final activeGroups = groups.where((g) => g.categoryId.isNotEmpty).toList();

    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: allIds.length,
        itemBuilder: (context, i) {
          final catId = allIds[i];
          final cat = ServiceCategory.findById(catId);
          if (cat == null) return const SizedBox.shrink();
          final hasStory = activeIds.contains(catId);
          final isViewed = _viewed.contains(catId);
          final accent = hasStory ? AppColors.ink : const Color(0xFFE8EAED);

          return GestureDetector(
            onTap: hasStory
                ? () {
                    final idx = activeGroups.indexWhere((g) => g.categoryId == catId);
                    if (idx >= 0) {
                      setState(() => _viewed.add(catId));
                      _openViewer(context, activeGroups, idx);
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasStory && !isViewed
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF596372), Color(0xFF2C343F)],
                            )
                          : null,
                      color: hasStory && isViewed ? const Color(0xFFEAEEF3) : null,
                      boxShadow: hasStory
                          ? const [
                              BoxShadow(
                                color: Color.fromRGBO(16, 20, 24, 0.06),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: hasStory
                              ? accent.withValues(alpha: 0.26)
                              : const Color(0xFFE8EAED),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: 23,
                          color: hasStory ? AppColors.ink : const Color(0xFFB1B7BF),
                        ),
                      ),
                    ),
                  ),
                  AppGap.h8,
                  SizedBox(
                    width: 72,
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: hasStory ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.2,
                        color: hasStory ? AppColors.ink : const Color(0xFF9EA5AE),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String label;
  final bool verified;
  final bool warning;

  const _VerificationItem({
    required this.label,
    this.verified = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData iconData;

    if (warning) {
      iconColor = const Color(0xFFF59E0B);
      iconData = Icons.warning_amber_rounded;
    } else if (verified) {
      iconColor = const Color(0xFF22C55E);
      iconData = Icons.check_circle_rounded;
    } else {
      iconColor = const Color(0xFFEF4444);
      iconData = Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(iconData, size: 17, color: iconColor),
          AppGap.w14,
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.inkDark,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 20, 24, 0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.place_outlined, color: Colors.white, size: 16),
        ),
        CustomPaint(size: const Size(10, 6), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.inkDark;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// Pill niveau — typographie normale
// ─────────────────────────────────────────────────────────────
class _LevelPill extends StatelessWidget {
  final String level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    final lower = level.toLowerCase();
    final IconData icon;

    if (lower == 'ambassadeur') {
      icon = Icons.workspace_premium_rounded;
    } else if (lower == 'expert') {
      icon = Icons.military_tech_rounded;
    } else if (lower == 'pro') {
      icon = Icons.verified_rounded;
    } else {
      icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE6E9ED),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF66707C)),
          const SizedBox(width: 5),
          Text(
            level,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sheet — Inviter à une mission
// ─────────────────────────────────────────────────────────────
class _InviteMissionSheet extends StatelessWidget {
  final String freelancerName;
  final List<Mission> missions;
  final VoidCallback onCreateMission;

  const _InviteMissionSheet({
    required this.freelancerName,
    required this.missions,
    required this.onCreateMission,
  });

  @override
  Widget build(BuildContext context) {
    return AppPickerSheet(
      title: 'Inviter à une mission',
      footer: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
        child: AppButton(
          label: 'Créer une nouvelle mission',
          variant: ButtonVariant.outline,
          icon: Icons.add_rounded,
          onPressed: onCreateMission,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: missions.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppGap.h16,
                  Icon(Icons.inbox_outlined,
                      size: 48, color: context.colors.border),
                  AppGap.h12,
                  Text(
                    'Aucune mission ouverte',
                    style: context.text.titleSmall
                        ?.copyWith(color: context.colors.textSecondary),
                  ),
                  AppGap.h6,
                  Text(
                    'Créez une mission pour inviter $freelancerName',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.colors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  AppGap.h24,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: missions
                    .map(
                      (m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.home_repair_service_outlined,
                            size: 18,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        title: Text(
                          m.title,
                          style: context.text.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          m.status.label,
                          style: context.text.labelSmall
                              ?.copyWith(color: context.colors.textTertiary),
                        ),
                        trailing: AppButton(
                          label: 'Inviter',
                          variant: ButtonVariant.primary,
                          width: null,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

