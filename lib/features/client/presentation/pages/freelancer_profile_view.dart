import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../app/auth_provider.dart';
import '../../../../app/enum/user_role.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../mission/data/models/service_category.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/profile_provider.dart';
import '../../../story/story.dart';
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
  bool _openingChat = false;
  UserProfile? _profile;
  bool _loadingProfile = false;

  String get _name => _profile?.fullName ?? widget.freelancerName;
  String get _avatar => _profile?.avatarUrl ?? widget.freelancerAvatar;
  double get _rate => _profile?.hourlyRate ?? widget.hourlyRate;
  String get _bio => _profile?.bio ?? '';
  String get _address => _profile?.address ?? '';

  String get _experienceStat {
    final match = RegExp(r'(20\d{2})').firstMatch(widget.memberSince);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      if (year != null) {
        final years = DateTime.now().year - year;
        return years <= 1 ? '1 an' : '$years ans';
      }
    }
    return '2 ans';
  }

  String get _reliabilityStat => '${widget.cancellationLevel.reliabilityScore}%';

  String get _responseStat {
    final raw = widget.responseTime?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return '15 min';
  }

  String get _experienceLabel => _spacedLabel(widget.experienceLevel);

  @override
  void initState() {
    super.initState();
    if (widget.freelancerId != null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final loaded =
        await context.read<ProfileProvider>().fetchProfileById(widget.freelancerId!);
    if (!mounted) return;
    setState(() {
      _profile = loaded;
      _loadingProfile = false;
    });
  }

  Future<void> _openChat() async {
    final freelancerId = widget.freelancerId;
    if (freelancerId == null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            contactName: _name,
            contactAvatar: _avatar,
          ),
        ),
      );
      return;
    }

    setState(() => _openingChat = true);
    final auth = context.read<AuthProvider>();
    final isClient = auth.currentRole == UserRole.client;
    final conversationId = await context
        .read<MessagingProvider>()
        .getOrCreateConversation(otherUserId: freelancerId, iAmClient: isClient);
    if (!mounted) return;
    setState(() => _openingChat = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          contactName: _name,
          contactAvatar: _avatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              label: 'Chat',
              variant: ButtonVariant.outline,
              icon: Icons.chat_bubble_outline_rounded,
              width: null,
              isLoading: _openingChat,
              onPressed: _openingChat ? null : _openChat,
            ),
          ),
        ],
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
                serviceCategories: _profile?.serviceCategories ?? [],
              ),
            ),
            _AboutSection(
              memberSince: widget.memberSince,
              missionsCount: widget.missionsCount,
              cancellationLevel: widget.cancellationLevel,
              bio: _bio,
              address: _address,
            ),
            AppGap.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingProfile)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_avatar),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 24, 0.08),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(185, 151, 91, 0.18),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: Color(0xFF9B7A32),
                      ),
                    ),
                  ),
                ],
              ),
              AppGap.w20,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.toLowerCase(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                        height: 1.06,
                        color: AppColors.inkDark,
                      ),
                    ),
                    AppGap.h10,
                    Text(
                      '${_rate.toInt()}€/h',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    AppGap.h12,
                    Text(
                      _experienceLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.4,
                        color: AppColors.inkDark,
                      ),
                    ),
                    AppGap.h16,
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreelancerReviewsPage(
                            freelancerName: _name,
                            freelancerAvatar: _avatar,
                            reviewsCount: widget.reviewsCount,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: Color(0xFFC6A76A),
                          ),
                          AppGap.w6,
                          Text(
                            '${widget.rating.toStringAsFixed(1)}/5',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkDark,
                            ),
                          ),
                          Text(
                            '  ${widget.reviewsCount} avis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7A8088),
                            ),
                          ),
                          AppGap.w6,
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Color(0xFFADB3BA),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h24,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.gray50),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 24, 0.04),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _StatCard(value: _experienceStat, label: 'Expérience'),
                _StatDivider(),
                _StatCard(value: _reliabilityStat, label: 'Fiabilité'),
                _StatDivider(),
                _StatCard(value: _responseStat, label: 'Réponse'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(BuildContext context) {
    if (widget.proposedPrice == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tarif proposé',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E757D),
              ),
            ),
            Text(
              widget.proposedPrice!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.inkDark,
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

  const _AboutSection({
    required this.memberSince,
    required this.missionsCount,
    required this.cancellationLevel,
    this.bio = '',
    this.address = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Présentation'),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gray50),
            ),
            child: bio.isNotEmpty
                ? Text(
                    bio,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.7,
                      color: AppColors.inkDark,
                    ),
                  )
                : Text(
                    "Ce prestataire n'a pas encore rédigé sa présentation.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                                            color: const Color(0xFF9AA1A9),
                    ),
                  ),
          ),
          AppGap.h24,
          const _SectionTitle(title: 'Certification'),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: Column(
              children: [
                const _VerificationItem(label: "Pièce d'identité vérifiée"),
                const Divider(height: 24, color: AppColors.gray100),
                const _VerificationItem(label: 'Adresse e-mail vérifiée'),
                const Divider(height: 24, color: AppColors.gray100),
                const _VerificationItem(label: 'Numéro de téléphone vérifié'),
                const Divider(height: 24, color: AppColors.gray100),
                _VerificationItem(label: 'Membre depuis $memberSince'),
                const Divider(height: 24, color: AppColors.gray100),
                _VerificationItem(label: '$missionsCount missions réalisées'),
                const Divider(height: 24, color: AppColors.gray100),
                _VerificationItem(label: cancellationLevel.label),
              ],
            ),
          ),
          AppGap.h24,
          const _SectionTitle(title: 'Localisation'),
          AppGap.h12,
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5B626A),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF1F2F4)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 24, 0.03),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(48.8566, 2.3522),
                        initialZoom: 12,
                        interactionOptions: InteractionOptions(
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
                        const MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(48.8566, 2.3522),
                              width: 40,
                              height: 40,
                              child: _MapMarker(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x2EFFFFFF), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppGap.h10,
          Text(
            "Zone d'intervention : 10 km autour de ${address.isNotEmpty ? address : 'sa position'}",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF949CA4),
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
          final accent = hasStory ? const Color(0xFFC6A76A) : const Color(0xFFE8EAED);

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
                              colors: [Color(0xFFE7D3A2), Color(0xFFC6A76A)],
                            )
                          : null,
                      color: hasStory && isViewed ? const Color(0xFFF0ECE3) : null,
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
                        color: const Color(0xFFFFFBF6),
                        border: Border.all(
                          color: hasStory
                              ? accent.withValues(alpha: 0.38)
                              : const Color(0xFFE8EAED),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: 23,
                          color: hasStory ? AppColors.gray700 : const Color(0xFFB1B7BF),
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
                        color: hasStory ? AppColors.inkDark : const Color(0xFF9EA5AE),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.inkDark,
            ),
          ),
          AppGap.h4,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.gray100,
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
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.8,
        color: const Color(0xFF7A8088),
      ),
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String label;

  const _VerificationItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.inkDark,
        ),
        AppGap.w12,
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF353B43),
            ),
          ),
        ),
      ],
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

String _spacedLabel(String value) {
  return value
      .toUpperCase()
      .split('')
      .where((part) => part.isNotEmpty)
      .join(' ');
}
