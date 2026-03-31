import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../profile/profile_provider.dart';
import '../../../profile/data/models/user_profile.dart';

/// Enum pour les niveaux d'annulation
enum CancellationLevel {
  never,    // N'annule jamais
  rarely,   // Annule rarement
  sometimes,// Annule parfois
  often,    // Annule souvent
}

/// Extension pour obtenir les infos d'affichage du niveau d'annulation
extension CancellationLevelExtension on CancellationLevel {
  String get label {
    switch (this) {
      case CancellationLevel.never:
        return "N'annule jamais";
      case CancellationLevel.rarely:
        return "Annule rarement";
      case CancellationLevel.sometimes:
        return "Annule parfois";
      case CancellationLevel.often:
        return "Annule souvent";
    }
  }

  Color get color {
    switch (this) {
      case CancellationLevel.never:
        return const Color(0xFF22C55E);
      case CancellationLevel.rarely:
        return const Color(0xFF3B82F6);
      case CancellationLevel.sometimes:
        return const Color(0xFFF59E0B);
      case CancellationLevel.often:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case CancellationLevel.never:
        return Icons.workspace_premium_rounded;   // médaille premium
      case CancellationLevel.rarely:
        return Icons.shield_rounded;              // bouclier fiabilité
      case CancellationLevel.sometimes:
        return Icons.running_with_errors_rounded; // attention
      case CancellationLevel.often:
        return Icons.dangerous_rounded;           // danger
    }
  }
}

/// Page profil du Client vue par le FREELANCER
class ClientProfileView extends StatefulWidget {
  final String clientName;
  final String clientAvatar;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final String memberSince;
  final CancellationLevel cancellationLevel;
  final String level;
  // ID Supabase du client (pour la messagerie réelle)
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

  String get _name => _profile?.fullName ?? widget.clientName;
  String get _avatar => _profile?.avatarUrl ?? widget.clientAvatar;

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    final loaded = await context.read<ProfileProvider>().fetchProfileById(widget.clientId!);
    if (mounted) setState(() => _profile = loaded);
  }

  Future<void> _openChat() async {
    final clientId = widget.clientId;
    if (clientId == null) {
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
    final conversationId = await context.read<MessagingProvider>().getOrCreateConversation(
      otherUserId: clientId,
      iAmClient: false,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),
            _buildCancellationSection(),
            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),
            _buildVerificationsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),


    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + badge niveau en dessous
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
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, size: 22, color: AppColors.primary),
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
                  widget.level,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                // Rating cliquable
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
                      const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        ' — ${widget.reviewsCount} avis',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
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

  Widget _buildCancellationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Membre depuis
          Row(
            children: [
              Icon(Icons.card_membership_rounded, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Membre depuis ${widget.memberSince}',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Missions demandées
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                '${widget.missionsCount} missions demandées',
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONFIANCE ET VÉRIFICATIONS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          const _VerificationItem(label: 'Pièce d\'identité vérifiée', isVerified: true),
          const _VerificationItem(label: 'Adresse e-mail vérifiée', isVerified: true),
          const _VerificationItem(label: 'Numéro de téléphone vérifié', isVerified: true),
          const _VerificationItem(label: 'Moyen de paiement vérifié', isVerified: true),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

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
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
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
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Avis sur $clientName',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildRatingSummary(),
          const SizedBox(height: 20),
          ..._buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(clientAvatar)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB800)),
                    const SizedBox(width: 4),
                    Text('${rating.toStringAsFixed(1)}/5', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(' • $reviewsCount avis', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Répartition des notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          _RatingBar(stars: 5, percentage: 0.75, count: 9),
          _RatingBar(stars: 4, percentage: 0.17, count: 2),
          _RatingBar(stars: 3, percentage: 0.08, count: 1),
          _RatingBar(stars: 2, percentage: 0.0,  count: 0),
          _RatingBar(stars: 1, percentage: 0.0,  count: 0),
        ],
      ),
    );
  }

  List<Widget> _buildReviewsList() {
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundImage: NetworkImage(review.freelancerAvatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.freelancerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 16, color: const Color(0xFFFFB800),
                          )),
                          const SizedBox(width: 8),
                          Text(review.date, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(review.mission, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(review.comment, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 16, child: Text('$stars', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 24, child: Text('$count', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.right)),
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
