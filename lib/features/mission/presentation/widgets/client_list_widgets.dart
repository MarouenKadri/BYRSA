import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../data/models/mission.dart';
import 'shared/mission_shared_widgets.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 👤 Inkern - Widgets Client
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Bouton Candidatures ──────────────────────────────────────────────────────

class CandidatesButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const CandidatesButton({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primary,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: AppInsets.h14v8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count candidat${count > 1 ? 's' : ''}',
                style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              AppGap.w4,
              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Presta Info Row ──────────────────────────────────────────────────────────

class PrestaInfoRow extends StatelessWidget {
  final PrestaInfo presta;
  final int? rating;
  final VoidCallback? onTap;

  const PrestaInfoRow({super.key, required this.presta, this.rating, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(imageUrl: presta.avatarUrl, radius: 16, showVerified: presta.isVerified),
          AppGap.w8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(presta.name, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
              if (rating != null)
                RatingWidget(rating: rating!.toDouble(), showStars: true, compact: true)
              else
                RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount, compact: true),
            ],
          ),
          if (onTap != null) ...[
            AppGap.w8,
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textHint),
          ],
        ],
      ),
    );
  }
}

// ─── Presta Chip Compact ──────────────────────────────────────────────────────

class PrestaChip extends StatelessWidget {
  final PrestaInfo presta;
  final VoidCallback? onTap;

  const PrestaChip({super.key, required this.presta, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardLg),
      child: Container(
        padding: AppInsets.h10v6,
        decoration: BoxDecoration(color: context.colors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.cardLg)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 12, backgroundImage: NetworkImage(presta.avatarUrl), backgroundColor: context.colors.border),
            AppGap.w8,
            Text(presta.name, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
            if (onTap != null) ...[
              AppGap.w4,
              Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Section Candidatures ─────────────────────────────────────────────────────

class CandidatesSection extends StatelessWidget {
  final int candidatesCount;
  final VoidCallback onViewCandidates;

  const CandidatesSection({super.key, required this.candidatesCount, required this.onViewCandidates});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_rounded, size: 22, color: context.colors.primary),
              AppGap.w10,
              Text('Candidatures', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: AppInsets.h12v6,
                decoration: BoxDecoration(
                  color: candidatesCount > 0 ? context.colors.primary.withOpacity(0.1) : context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                ),
                child: Text(
                  '$candidatesCount candidat${candidatesCount > 1 ? 's' : ''}',
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: candidatesCount > 0 ? context.colors.primary : context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (candidatesCount > 0) ...[
            AppGap.h16,
            _CandidatesPreview(count: candidatesCount),
            AppGap.h16,
            AppButton(
              label: 'Voir les candidatures',
              variant: ButtonVariant.primary,
              icon: Icons.people_alt_rounded,
              onPressed: onViewCandidates,
            ),
          ] else ...[
            AppGap.h16,
            const _WaitingState(),
          ],
        ],
      ),
    );
  }
}

class _CandidatesPreview extends StatelessWidget {
  final int count;
  const _CandidatesPreview({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 4 ? 4 : count;
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * 40.0,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: CircleAvatar(radius: 26, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${i + 10}')),
              ),
            ),
          if (count > 4)
            Positioned(
              left: 4 * 40.0,
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: Center(child: Text('+${count - 4}', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),
        ],
      ),
    );
  }
}

class _WaitingState extends StatelessWidget {
  const _WaitingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(AppRadius.button)),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty_rounded, color: context.colors.textTertiary, size: 24),
          AppGap.w12,
          Expanded(
            child: Text(
              'En attente de candidatures...\nLes freelancers intéressés apparaîtront ici.',
              style: context.text.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Presta Sélectionné ───────────────────────────────────────────────

class SelectedPrestaSection extends StatelessWidget {
  final PrestaInfo presta;
  final MissionStatus status;
  final int? rating;
  final VoidCallback? onContact;
  final VoidCallback? onPhone;
  final VoidCallback? onViewProfile;

  const SelectedPrestaSection({
    super.key,
    required this.presta,
    required this.status,
    this.rating,
    this.onContact,
    this.onPhone,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppInsets.h16v8,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.check_circle_rounded, size: 22, color: context.colors.primary),
            AppGap.w10,
            Text('Prestataire choisi', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          AppGap.h16,
          InkWell(
            onTap: onViewProfile,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Row(
              children: [
                UserAvatar(imageUrl: presta.avatarUrl, radius: 32, showVerified: presta.isVerified),
                AppGap.w14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(presta.name, style: context.text.titleLarge),
                      AppGap.h4,
                      RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount),
                    ],
                  ),
                ),
                if (onViewProfile != null)
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
              ],
            ),
          ),

          // ─── Tarif accepté ───
          if (presta.acceptedPrice != null) ...[
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: AppInsets.a14,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarif accepté',
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                  ),
                  Text(
                    presta.acceptedPrice!,
                    style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: context.colors.primary),
                  ),
                ],
              ),
            ),
          ],

          if (status != MissionStatus.paymentHeld && status != MissionStatus.awaitingRelease && status != MissionStatus.closed && status != MissionStatus.cancelled && status != MissionStatus.inDispute && status != MissionStatus.expired && (onContact != null || onPhone != null)) ...[
            AppGap.h16,
            Row(
              children: [
                if (onContact != null)
                  Expanded(
                    child: AppButton(
                      label: 'Message',
                      variant: ButtonVariant.primary,
                      icon: Icons.chat_rounded,
                      onPressed: onContact,
                    ),
                  ),
                if (onContact != null && onPhone != null) AppGap.w10,
                if (onPhone != null)
                  Expanded(
                    child: AppButton(
                      label: 'Téléphone',
                      variant: ButtonVariant.outline,
                      icon: Icons.phone_rounded,
                      onPressed: onPhone,
                    ),
                  ),
              ],
            ),
          ],
          if (status == MissionStatus.closed && rating != null) ...[
            AppGap.h16,
            const Divider(),
            AppGap.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Votre note : ', style: context.text.bodyMedium),
                RatingWidget(rating: rating!.toDouble(), showStars: true),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrestaStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PrestaStatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppInsets.v12,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: context.colors.primary),
            AppGap.h4,
            Text(value, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            AppGap.h2,
            Text(label, style: context.text.labelSmall?.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Action Tile ──────────────────────────────────────────────────────────────

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Padding(
          padding: AppInsets.a16,
          child: Row(
            children: [
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: isDestructive ? AppColors.error.withOpacity(0.08) : context.colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(icon, size: 22, color: isDestructive ? AppColors.error : context.colors.textSecondary),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall?.copyWith(color: isDestructive ? AppColors.error : null)),
                    Text(subtitle, style: context.text.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
