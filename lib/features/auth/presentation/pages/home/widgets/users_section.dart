import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';

class FeaturesSection extends StatefulWidget {
  const FeaturesSection({super.key});

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  static const _cards = [
    _CardData(
      icon: Icons.search_rounded,
      title: 'Vous êtes client ?',
      description:
          'Trouvez des prestataires qualifiés pour tous vos services à domicile',
      features: [
        'Ménage, jardinage, bricolage...',
        'Profils vérifiés et notés',
        'Réponse rapide garantie',
      ],
      isPrimary: true,
    ),
    _CardData(
      icon: Icons.work_rounded,
      title: 'Vous êtes prestataire ?',
      description:
          'Développez votre activité et trouvez de nouvelles missions',
      features: [
        'Accédez à des milliers de demandes',
        'Gérez votre planning facilement',
        'Paiements sécurisés et rapides',
      ],
      isPrimary: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 248,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _cards.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                _FeatureCard(data: _cards[index]),
          ),
        ),
        AppGap.h14,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _cards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? context.colors.primary
                    : context.colors.border,
                borderRadius: BorderRadius.circular(AppDesign.radius10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final bool isPrimary;

  const _CardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.isPrimary,
  });
}

class _FeatureCard extends StatelessWidget {
  final _CardData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final accentColor = data.isPrimary ? context.colors.primary : context.colors.info;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: AppInsets.a20,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius14),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radius14Lg),
                ),
                child: Icon(data.icon, color: accentColor, size: 26),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      data.description,
                      style: context.text.labelMedium?.copyWith(
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h18,

          // ─── Features ───
          ...data.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: accentColor,
                    ),
                  ),
                  AppGap.w10,
                  Expanded(
                    child: Text(
                      feature,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
