import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../shared/mission_common_widgets.dart';

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
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count candidat${count > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 4),
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
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(imageUrl: presta.avatarUrl, radius: 16, showVerified: presta.isVerified),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(presta.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (rating != null)
                RatingWidget(rating: rating!.toDouble(), showStars: true, compact: true)
              else
                RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount, compact: true),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 12, backgroundImage: NetworkImage(presta.avatarUrl), backgroundColor: AppColors.border),
            const SizedBox(width: 8),
            Text(presta.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
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
              const Icon(Icons.people_alt_rounded, size: 22, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text('Candidatures', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: candidatesCount > 0 ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$candidatesCount candidat${candidatesCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: candidatesCount > 0 ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (candidatesCount > 0) ...[
            const SizedBox(height: 16),
            _CandidatesPreview(count: candidatesCount),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewCandidates,
                icon: const Icon(Icons.people_alt_rounded, size: 20),
                label: const Text('Voir les candidatures'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
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
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: Center(child: Text('+${count - 4}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.button)),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty_rounded, color: AppColors.textTertiary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'En attente de candidatures...\nLes freelancers intéressés apparaîtront ici.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Prestataire choisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          InkWell(
            onTap: onViewProfile,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                UserAvatar(imageUrl: presta.avatarUrl, radius: 32, showVerified: presta.isVerified),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(presta.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount),
                    ],
                  ),
                ),
                if (onViewProfile != null)
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
              ],
            ),
          ),

          // ─── Tarif accepté ───
          if (presta.acceptedPrice != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tarif accepté',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text(
                    presta.acceptedPrice!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],

          if (status != MissionStatus.waitingPayment && status != MissionStatus.closed && status != MissionStatus.cancelled && status != MissionStatus.dispute && status != MissionStatus.expired && (onContact != null || onPhone != null)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onContact != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onContact,
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (onContact != null && onPhone != null) const SizedBox(width: 10),
                if (onPhone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPhone,
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: const Text('Téléphone'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (status == MissionStatus.closed && rating != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Votre note : ', style: TextStyle(fontSize: 14, color: Colors.black54)),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive ? AppColors.error.withOpacity(0.08) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: isDestructive ? AppColors.error : AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
