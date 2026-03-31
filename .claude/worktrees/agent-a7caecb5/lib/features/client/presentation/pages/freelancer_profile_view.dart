import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../../app/auth_provider.dart';
import '../../../../app/enum/user_role.dart';
import '../../../post/post.dart';
import '../../../post/post_provider.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../profile/profile_provider.dart';
import '../../../profile/data/models/user_profile.dart';
import 'freelancer_reviews_page.dart';

/// Niveau de fiabilité (annulations) du freelancer
enum CancellationLevel { never, rarely, sometimes, often }

extension CancellationLevelExtension on CancellationLevel {
  String get label {
    switch (this) {
      case CancellationLevel.never:    return "N'annule jamais";
      case CancellationLevel.rarely:   return "Annule rarement";
      case CancellationLevel.sometimes:return "Annule parfois";
      case CancellationLevel.often:    return "Annule souvent";
    }
  }

  Color get color {
    switch (this) {
      case CancellationLevel.never:    return const Color(0xFF22C55E);
      case CancellationLevel.rarely:   return const Color(0xFF3B82F6);
      case CancellationLevel.sometimes:return const Color(0xFFF59E0B);
      case CancellationLevel.often:    return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case CancellationLevel.never:    return Icons.workspace_premium_rounded;
      case CancellationLevel.rarely:   return Icons.shield_rounded;
      case CancellationLevel.sometimes:return Icons.running_with_errors_rounded;
      case CancellationLevel.often:    return Icons.dangerous_rounded;
    }
  }
}

/// Page profil du Freelancer vue par le CLIENT
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
  // Données candidature (optionnelles — renseignées depuis CandidatesPage)
  final String? proposedPrice;
  final String? responseTime;
  // ID Supabase du freelancer (pour la messagerie réelle)
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

class _FreelancerProfilePageState extends State<FreelancerProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _openingChat = false;
  UserProfile? _profile;
  bool _loadingProfile = false;

  // Helpers: use loaded profile when available, fall back to constructor params
  String get _name => _profile?.fullName ?? widget.freelancerName;
  String get _avatar => _profile?.avatarUrl ?? widget.freelancerAvatar;
  double get _rate => _profile?.hourlyRate ?? widget.hourlyRate;
  String get _bio => _profile?.bio ?? '';
  String get _address => _profile?.address ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.freelancerId != null) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final loaded = await context.read<ProfileProvider>().fetchProfileById(widget.freelancerId!);
    if (mounted) setState(() { _profile = loaded; _loadingProfile = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openChat() async {
    final freelancerId = widget.freelancerId;
    if (freelancerId == null) {
      // Pas d'ID Supabase — ouvre le chat en mode démo
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatPage(
          contactName: _name,
          contactAvatar: _avatar,
        ),
      ));
      return;
    }

    setState(() => _openingChat = true);
    final auth = context.read<AuthProvider>();
    final isClient = auth.currentRole == UserRole.client;
    final conversationId = await context.read<MessagingProvider>().getOrCreateConversation(
      otherUserId: freelancerId,
      iAmClient: isClient,
    );
    if (!mounted) return;
    setState(() => _openingChat = false);

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatPage(
        conversationId: conversationId,
        contactName: _name,
        contactAvatar: _avatar,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              icon: _openingChat
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chat_rounded, size: 18),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              onPressed: _openingChat ? null : _openChat,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildStatistics(),

          // ─── Tab Bar ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: AppColors.textPrimary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'À propos'),
                Tab(text: 'Publications'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(
                  memberSince: widget.memberSince,
                  missionsCount: widget.missionsCount,
                  experienceLevel: widget.experienceLevel,
                  hourlyRate: _rate,
                  bio: _bio,
                  address: _address,
                ),
                _PostsTab(),
              ],
            ),
          ),
        ],
      ),


    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + badge Ambassadeur en dessous
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_avatar),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  widget.experienceLevel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nom + Tarif sur la même ligne ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${_rate.toInt()} €/h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Rating cliquable
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
                        size: 18,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' — ${widget.reviewsCount} avis',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          // ─── Tarif proposé (si vient d'une candidature) ───
          if (widget.proposedPrice != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tarif proposé',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text(
                    widget.proposedPrice!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📖 Onglet "À propos"
// ─────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final String memberSince;
  final int missionsCount;
  final String experienceLevel;
  final double hourlyRate;
  final String bio;
  final String address;

  const _AboutTab({
    required this.memberSince,
    required this.missionsCount,
    required this.experienceLevel,
    required this.hourlyRate,
    this.bio = '',
    this.address = '',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── À propos de vous ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bio.isNotEmpty
                    ? Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.edit_note_rounded,
                              size: 20, color: AppColors.textHint),
                          const SizedBox(width: 10),
                          Text('Aucune description renseignée.',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textHint)),
                        ]),
                      ),
              ],
            ),
          ),
          const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
          // ─── Infos générales (membre, annulations, niveau, tarif) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(children: [
                  Icon(Icons.card_membership_rounded, size: 22, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('Membre depuis $memberSince',
                      style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Icon(Icons.check_circle_outline_rounded, size: 22, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('$missionsCount missions réalisées',
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),

          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

          // ─── Confiance et vérifications ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle(title: 'CONFIANCE ET VÉRIFICATIONS'),
                SizedBox(height: 12),
                _VerificationItem(
                  label: 'Pièce d\'identité vérifiée',
                  isVerified: true,
                ),
                _VerificationItem(
                  label: 'Adresse e-mail vérifiée',
                  isVerified: true,
                ),
                _VerificationItem(
                  label: 'Numéro de téléphone vérifié',
                  isVerified: true,
                ),
              ],
            ),
          ),

          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

          // ─── Services proposés ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle(title: 'SERVICES PROPOSÉS'),
                SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _ServiceItem(icon: Icons.home_rounded, label: 'Ménage'),
                    _ServiceItem(icon: Icons.grass_rounded, label: 'Jardinage'),
                    _ServiceItem(icon: Icons.iron_rounded, label: 'Repassage'),
                    _ServiceItem(
                        icon: Icons.handyman_rounded, label: 'Bricolage'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

          // ─── Bio ───
          if (bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '"$bio"',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

          // ─── Localisation ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'LOCALISATION'),
                const SizedBox(height: 12),
                if (address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(address,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ]),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(48.8566, 2.3522), // Paris par défaut
                        initialZoom: 12,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  ),
                ),
                const SizedBox(height: 8),
                Text('Zone d\'intervention : 10 km autour de ${address.isNotEmpty ? address : "sa position"}',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📝 Onglet "Publications" — posts du freelancer
// ─────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // En production : filtré par freelancerId
    final posts = context.watch<PostProvider>().posts;

    if (posts.isEmpty) {
      return Center(
        child: Text(
          'Aucune publication pour le moment',
          style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onVote: (vote) => context.read<PostProvider>().vote(post.id, vote),
          onEdit: () {},
          onDelete: () {},
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
          ),
        );
      },
    );
  }
}

// ─── Widgets utilitaires ─────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
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
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String label;
  final bool isVerified;

  const _VerificationItem({required this.label, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 22,
            color: isVerified ? AppColors.primary : AppColors.textHint,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 18),
        ),
        CustomPaint(size: const Size(10, 6), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
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
