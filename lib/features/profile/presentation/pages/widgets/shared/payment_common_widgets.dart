import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Composants partagés — Paiements (Client & Freelancer)
// ═══════════════════════════════════════════════════════════════════════════

// ─── Champ avec ombre ────────────────────────────────────────────────────────

class PaymentShadowField extends StatelessWidget {
  final Widget child;
  const PaymentShadowField({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppPaymentMetrics.shadowBlurRadius,
            offset: const Offset(0, AppPaymentMetrics.shadowOffsetY),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Bouton "Ajouter" unifié ──────────────────────────────────────────────────

class PaymentAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PaymentAddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppPaymentMetrics.addButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: AppPaymentMetrics.commonIconSize,
              color: context.colors.textSecondary,
            ),
            AppGap.w8,
            Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Titre de section (small caps) ───────────────────────────────────────────

class PaymentSectionLabel extends StatelessWidget {
  final String label;
  const PaymentSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.text.labelSmall?.copyWith(
        color: context.colors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
      ),
    );
  }
}

// ─── Note d'information sobre ─────────────────────────────────────────────────

class PaymentInfoNote extends StatelessWidget {
  final IconData icon;
  final String body;
  final String? title;

  const PaymentInfoNote({
    super.key,
    required this.icon,
    required this.body,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a14,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppPaymentMetrics.infoIconSize,
            color: context.colors.textTertiary,
          ),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h3,
                ],
                Text(
                  body,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet confirmation suppression ──────────────────────────────────────────

class PaymentDeleteConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onConfirm;

  const PaymentDeleteConfirmSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      title: title,
      footer: Column(
        children: [
          AppButton(
            label: 'Supprimer',
            variant: ButtonVariant.destructive,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
          AppGap.h12,
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppPaymentMetrics.deleteSheetIconWrapSize,
              height: AppPaymentMetrics.deleteSheetIconWrapSize,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: AppPaymentMetrics.deleteSheetIconSize,
              ),
            ),
          ),
          AppGap.h14,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile de transaction (partagée historique client & freelancer) ───────────

class PaymentTxTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const PaymentTxTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: AppInsets.h16v14,
        child: Row(
          children: [
            // ─── Icône ───
            Container(
              width: AppPaymentMetrics.txLeadingBoxSize,
              height: AppPaymentMetrics.txLeadingBoxSize,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppPaymentMetrics.txLeadingRadius),
              ),
              child: Icon(
                icon,
                size: AppPaymentMetrics.commonIconSize,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.w14,
            // ─── Titre + sous-titre ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppGap.w12,
            // ─── Montant + badge ───
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPositive
                        ? AppColors.primary
                        : context.colors.textPrimary,
                  ),
                ),
                if (badge != null) ...[
                  AppGap.h3,
                  Text(
                    badge!,
                    style: context.text.labelSmall?.copyWith(
                      color: badgeColor ?? context.colors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pills de filtre (Tout / Revenus / ...) ───────────────────────────────────

class PaymentFilterPills extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  const PaymentFilterPills({
    super.key,
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppPaymentMetrics.filterPillHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.h16,
        itemCount: filters.length,
        separatorBuilder: (_, __) => AppGap.w8,
        itemBuilder: (context, i) {
          final f = filters[i];
          final active = f == selected;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: AppPaymentMetrics.filterAnimationMs,
              ),
              padding: AppInsets.h16,
              decoration: BoxDecoration(
                color: active
                    ? context.colors.textPrimary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: active
                      ? context.colors.textPrimary
                      : context.colors.border,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                f,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active
                      ? context.colors.background
                      : context.colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum PaymentMissionPipelineStage { secured, waiting24h, paid, dispute }

class PaymentMissionPipelineInline extends StatelessWidget {
  final PaymentMissionPipelineStage stage;
  final String? caption;

  const PaymentMissionPipelineInline({
    super.key,
    required this.stage,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = switch (stage) {
      PaymentMissionPipelineStage.secured => 0,
      PaymentMissionPipelineStage.waiting24h => 1,
      PaymentMissionPipelineStage.paid => 2,
      PaymentMissionPipelineStage.dispute => 1,
    };
    final accent = stage == PaymentMissionPipelineStage.dispute
        ? context.colors.error
        : context.colors.primary;
    final text = caption ?? _defaultCaption(stage);

    return Container(
      width: double.infinity,
      padding: AppInsets.h10v8,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PipelineDot(
                active: currentStep >= 0,
                done: currentStep > 0,
                accent: accent,
              ),
              _PipelineConnector(done: currentStep > 0, accent: accent),
              _PipelineDot(
                active: currentStep >= 1,
                done: currentStep > 1,
                accent: accent,
              ),
              _PipelineConnector(done: currentStep > 1, accent: accent),
              _PipelineDot(
                active: currentStep >= 2,
                done: false,
                accent: accent,
              ),
            ],
          ),
          AppGap.h4,
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  String _defaultCaption(PaymentMissionPipelineStage stage) {
    return switch (stage) {
      PaymentMissionPipelineStage.secured => 'Paiement securise',
      PaymentMissionPipelineStage.waiting24h =>
        'Versement automatique sous 24h',
      PaymentMissionPipelineStage.paid => 'Paiement verse',
      PaymentMissionPipelineStage.dispute => 'Litige ouvert, versement bloque',
    };
  }
}

class _PipelineDot extends StatelessWidget {
  final bool active;
  final bool done;
  final Color accent;

  const _PipelineDot({
    required this.active,
    required this.done,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: AppPaymentMetrics.pipelineDotSize,
        height: AppPaymentMetrics.pipelineDotSize,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
        ),
      );
    }
    if (active) {
      return Container(
        width: AppPaymentMetrics.pipelineDotSize,
        height: AppPaymentMetrics.pipelineDotSize,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 1.3),
        ),
      );
    }
    return Container(
      width: AppPaymentMetrics.pipelineDotSize,
      height: AppPaymentMetrics.pipelineDotSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.border, width: 1.2),
      ),
    );
  }
}

class _PipelineConnector extends StatelessWidget {
  final bool done;
  final Color accent;

  const _PipelineConnector({required this.done, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: AppPaymentMetrics.pipelineConnectorHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: AppPaymentMetrics.pipelineConnectorMargin,
        ),
        decoration: BoxDecoration(
          color: done ? accent.withValues(alpha: 0.7) : context.colors.border,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}
