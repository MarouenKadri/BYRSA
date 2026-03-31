import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../reviews/data/models/review.dart';

/// Page des avis reçus par un freelancer — vue CLIENT
class FreelancerReviewsPage extends StatelessWidget {
  final String freelancerName;
  final String freelancerAvatar;
  final int reviewsCount;

  const FreelancerReviewsPage({
    super.key,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.reviewsCount,
  });

  static final List<Review> _reviews = [
    Review(
      id: 'demo-fr1', revieweeId: 'demo', reviewerId: 'demo-u1',
      reviewerName: 'Marie L.', reviewerAvatar: 'https://i.pravatar.cc/150?img=47',
      satisfaction: Satisfaction.tresSatisfait,
      comment: 'Excellent travail ! Très professionnel et soigneux. Je recommande vivement !',
      missionId: 'demo-m1', missionTitle: 'Ménage appartement 80m²',
      createdAt: DateTime(2026, 3, 7),
    ),
    Review(
      id: 'demo-fr2', revieweeId: 'demo', reviewerId: 'demo-u2',
      reviewerName: 'Pierre D.', reviewerAvatar: 'https://i.pravatar.cc/150?img=12',
      satisfaction: Satisfaction.tresSatisfait,
      comment: 'Super prestation pour l\'entretien de mon jardin. Travail impeccable.',
      missionId: 'demo-m2', missionTitle: 'Entretien jardin',
      createdAt: DateTime(2026, 3, 2),
    ),
    Review(
      id: 'demo-fr3', revieweeId: 'demo', reviewerId: 'demo-u3',
      reviewerName: 'Sophie M.', reviewerAvatar: 'https://i.pravatar.cc/150?img=23',
      satisfaction: Satisfaction.satisfait,
      comment: 'Bon travail dans l\'ensemble. Un peu de retard mais résultat satisfaisant.',
      missionId: 'demo-m3', missionTitle: 'Repassage',
      createdAt: DateTime(2026, 2, 23),
    ),
    Review(
      id: 'demo-fr4', revieweeId: 'demo', reviewerId: 'demo-u4',
      reviewerName: 'Lucas R.', reviewerAvatar: 'https://i.pravatar.cc/150?img=8',
      satisfaction: Satisfaction.tresSatisfait,
      comment: 'Parfait ! Montage de mes meubles IKEA fait rapidement et proprement.',
      missionId: 'demo-m4', missionTitle: 'Montage meubles',
      createdAt: DateTime(2026, 2, 16),
    ),
    Review(
      id: 'demo-fr5', revieweeId: 'demo', reviewerId: 'demo-u5',
      reviewerName: 'Emma B.', reviewerAvatar: 'https://i.pravatar.cc/150?img=45',
      satisfaction: Satisfaction.tresSatisfait,
      comment: 'Travail soigné et professionnel. Je recommande les yeux fermés !',
      missionId: 'demo-m5', missionTitle: 'Bricolage divers',
      createdAt: DateTime(2026, 2, 9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Avis sur $freelancerName',
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: AppInsets.a16,
        children: [
          _buildHeader(context),
          AppGap.h16,
          _buildSummary(context),
          AppGap.h20,
          ..._reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReviewCard(review: r),
              )),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dominant = _reviews
        .map((r) => r.satisfaction)
        .fold<Map<Satisfaction, int>>(
          {},
          (map, s) => map..[s] = (map[s] ?? 0) + 1,
        )
        .entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        CircleAvatar(radius: 30, backgroundImage: NetworkImage(freelancerAvatar)),
        AppGap.w16,
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(freelancerName,
                style: context.text.titleLarge?.copyWith(
                  fontSize: AppFontSize.xl,
                  fontWeight: FontWeight.w700,
                )),
            AppGap.h6,
            Container(
              padding: AppInsets.h10v4,
              decoration: BoxDecoration(
                color: dominant.color.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(AppDesign.radius20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(dominant.icon, size: 16, color: dominant.color),
                AppGap.w5,
                Text(dominant.label,
                    style: context.text.labelMedium?.copyWith(
                      fontSize: AppFontSize.sm,
                      fontWeight: FontWeight.w600,
                      color: dominant.color,
                    )),
              ]),
            ),
            AppGap.h4,
            Text('$reviewsCount avis',
                style: context.text.bodySmall?.copyWith(
                  fontSize: AppFontSize.md,
                  color: context.colors.textSecondary,
                )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final counts = {
      for (final s in Satisfaction.values)
        s: _reviews.where((r) => r.satisfaction == s).length,
    };
    final total = _reviews.length;

    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Répartition',
          style: context.text.titleSmall?.copyWith(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppGap.h12,
        ...Satisfaction.values.map((s) {
          final count = counts[s]!;
          final pct = total == 0 ? 0.0 : count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(s.icon, size: 18, color: s.color),
              AppGap.w8,
              SizedBox(
                width: 90,
                child: Text(s.label,
                    style: context.text.labelMedium?.copyWith(
                      fontSize: AppFontSize.sm,
                      color: context.colors.textSecondary,
                    )),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesign.radius4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: context.colors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(s.color),
                    minHeight: 8,
                  ),
                ),
              ),
              AppGap.w8,
              SizedBox(
                width: 20,
                child: Text('$count',
                    style: context.text.labelMedium?.copyWith(
                      fontSize: AppFontSize.sm,
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.right),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  String _fmt(DateTime dt) {
    const m = ['jan.','fév.','mars','avr.','mai','juin','juil.','août','sept.','oct.','nov.','déc.'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = review.satisfaction;
    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(review.reviewerAvatar)),
          AppGap.w12,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(review.reviewerName,
                    style: context.text.titleSmall?.copyWith(
                      fontSize: AppFontSize.body,
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text(_fmt(review.createdAt),
                    style: context.text.labelMedium?.copyWith(
                      fontSize: AppFontSize.sm,
                      color: context.colors.textTertiary,
                    )),
              ]),
              AppGap.h5,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(AppDesign.radius20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(s.icon, size: 14, color: s.color),
                  AppGap.w4,
                  Text(s.label,
                      style: context.text.labelSmall?.copyWith(
                        fontSize: AppFontSize.xs,
                        fontWeight: FontWeight.w600,
                        color: s.color,
                      )),
                ]),
              ),
            ]),
          ),
        ]),
        AppGap.h10,
        Container(
          padding: AppInsets.h10v6,
          decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(AppDesign.radius8)),
          child: Row(children: [
            Icon(Icons.work_outline_rounded,
                size: 14, color: context.colors.textSecondary),
            AppGap.w6,
            Text(review.missionTitle,
                style: context.text.labelMedium?.copyWith(
                  fontSize: AppFontSize.sm,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
          ]),
        ),
        AppGap.h10,
        Text(review.comment,
            style: context.text.bodyMedium?.copyWith(
              fontSize: AppFontSize.base,
              color: context.colors.textSecondary,
              height: 1.5,
            )),
      ]),
    );
  }
}
