import 'package:flutter/material.dart' hide FilterChip;

import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../data/models/mission.dart';
import 'shared/mission_shared_widgets.dart';
import '../../../freelancer/presentation/pages/client_profile_view.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔧 Inkern - Widgets Freelancer
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Client Info Row ──────────────────────────────────────────────────────────

class ClientInfoRow extends StatelessWidget {
  final ClientInfo client;
  final bool compact;

  const ClientInfoRow({super.key, required this.client, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(imageUrl: client.avatarUrl, radius: compact ? 16 : 18, showVerified: client.isVerified),
        AppGap.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(client.name, style: (compact ? context.text.bodySmall : context.text.bodyMedium)?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
              AppGap.h2,
              RatingWidget(rating: client.rating, missionsCount: client.missionsCount, compact: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Client (Détail Mission) ─────────────────────────────────────────

class ClientSection extends StatelessWidget {
  final ClientInfo client;
  final String? missionBudget;
  final VoidCallback? onMessage;
  final VoidCallback? onPhone;
  final bool canViewProfile;

  const ClientSection({super.key, required this.client, this.missionBudget, this.onMessage, this.onPhone, this.canViewProfile = false});

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientProfileView(
          clientId: client.id,
          clientName: client.name,
          clientAvatar: client.avatarUrl,
          rating: client.rating,
          missionsCount: client.missionsCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Avatar + nom + avis ───
          GestureDetector(
            onTap: canViewProfile ? () => _goToProfile(context) : null,
            child: Row(
              children: [
                UserAvatar(imageUrl: client.avatarUrl, radius: 28, showVerified: client.isVerified),
                AppGap.w14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      AppGap.h4,
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: AppColors.amber),
                          AppGap.w4,
                          Text(
                            client.rating.toStringAsFixed(1),
                            style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                          ),
                          Text(
                            ' · ${client.missionsCount} mission${client.missionsCount > 1 ? 's' : ''}',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canViewProfile)
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textTertiary),
              ],
            ),
          ),

          // ─── Budget de la mission ───
          if (missionBudget != null) ...[
            AppGap.h16,
            AppSurfaceCard(
              padding: AppInsets.a14,
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesign.radius12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget de la mission',
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                  ),
                  Text(
                    missionBudget!,
                    style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: context.colors.primary),
                  ),
                ],
              ),
            ),
          ],

