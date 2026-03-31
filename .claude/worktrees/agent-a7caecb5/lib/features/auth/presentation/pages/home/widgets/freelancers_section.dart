import 'package:flutter/material.dart';
import '../../../widgets/top_freelancer_card.dart';
import '../../../../data/models/freelancer.dart';
import '../../../../../client/presentation/pages/freelancer_profile_view.dart';

class FreelancersRow extends StatelessWidget {
  const FreelancersRow({super.key});

  @override
  Widget build(BuildContext context) {
    const freelancers = <Freelancer>[
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

    void openProfile(Freelancer f) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FreelancerProfileView(
            freelancerName: f.name,
            freelancerAvatar: f.imageUrl,
            rating: f.rating,
          ),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < freelancers.length; i += 2) {
      final first = freelancers[i];
      final second = (i + 1 < freelancers.length) ? freelancers[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: TopFreelancerCard(freelancer: first, onTap: () => openProfile(first))),
              const SizedBox(width: 12),
              if (second != null)
                Expanded(child: TopFreelancerCard(freelancer: second, onTap: () => openProfile(second)))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
