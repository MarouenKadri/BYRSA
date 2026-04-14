import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../mission/presentation/widgets/detail/mission_detail_primitives.dart';
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

enum FreelancerContactMode { spontaneous, pendingCandidate, confirmedPresta }

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

  /// Contexte du bouton "Contacter" :
  /// - `spontaneous` (défaut) → chat + bouton "Réserver"
  /// - `pendingCandidate`     → chat + bouton "Accepter"
  /// - `confirmedPresta`      → chat simple, aucun bouton spécial
  final FreelancerContactMode contactMode;
  final VoidCallback? onCandidateAccepted;
  final String? candidatePrice;

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
    this.contactMode = FreelancerContactMode.spontaneous,
    this.onCandidateAccepted,
    this.candidatePrice,
  });

  @override
  State<FreelancerProfileView> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfileView> {
  late final FreelancerPublicProfileProvider _profileProvider;
  bool _isOpeningChat = false;

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

  Future<void> _openChat(BuildContext context) async {
    if (_isOpeningChat) return;
    setState(() => _isOpeningChat = true);

    String? conversationId;
    if (widget.freelancerId != null) {
      try {
        conversationId = await context.read<MessagingProvider>()
            .getOrCreateConversation(
              otherUserId: widget.freelancerId!,
              iAmClient: true,
            );
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isOpeningChat = false);

    final isPending = widget.contactMode == FreelancerContactMode.pendingCandidate;
    final isSpontaneous = widget.contactMode == FreelancerContactMode.spontaneous;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          contactName: _name,
          contactAvatar: _avatar,
          isVerified: true,
          candidateMode: isPending,
          candidatePrice: isPending ? widget.candidatePrice : null,
          onAcceptCandidate: isPending ? widget.onCandidateAccepted : null,
          showReserveButton: isSpontaneous,
        ),
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
                border: Border(top: BorderSide(color: context.colors.divider)),
              ),
              child: AppButton(
                label: _isOpeningChat
                    ? 'Connexion...'
                    : widget.contactMode == FreelancerContactMode.pendingCandidate
                        ? 'Contacter & Accepter'
                        : 'Contacter',
                variant: ButtonVariant.black,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: _isOpeningChat ? null : () => _openChat(context),
              ),
            ),
          ),
          body: Column(
            children: [
              _buildProfileHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReviewsPill(context),
                      _buildProposalCard(context),
                      _buildProfileMetaSection(context),
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
            ],
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
                    const Spacer(),
                    _HeroRateBadge(rate: _rate),
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
                      child: _LevelPill(level: widget.experienceLevel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMetaSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          _ProfileStatsCard(
            experience: _experienceStat,
            missions: _missionsStat,
            response: _responseStat,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsPill(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppPillChip(
          label: '${_rating.toStringAsFixed(1)} · $_reviewsCount avis',
          icon: Icons.star_rounded,
          onTap: () => _openReviews(context),
          foregroundColor: AppColors.inkDark,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
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
          borderRadius: BorderRadius.circular(AppRadius.xl),
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
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textHint,
              ),
            ),
            Text(
              widget.proposedPrice!,
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
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
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
                    style: context.text.bodyMedium?.copyWith(
                      height: 1.65,
                      color: context.colors.textSecondary,
                    ),
                  )
                : Text(
                    "Ce prestataire n'a pas encore rédigé sa présentation.",
                    style: context.text.bodyMedium?.copyWith(
                      height: 1.6,
                      color: context.colors.textHint,
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
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
                      borderRadius: BorderRadius.circular(AppRadius.cardLg),
                      border: Border.all(color: AppColors.gray50),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: context.colors.textHint,
                          ),
                        ),
                        AppGap.w8,
                        Expanded(
                          child: Text(
                            address,
                            style: context.text.titleSmall?.copyWith(
                              height: 1.35,
                              fontWeight: FontWeight.w700,
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
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
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
      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  final String experience;
  final String missions;
  final String response;

  const _ProfileStatsCard({
    required this.experience,
    required this.missions,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.gray50),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileStatCell(
              icon: Icons.workspace_premium_rounded,
              value: experience,
              label: 'Expérience',
            ),
          ),
          _ProfileStatDivider(),
          Expanded(
            child: _ProfileStatCell(
              icon: Icons.task_alt_rounded,
              value: missions,
              label: 'Missions',
            ),
          ),
          _ProfileStatDivider(),
          Expanded(
            child: _ProfileStatCell(
              icon: Icons.schedule_outlined,
              value: response,
              label: 'Réponse',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: AppColors.gray50,
    );
  }
}

class _ProfileStatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gray600),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      iconColor = AppColors.warning;
      iconData = Icons.warning_amber_rounded;
    } else if (verified) {
      iconColor = AppColors.successDark;
      iconData = Icons.check_circle_rounded;
    } else {
      iconColor = AppColors.error;
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
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
        border: Border.all(color: AppColors.gray50, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gray600),
          const SizedBox(width: 5),
          Text(
            level,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRateBadge extends StatelessWidget {
  final double rate;

  const _HeroRateBadge({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.9,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '${rate.toInt()}€/h',
            style: context.text.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}


