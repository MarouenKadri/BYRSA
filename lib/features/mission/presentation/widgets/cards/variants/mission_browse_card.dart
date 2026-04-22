import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_shared_widgets.dart';
import '../../freelancer_list_widgets.dart' show DistanceBadge;
import '../primitives/mission_card_frame.dart';
import '../primitives/mission_meta_row.dart';

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

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isApplied ? 0.72 : 1.0,
      child: MissionCardFrame(
        onTap: onTap,
        radius: MissionCardFrame.radiusDefault,
        color: context.colors.surface,
        shadows: MissionCardFrame.browseShadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mission.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(MissionCardFrame.radiusDefault),
                ),
                child: MissionImageHeader(
                  images: mission.images,
                  fallbackIcon: mission.categoryIcon,
                  heroTag: 'mission-img-${mission.id}',
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(MissionCardFrame.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryRow(mission: mission, isApplied: isApplied),
                  AppGap.h14,
                  Text(
                    mission.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MissionCardFrame.titleStyle,
                  ),
                  AppGap.h10,
                  Text(
                    mission.description,
                    style: MissionCardFrame.subtitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h14,
                  MissionMetaRow(items: [
                    MissionMetaItem(icon: Icons.calendar_today_outlined, text: mission.formattedDate),
                    MissionMetaItem(icon: Icons.schedule_outlined, text: mission.timeSlot),
                    MissionMetaItem(icon: Icons.location_on_outlined, text: mission.address.shortAddress),
                  ]),
                  AppGap.h16,
                  Divider(height: 1, color: context.colors.divider),
                  AppGap.h16,
                  _Footer(mission: mission),
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
                style: MissionCardFrame.metaStyle,
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
              border: Border.all(color: context.colors.border),
            ),
            child: Text(
              'Déjà postulé',
              style: MissionCardFrame.metaStyle,
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

  const _Footer({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BudgetText(budget: mission.budget, large: true),
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
              style: MissionCardFrame.metaStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        Icon(Icons.people_outline_rounded, size: 14, color: context.colors.textHint),
        AppGap.w4,
        Text(
          '${mission.candidatesCount}',
          style: MissionCardFrame.metaStyle,
        ),
      ],
    );
  }
}
