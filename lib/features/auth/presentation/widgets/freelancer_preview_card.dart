import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/freelancer.dart';

class FreelancerPreviewCard extends StatelessWidget {
  final Freelancer freelancer;
  final VoidCallback? onTap;
  final double? width;
  final int missionsCount;
  final int reviewsCount;

  const FreelancerPreviewCard({
    super.key,
    required this.freelancer,
    this.onTap,
    this.width,
    this.missionsCount = 0,
    this.reviewsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ──────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    freelancer.imageUrl.isNotEmpty
                        ? Image.network(
                            freelancer.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _AvatarFallback(name: freelancer.name),
                          )
                        : _AvatarFallback(name: freelancer.name),
                    // Badge vérifié
                    if (freelancer.isVerified)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Infos ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    freelancer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  // Spécialité
                  if (freelancer.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      freelancer.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 7),

                  // Étoiles + avis
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = freelancer.rating > 0
                            ? freelancer.rating >= i + 1
                            : false;
                        return Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: filled
                              ? AppColors.amber
                              : context.colors.border,
                        );
                      }),
                      if (reviewsCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($reviewsCount)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  Divider(height: 1, color: context.colors.divider),

                  const SizedBox(height: 8),

                  // Tarif + missions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          freelancer.job,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      if (missionsCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$missionsCount missions',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