          // ─── Boutons de contact ───
          if (onMessage != null || onPhone != null) ...[
            AppGap.h16,
            Row(
              children: [
                if (onMessage != null)
                  Expanded(
                    child: AppButton(
                      label: 'Message',
                      icon: Icons.chat_rounded,
                      onPressed: onMessage,
                      variant: ButtonVariant.primary,
                    ),
                  ),
                if (onMessage != null && onPhone != null) AppGap.w10,
                if (onPhone != null)
                  Expanded(
                    child: AppButton(
                      label: 'Téléphone',
                      icon: Icons.phone_rounded,
                      onPressed: onPhone,
                      variant: ButtonVariant.outline,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ClientStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ClientStatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppSurfaceCard(
        padding: AppInsets.v12,
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
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

// ─── Formulaire de Candidature ────────────────────────────────────────────────

class ApplicationForm extends StatelessWidget {
  final BudgetInfo suggestedBudget;
  final TextEditingController? priceController;
  final TextEditingController? messageController;

  const ApplicationForm({
    super.key,
    required this.suggestedBudget,
    this.priceController,
    this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Titre ───
          Row(children: [
            Icon(Icons.send_rounded, size: 22, color: context.colors.primary),
            AppGap.w10,
            Text('Votre proposition', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ]),

          AppGap.h20,

          // ─── Tarif (obligatoire) ───
          Row(
            children: [
              Text('Votre tarif', style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              AppGap.w6,
              AppTagPill(
                label: 'Obligatoire',
                backgroundColor: context.colors.primary.withOpacity(0.12),
                foregroundColor: context.colors.primary,
                fontSize: AppFontSize.xs,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          AppGap.h8,
          TextFormField(
            controller: priceController,
            initialValue: priceController == null ? suggestedBudget.averageAmount.toInt().toString() : null,
            keyboardType: TextInputType.number,
            style: context.text.headlineSmall,
            decoration: AppInputDecorations.formField(
              context,
              hintText: suggestedBudget.averageAmount.toInt().toString(),
              hintStyle: context.text.headlineSmall?.copyWith(color: context.colors.border),
              prefixIcon: Icon(Icons.euro_rounded, color: context.colors.primary),
              fillColor: context.colors.primary.withValues(alpha: 0.04),
              contentPadding: AppInsets.h16v16,
              radius: AppDesign.radius10,
            ).copyWith(
              suffixText: '€',
              suffixStyle: context.text.titleMedium?.copyWith(color: context.colors.textSecondary),
              helperText: 'Budget suggéré par le client : ${suggestedBudget.displayText}',
              helperStyle: context.text.labelMedium?.copyWith(color: context.colors.textTertiary),
            ),
          ),

          AppGap.h20,
          Divider(height: 1, color: context.colors.divider),
          AppGap.h20,

          // ─── Message (optionnel) ───
          Row(
            children: [
              Text('Message au client', style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              AppGap.w6,
              AppTagPill(
                label: 'Optionnel',
                backgroundColor: context.colors.surfaceAlt,
                foregroundColor: context.colors.textTertiary,
                fontSize: AppFontSize.xs,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          AppGap.h8,
          TextFormField(
            controller: messageController,
            maxLines: 4,
            decoration: AppInputDecorations.formField(
              context,
              hintText: 'Présentez-vous et expliquez pourquoi vous êtes le bon choix...',
              hintStyle: context.text.bodySmall?.copyWith(color: context.colors.textHint),
              fillColor: context.colors.background,
              contentPadding: AppInsets.a14,
              radius: AppDesign.radius10,
            ),
          ),

          AppGap.h14,
          const TipBox(text: 'Conseil : Mentionnez votre expérience et votre disponibilité.'),
        ],
      ),
    );
  }
}

// ─── Tip Box ─────────────────────────────────────────────────────────────────

class TipBox extends StatelessWidget {
  final String text;
  final IconData icon;

  const TipBox({super.key, required this.text, this.icon = Icons.lightbulb_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return AppInfoBanner(
      icon: icon,
      message: text,
      color: AppColors.info,
    );
  }
}

// ─── Mission Filter Chip ──────────────────────────────────────────────────────

class MissionFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const MissionFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPillChip(
      label: label,
      icon: icon,
      selected: isSelected,
      onTap: onTap,
      selectedBackgroundColor: color.withOpacity(0.15),
      selectedForegroundColor: color,
      backgroundColor: context.colors.surfaceAlt,
      foregroundColor: context.colors.textSecondary,
      padding: AppInsets.h12v8,
      borderRadius: BorderRadius.circular(AppDesign.radius20),
    );
  }
}

// ─── Distance Badge ───────────────────────────────────────────────────────────

class DistanceBadge extends StatelessWidget {
  final String distance;
  final bool compact;

  const DistanceBadge({super.key, required this.distance, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_outlined, size: compact ? 14 : 16, color: context.colors.textTertiary),
        AppGap.w3,
        Text(
          distance,
          style: compact ? context.text.labelMedium : context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─── Mission Meta Row ─────────────────────────────────────────────────────────

class MissionMetaRow extends StatelessWidget {
  final int candidatesCount;
  final String postedAtText;

  const MissionMetaRow({super.key, required this.candidatesCount, required this.postedAtText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.people_outline_rounded, size: 16, color: context.colors.textHint),
        AppGap.w4,
        Text('$candidatesCount candidat${candidatesCount > 1 ? 's' : ''}', style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary)),
        const Spacer(),
        Icon(Icons.access_time_rounded, size: 16, color: context.colors.textHint),
        AppGap.w4,
        Text(postedAtText, style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary)),
      ],
    );
  }
}

// ─── Application Success Dialog ───────────────────────────────────────────────

Future<void> showApplicationSuccessDialog(
  BuildContext context, {
  required String clientName,
  required VoidCallback onContinue,
}) {
  return showAppSuccessDialog(
    context: context,
    title: 'Proposition envoyée !',
    message: 'Votre proposition a été envoyée à $clientName.',
    buttonLabel: 'Continuer',
    onPressed: onContinue,
  );
}
