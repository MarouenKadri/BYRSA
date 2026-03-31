import 'package:flutter/material.dart';
import '../../../../app/theme/design_tokens.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Avis sur $freelancerName',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSummary(),
          const SizedBox(height: 20),
          ..._reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReviewCard(review: r),
              )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        CircleAvatar(radius: 30, backgroundImage: NetworkImage(freelancerAvatar)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(freelancerName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: dominant.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(dominant.icon, size: 16, color: dominant.color),
                const SizedBox(width: 5),
                Text(dominant.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dominant.color)),
              ]),
            ),
            const SizedBox(height: 4),
            Text('$reviewsCount avis',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSummary() {
    final counts = {
      for (final s in Satisfaction.values)
        s: _reviews.where((r) => r.satisfaction == s).length,
    };
    final total = _reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Répartition',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...Satisfaction.values.map((s) {
          final count = counts[s]!;
          final pct = total == 0 ? 0.0 : count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(s.icon, size: 18, color: s.color),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: Text(s.label,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(s.color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(review.reviewerAvatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(review.reviewerName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(_fmt(review.createdAt),
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ]),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(s.icon, size: 14, color: s.color),
                  const SizedBox(width: 4),
                  Text(s.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: s.color)),
                ]),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.work_outline_rounded,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(review.missionTitle,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 10),
        Text(review.comment,
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}
