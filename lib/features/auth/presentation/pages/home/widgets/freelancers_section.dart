import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/freelancer_preview_card.dart';
import '../../../../data/models/freelancer.dart';
import '../../../../../profile/profile_provider.dart';
import '../../../../../client/presentation/pages/freelancer_profile_view.dart';

class FreelancersRow extends StatefulWidget {
  const FreelancersRow({super.key});

  @override
  State<FreelancersRow> createState() => _FreelancersRowState();
}

class _FreelancersRowState extends State<FreelancersRow> {
  static const _fallbackFreelancers = <Freelancer>[
    Freelancer(
      name: 'Fatima',
      job: 'Ménage · Repassage',
      rating: 4.9,
      subtitle: '+45 missions réalisées',
      imageUrl:
          'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
    ),
    Freelancer(
      name: 'Lucas',
      job: 'Bricolage · Montage',
      rating: 4.8,
      subtitle: 'Réponse en moins de 10 min',
      imageUrl:
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
    ),
    Freelancer(
      name: 'Emma',
      job: 'Jardinage · Entretien',
      rating: 4.9,
      subtitle: '+30 missions réalisées',
      imageUrl:
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
    ),
    Freelancer(
      name: 'Karim',
      job: 'Plomberie · Électricité',
      rating: 4.7,
      subtitle: 'Réponse en moins de 5 min',
      imageUrl:
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  Freelancer _fromRow(Map<String, dynamic> row) {
    final firstName = (row['first_name'] ?? '') as String;
    final lastName = (row['last_name'] ?? '') as String;
    final fullName = '$firstName $lastName'.trim();
    final hourlyRateRaw = row['hourly_rate'];
    final hourlyRate = hourlyRateRaw is num
        ? hourlyRateRaw.toInt()
        : int.tryParse('$hourlyRateRaw') ?? 0;
    final ratingRaw = row['rating'];
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;
    return Freelancer(
      name: fullName.isEmpty ? 'Prestataire' : fullName,
      job: hourlyRate > 0 ? '$hourlyRate€/h' : 'Freelancer',
      rating: rating > 0 ? rating : 4.8,
      subtitle: '',
      imageUrl: (row['avatar_url'] ?? '') as String,
      isVerified: (row['is_verified'] ?? false) as bool,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final loaded = provider.freelancers
        .map(
          (row) => _HomeFreelancerItem(
            freelancer: _fromRow(row),
            freelancerId: row['id'] as String?,
          ),
        )
        .toList(growable: false);
    final fallback = _fallbackFreelancers
        .map((f) => _HomeFreelancerItem(freelancer: f))
        .toList(growable: false);
    final items = loaded.isEmpty ? fallback : loaded;
    final itemCount = items.length > 8 ? 8 : items.length;

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final f = item.freelancer;
          return FreelancerPreviewCard(
            freelancer: f,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FreelancerProfileView(
                  freelancerId: item.freelancerId,
                  freelancerName: f.name,
                  freelancerAvatar: f.imageUrl,
                  rating: f.rating,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeFreelancerItem {
  final Freelancer freelancer;
  final String? freelancerId;

  const _HomeFreelancerItem({required this.freelancer, this.freelancerId});
}
