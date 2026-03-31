import 'package:flutter/material.dart';

import '../../../widgets/top_freelancer_card.dart';
import '../../../../data/models/freelancer.dart';
import '../../../../../client/presentation/pages/freelancer_profile_view.dart';

class FreelancersRow extends StatelessWidget {
  const FreelancersRow({super.key});

  static const _freelancers = <Freelancer>[
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _freelancers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final f = _freelancers[index];
          return TopFreelancerCard(
            freelancer: f,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FreelancerProfileView(
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
