import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/profile_provider.dart';

enum CancellationLevel {
  never,
  rarely,
  sometimes,
  often,
}

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

class ClientProfileView extends StatefulWidget {
  final String clientName;
  final String clientAvatar;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final String memberSince;
  final CancellationLevel cancellationLevel;
  final String level;
  final String? clientId;

  const ClientProfileView({
    super.key,
    this.clientName = 'Marie',
    this.clientAvatar = 'https://i.pravatar.cc/150?img=47',
    this.rating = 4.8,
    this.reviewsCount = 12,
    this.missionsCount = 18,
    this.memberSince = 'Mars 2023',
    this.cancellationLevel = CancellationLevel.rarely,
    this.level = 'Ambassadeur',
    this.clientId,
  });

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<ClientProfileView> {
  bool _openingChat = false;
  UserProfile? _profile;
  bool _loadingProfile = false;

  String get _name => _profile?.fullName ?? widget.clientName;
  String get _avatar => _profile?.avatarUrl ?? widget.clientAvatar;

  String get _memberStat {
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

  String get _missionsStat => '${widget.missionsCount}';
  String get _reliabilityStat => '${widget.cancellationLevel.reliabilityScore}%';
  String get _levelLabel => _spacedLabel(widget.level);

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final loaded = await context.read<ProfileProvider>().fetchProfileById(widget.clientId!);
    if (!mounted) return;
    setState(() {
      _profile = loaded;
      _loadingProfile = false;
    });
  }

  Future<void> _openChat() async {
    final clientId = widget.clientId;
    if (clientId == null) {
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
    final conversationId = await context.read<MessagingProvider>().getOrCreateConversation(
          otherUserId: clientId,
          iAmClient: false,
        );
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
      backgroundColor: const Color(0xFFFAFAFA),
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
            _buildIdentityCard(),
            _buildTrustCard(),
            AppGap.h28,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
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
                    width: 108,
                    height: 108,
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
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.06,
                        color: const Color(0xFF101418),
                      ),
                    ),
                    AppGap.h10,
                    Text(
                      _levelLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.2,
                        color: const Color(0xFF101418),
                      ),
                    ),
                    AppGap.h16,
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientReviewsPage(
                            clientName: _name,
                            clientAvatar: _avatar,
                            rating: widget.rating,
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
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF101418),
                            ),
                          ),
                          Text(
                            '  ${widget.reviewsCount} avis',
                            style: GoogleFonts.inter(
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
              border: Border.all(color: const Color(0xFFF0F1F3)),
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
                _StatCard(value: _memberStat, label: 'Membre'),
                const _StatDivider(),
                _StatCard(value: _missionsStat, label: 'Missions'),
                const _StatDivider(),
                _StatCard(value: _reliabilityStat, label: 'Fiabilité'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'Profil client'),
            AppGap.h12,
            Text(
              "Client actif sur la plateforme depuis ${widget.memberSince.toLowerCase()}, avec ${widget.missionsCount} missions publiées.",
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.65,
                color: const Color(0xFF353B43),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F1F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'Certification'),
            AppGap.h14,
            const _VerificationItem(label: "Pièce d'identité vérifiée"),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            const _VerificationItem(label: 'Adresse e-mail vérifiée'),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            const _VerificationItem(label: 'Numéro de téléphone vérifié'),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            const _VerificationItem(label: 'Moyen de paiement vérifié'),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            _VerificationItem(label: 'Membre depuis ${widget.memberSince}'),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            _VerificationItem(label: '${widget.missionsCount} missions demandées'),
            const Divider(height: 24, color: Color(0xFFEDEEF0)),
            _VerificationItem(label: widget.cancellationLevel.label),
          ],
        ),
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
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101418),
            ),
          ),
          AppGap.h4,
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8E959D),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: const Color(0xFFEDEEF0),
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
      style: GoogleFonts.inter(
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
          color: Color(0xFF101418),
        ),
        AppGap.w12,
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
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

String _spacedLabel(String value) {
  return value.toUpperCase().split('').where((part) => part.isNotEmpty).join(' ');
}

/// ─────────────────────────────────────────────────────────────
/// ⭐ Page des avis du client (donnés par les freelancers)
/// ─────────────────────────────────────────────────────────────
class ClientReviewsPage extends StatelessWidget {
  final String clientName;
  final String clientAvatar;
  final double rating;
  final int reviewsCount;

