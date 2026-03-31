import 'package:flutter/material.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../data/models/review.dart';

class MyReviewsPage extends StatefulWidget {
  final bool isFreelancer;
  const MyReviewsPage({super.key, required this.isFreelancer});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mes avis',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Reçus'),
                Tab(text: 'Donnés'),
              ],
            ),
          ),
        ),
      ),
      body: Column(children: [
        _buildStatsSummary(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ReviewsTab(
                reviews: widget.isFreelancer
                    ? _freelancerReceivedReviews
                    : _clientReceivedReviews,
              ),
              _ReviewsTab(
                reviews: widget.isFreelancer
                    ? _freelancerGivenReviews
                    : _clientGivenReviews,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStatsSummary() {
    final reviews = widget.isFreelancer
        ? _freelancerReceivedReviews
        : _clientReceivedReviews;

    final total = reviews.length;
    final recommended = reviews.where((r) =>
      r.satisfaction == Satisfaction.satisfait ||
      r.satisfaction == Satisfaction.tresSatisfait,
    ).length;
    final pctRecommend = total == 0 ? 0 : ((recommended / total) * 100).round();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Score global ──
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sentiment_very_satisfied_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '$pctRecommend%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              'recommandent · $total avis',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ]),
        ]),
        const SizedBox(height: 20),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        // ── Répartition par niveau ──
        ...Satisfaction.values.reversed.map((s) {
          final count = reviews.where((r) => r.satisfaction == s).length;
          final pct = total == 0 ? 0.0 : count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Icon(s.icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: Text(s.label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 7,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 22,
                child: Text('$count', style: TextStyle(fontSize: 12, color: AppColors.textTertiary), textAlign: TextAlign.right),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ── Données démo freelancer ───────────────────────────────────

final _freelancerReceivedReviews = [
  Review(
    id: 'fr-r1', revieweeId: 'me', reviewerId: 'u1',
    reviewerName: 'Marie L.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=47',
    satisfaction: Satisfaction.tresSatisfait,
    comment: 'Excellent travail ! Très professionnel et ponctuel. Je recommande vivement.',
    missionId: 'm1', missionTitle: 'Réparation fuite d\'eau',
    createdAt: DateTime(2026, 3, 7),
  ),
  Review(
    id: 'fr-r2', revieweeId: 'me', reviewerId: 'u2',
    reviewerName: 'Pierre D.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=12',
    satisfaction: Satisfaction.tresSatisfait,
    comment: 'Super prestation, travail impeccable. Communication au top !',
    missionId: 'm2', missionTitle: 'Installation prise électrique',
    createdAt: DateTime(2026, 3, 2),
  ),
  Review(
    id: 'fr-r3', revieweeId: 'me', reviewerId: 'u3',
    reviewerName: 'Sophie M.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=23',
    satisfaction: Satisfaction.satisfait,
    comment: 'Bon travail. Petit retard mais résultat très satisfaisant.',
    missionId: 'm3', missionTitle: 'Montage cuisine IKEA',
    createdAt: DateTime(2026, 2, 23),
  ),
];

final _freelancerGivenReviews = [
  Review(
    id: 'fr-g1', revieweeId: 'u1', reviewerId: 'me',
    reviewerName: 'Marie L.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=47',
    satisfaction: Satisfaction.tresSatisfait,
    comment: 'Cliente très agréable, maison propre et consignes claires. Paiement rapide.',
    missionId: 'm1', missionTitle: 'Réparation fuite d\'eau',
    createdAt: DateTime(2026, 3, 6),
  ),
  Review(
    id: 'fr-g2', revieweeId: 'u2', reviewerId: 'me',
    reviewerName: 'Pierre D.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=12',
    satisfaction: Satisfaction.satisfait,
    comment: 'Excellent client, très flexible sur les horaires.',
    missionId: 'm2', missionTitle: 'Installation prise électrique',
    createdAt: DateTime(2026, 3, 2),
  ),
];

// ── Données démo client ───────────────────────────────────────

final _clientReceivedReviews = [
  Review(
    id: 'cl-r1', revieweeId: 'me', reviewerId: 'f1',
    reviewerName: 'Karim B.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=33',
    satisfaction: Satisfaction.tresSatisfait,
    comment: 'Client très agréable, paiement rapide et mission bien définie.',
    missionId: 'cm1', missionTitle: 'Nettoyage appartement',
    createdAt: DateTime(2026, 3, 5),
  ),
  Review(
    id: 'cl-r2', revieweeId: 'me', reviewerId: 'f2',
    reviewerName: 'Lucie R.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=44',
    satisfaction: Satisfaction.correct,
    comment: 'Bonne communication. Logement facile d\'accès.',
    missionId: 'cm2', missionTitle: 'Jardinage',
    createdAt: DateTime(2026, 2, 18),
  ),
];

final _clientGivenReviews = [
  Review(
    id: 'cl-g1', revieweeId: 'f1', reviewerId: 'me',
    reviewerName: 'Karim B.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=33',
    satisfaction: Satisfaction.tresSatisfait,
    comment: 'Travail parfait, appartement impeccable. Très ponctuel !',
    missionId: 'cm1', missionTitle: 'Nettoyage appartement',
    createdAt: DateTime(2026, 3, 6),
  ),
  Review(
    id: 'cl-g2', revieweeId: 'f2', reviewerId: 'me',
    reviewerName: 'Lucie R.',
    reviewerAvatar: 'https://i.pravatar.cc/150?img=44',
    satisfaction: Satisfaction.satisfait,
    comment: 'Bon travail dans le jardin. Globalement satisfait.',
    missionId: 'cm2', missionTitle: 'Jardinage',
    createdAt: DateTime(2026, 2, 19),
  ),
];

// ── Widgets ───────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final List<Review> reviews;
  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sentiment_neutral_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('Aucun avis pour le moment',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: reviews.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ReviewCard(review: reviews[i]),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  const months = [
    'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final s = review.satisfaction;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircleAvatar(radius: 22, backgroundImage: NetworkImage(review.reviewerAvatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.reviewerName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.work_outline_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(review.missionTitle,
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          // Date + badge satisfaction
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_formatDate(review.createdAt),
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(s.icon, size: 15, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(s.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ]),
        ]),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Text(review.comment,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ]),
    );
  }
}
