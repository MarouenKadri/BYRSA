import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../app/widgets/cigale_tab_bar.dart';
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
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text('Mes avis', style: context.reviewPageTitleStyle),
        centerTitle: true,
        bottom: CigaleTabBar(
          controller: _tabController,
          tabs: const [
            CigaleTab(icon: Icons.star_rounded, label: 'Reçus'),
            CigaleTab(icon: Icons.rate_review_rounded, label: 'Donnés'),
          ],
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

    return AppSurfaceCard(
      margin: AppInsets.a16,
      padding: AppInsets.a20,
      border: Border.all(color: context.colors.border),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Score global ──
        Row(children: [
          AppSurfaceCard(
            padding: AppInsets.a12,
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppDesign.radius14),
            child: const Icon(
              Icons.sentiment_very_satisfied_rounded,
              size: AppReviewMetrics.summaryIconSize,
              color: AppColors.primary,
            ),
          ),
          AppGap.w16,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '$pctRecommend%',
              style: context.reviewSummaryScoreStyle,
            ),
            Text(
              'recommandent · $total avis',
              style: context.reviewSummaryMetaStyle,
            ),
          ]),
        ]),
        AppGap.h20,
        Divider(height: 1, color: context.colors.divider),
        AppGap.h16,
        // ── Répartition par niveau ──
        ...Satisfaction.values.reversed.map((s) {
          final count = reviews.where((r) => r.satisfaction == s).length;
          final pct = total == 0 ? 0.0 : count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Icon(s.icon, size: 20, color: context.colors.textSecondary),
              AppGap.w10,
              SizedBox(
                width: AppReviewMetrics.distributionLabelWidth,
                child: Text(
                  s.label,
                  style: context.reviewDistributionLabelStyle,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesign.radius4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: context.colors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: AppReviewMetrics.progressHeight,
                  ),
                ),
              ),
              AppGap.w10,
              SizedBox(
                width: AppReviewMetrics.distributionCountWidth,
                child: Text(
                  '$count',
                  style: context.reviewDistributionCountStyle,
                  textAlign: TextAlign.right,
                ),
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
              size: 64, color: context.colors.textHint),
          AppGap.h12,
          Text('Aucun avis pour le moment',
              style: context.reviewEmptyStateStyle),
        ]),
      );
    }
    return ListView.builder(
      padding: AppInsets.h16,
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
    return AppSurfaceCard(
      padding: AppInsets.a16,
      border: Border.all(color: context.colors.border),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircleAvatar(
            radius: AppReviewMetrics.reviewAvatarRadius,
            backgroundImage: NetworkImage(review.reviewerAvatar),
          ),
          AppGap.w12,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.reviewerName,
                  style: context.reviewAuthorStyle),
              AppGap.h4,
              Row(children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: AppReviewMetrics.missionIconSize,
                  color: context.colors.textHint,
                ),
                AppGap.w5,
                Expanded(
                  child: Text(review.missionTitle,
                      style: context.reviewMissionStyle,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
          AppGap.w8,
          // Date + badge satisfaction
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_formatDate(review.createdAt),
                style: context.reviewDateStyle),
            AppGap.h6,
            AppSurfaceCard(
              padding: AppInsets.h10v5,
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppDesign.radius14Lg),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  s.icon,
                  size: AppReviewMetrics.satisfactionIconSize,
                  color: AppColors.primary,
                ),
                AppGap.w5,
                Text(s.label, style: context.reviewBadgeStyle),
              ]),
            ),
          ]),
        ]),
        if (review.comment.isNotEmpty) ...[
          AppGap.h12,
          Divider(height: 1, color: context.colors.divider),
          AppGap.h12,
          Text(review.comment,
              style: context.reviewCommentStyle),
        ],
      ]),
    );
  }
}
