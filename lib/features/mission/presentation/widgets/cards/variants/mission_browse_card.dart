import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_shared_widgets.dart';
import '../../freelancer_list_widgets.dart';
import '../primitives/mission_card_frame.dart';

// ─── Variant : Marketplace freelancer ────────────────────────────────────────
// Responsabilité : afficher une mission disponible dans le marketplace.
// Compose MissionCardFrame. Design riche : image, titre Playfair, client avatar,
// badge distance ou "Déjà postulé".
// ─────────────────────────────────────────────────────────────────────────────

class MissionBrowseCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final bool isApplied;

  const MissionBrowseCard({
    super.key,
    required this.mission,
    required this.onTap,
    this.isApplied = false,
  });

  static const double _radius = 24;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isApplied ? 0.72 : 1.0,
      child: MissionCardFrame(
        onTap: onTap,
        radius: _radius,
        color: context.colors.surface,
        shadows: MissionCardFrame.browseShadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mission.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_radius),
                ),
                child: MissionImageHeader(
                  images: mission.images,
                  fallbackIcon: mission.categoryIcon,
                  heroTag: 'mission-img-${mission.id}',
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryRow(mission: mission, isApplied: isApplied),
                  AppGap.h14,
                  Text(
                    mission.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      color: AppColors.inkDark,
                    ),
                  ),
                  AppGap.h10,
                  Text(
                    mission.description,
                    style: context.text.bodySmall?.copyWith(
                      height: 1.5,
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h14,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(icon: Icons.calendar_today_rounded, text: mission.formattedDate, compact: true),
                      InfoChip(icon: Icons.schedule_rounded, text: mission.timeSlot, compact: true),
                      InfoChip(icon: Icons.location_on_outlined, text: mission.address.shortAddress, compact: true),
                    ],
                  ),
                  AppGap.h16,
                  Divider(height: 1, color: context.colors.divider),
                  AppGap.h16,
                  _Footer(mission: mission, context: context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Mission mission;
  final bool isApplied;

  const _CategoryRow({required this.mission, required this.isApplied});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: mission.categoryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: mission.categoryColor.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mission.categoryIcon,
                size: 14,
                color: mission.categoryColor.withValues(alpha: 0.78),
              ),
              AppGap.w6,
              Text(
                mission.categoryName,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (isApplied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD6DCE5)),
            ),
            child: Text(
              'Déjà postulé',
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
          )
        else if (mission.address.distance != null)
          DistanceBadge(distance: mission.address.distance!, compact: true),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final Mission mission;
  final BuildContext context;

  const _Footer({required this.mission, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          mission.budget.displayText,
          style: context.text.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF163127),
            letterSpacing: -0.3,
          ),
        ),
        AppGap.w16,
        if (mission.client != null) ...[
          UserAvatar(
            imageUrl: mission.client!.avatarUrl,
            radius: 14,
            showVerified: mission.client!.isVerified,
          ),
          AppGap.w8,
          Flexible(
            child: Text(
              mission.client!.name,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        Icon(Icons.people_outline_rounded, size: 14, color: context.colors.textHint),
        AppGap.w4,
        Text(
          '${mission.candidatesCount}',
          style: context.text.labelMedium?.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ],
    );
  }
}