  const ClientReviewsPage({
    super.key,
    required this.clientName,
    required this.clientAvatar,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Avis sur $clientName',
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: AppInsets.a16,
        children: [
          _buildHeader(context),
          AppGap.h16,
          _buildRatingSummary(context),
          AppGap.h20,
          ..._buildReviewsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(clientAvatar)),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientName, style: context.text.headlineSmall),
                AppGap.h4,
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: AppColors.amber),
                    AppGap.w4,
                    Text('${rating.toStringAsFixed(1)}/5', style: context.text.titleSmall),
                    Text(' • $reviewsCount avis', style: context.text.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    return Container(
      padding: AppInsets.a20,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Répartition des notes', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          AppGap.h16,
          _RatingBar(stars: 5, percentage: 0.75, count: 9),
          _RatingBar(stars: 4, percentage: 0.17, count: 2),
          _RatingBar(stars: 3, percentage: 0.08, count: 1),
          _RatingBar(stars: 2, percentage: 0.0,  count: 0),
          _RatingBar(stars: 1, percentage: 0.0,  count: 0),
        ],
      ),
    );
  }

  List<Widget> _buildReviewsList(BuildContext context) {
    final reviews = [
      _Review(freelancerName: 'Thomas R.', freelancerAvatar: 'https://i.pravatar.cc/150?img=3',  rating: 5, date: 'Il y a 3 jours',   comment: 'Cliente très agréable et respectueuse. Les instructions étaient claires et le paiement rapide. Je recommande !',          mission: 'Ménage appartement'),
      _Review(freelancerName: 'Julie M.',  freelancerAvatar: 'https://i.pravatar.cc/150?img=25', rating: 5, date: 'Il y a 1 semaine', comment: 'Excellente cliente ! Ponctuelle, accueillante et très claire dans ses attentes. Un plaisir de travailler pour elle.', mission: 'Repassage'),
      _Review(freelancerName: 'Marc D.',   freelancerAvatar: 'https://i.pravatar.cc/150?img=11', rating: 4, date: 'Il y a 2 semaines',comment: 'Bonne expérience globale. Cliente sérieuse et professionnelle. Le logement était bien préparé pour l\'intervention.',  mission: 'Jardinage'),
      _Review(freelancerName: 'Sarah L.',  freelancerAvatar: 'https://i.pravatar.cc/150?img=32', rating: 5, date: 'Il y a 1 mois',    comment: 'Super cliente ! Toujours disponible pour répondre aux questions. Paiement immédiat après la mission.',               mission: 'Ménage + Repassage'),
      _Review(freelancerName: 'Antoine B.',freelancerAvatar: 'https://i.pravatar.cc/150?img=7',  rating: 5, date: 'Il y a 1 mois',    comment: 'Très bonne communication et consignes précises. Je n\'hésiterai pas à accepter d\'autres missions de sa part.',      mission: 'Bricolage'),
    ];

    return reviews.map((review) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: AppInsets.a16,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundImage: NetworkImage(review.freelancerAvatar)),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.freelancerName, style: context.text.titleSmall),
                      AppGap.h2,
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 16, color: AppColors.amber,
                          )),
                          AppGap.w8,
                          Text(review.date, style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppGap.h12,
            Container(
              padding: AppInsets.h10v6,
              decoration: BoxDecoration(color: context.colors.surfaceAlt, borderRadius: BorderRadius.circular(AppDesign.radius8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline_rounded, size: 14, color: context.colors.textSecondary),
                  AppGap.w6,
                  Text(review.mission, style: context.text.labelMedium),
                ],
              ),
            ),
            AppGap.h12,
            Text(review.comment, style: context.text.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      );
    }).toList();
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double percentage;
  final int count;

  const _RatingBar({required this.stars, required this.percentage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.v4,
      child: Row(
        children: [
          SizedBox(width: 16, child: Text('$stars', style: context.text.bodySmall)),
          const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
          AppGap.w10,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radius4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: context.colors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
                minHeight: 8,
              ),
            ),
          ),
          AppGap.w10,
          SizedBox(width: 24, child: Text('$count', style: context.text.bodySmall, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _Review {
  final String freelancerName;
  final String freelancerAvatar;
  final int rating;
  final String date;
  final String comment;
  final String mission;

  const _Review({
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.mission,
  });
}
