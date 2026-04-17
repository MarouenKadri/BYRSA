import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import 'mission_status_ui.dart';

enum MissionFinanceState {
  pending,
  secured,
  awaitingRelease24h,
  paidOut,
  disputeHold,
  refund100,
  refund50,
}

class _FinancePipelineConfig {
  final List<String> labels;
  final List<IconData> icons;
  final int activeStep;

  const _FinancePipelineConfig({
    required this.labels,
    required this.icons,
    required this.activeStep,
  });
}

class MissionFinanceUi {
  static const Set<MissionStatus> _paymentLinkedStatuses = {
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completionRequested,
    MissionStatus.completed,
    MissionStatus.paymentHeld,
    MissionStatus.awaitingRelease,
    MissionStatus.closed,
    MissionStatus.inDispute,
  };

  static bool isPaymentLinkedMission(Mission mission) {
    if (_paymentLinkedStatuses.contains(mission.status)) return true;
    if (mission.status == MissionStatus.cancelled) {
      // Annulation après réservation/presta assigné => logique de remboursement.
      return mission.assignedPresta != null;
    }
    return false;
  }

  static MissionFinanceState resolveState(
    Mission mission, {
    DateTime? now,
  }) {
    switch (mission.status) {
      case MissionStatus.draft:
      case MissionStatus.waitingCandidates:
      case MissionStatus.candidateReceived:
      case MissionStatus.prestaChosen:
      case MissionStatus.expired:
        return MissionFinanceState.pending;
      case MissionStatus.confirmed:
      case MissionStatus.onTheWay:
      case MissionStatus.inProgress:
      case MissionStatus.completionRequested:
      case MissionStatus.completed:
      case MissionStatus.paymentHeld:
        return MissionFinanceState.secured;
      case MissionStatus.awaitingRelease:
        return MissionFinanceState.awaitingRelease24h;
      case MissionStatus.closed:
        return MissionFinanceState.paidOut;
      case MissionStatus.inDispute:
        return MissionFinanceState.disputeHold;
      case MissionStatus.cancelled:
        if (!isPaymentLinkedMission(mission)) {
          return MissionFinanceState.pending;
        }
        return _cancelRefundState(mission, now: now);
    }
  }

  static MissionFinanceState _cancelRefundState(
    Mission mission, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final startsIn = mission.scheduledStart.difference(ref);
    final isMoreThan24h = startsIn.inMinutes >= 24 * 60;
    return isMoreThan24h
        ? MissionFinanceState.refund100
        : MissionFinanceState.refund50;
  }

  static bool isRefund(MissionFinanceState state) {
    return state == MissionFinanceState.refund100 ||
        state == MissionFinanceState.refund50;
  }

  static _FinancePipelineConfig pipeline({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    if (role == MissionUiRole.client) {
      final activeStep = switch (state) {
        MissionFinanceState.pending => -1,
        _ => 0,
      };
      return _FinancePipelineConfig(
        labels: const ['Paye'],
        icons: const [Icons.payments_rounded],
        activeStep: activeStep,
      );
    }

    final activeStep = switch (state) {
      MissionFinanceState.pending => -1,
      MissionFinanceState.awaitingRelease24h => 1,
      MissionFinanceState.paidOut => 2,
      MissionFinanceState.disputeHold => 1,
      _ => 0,
    };

    return _FinancePipelineConfig(
      labels: [
        'Fonds bloques',
        'Versement 24h',
      ],
      icons: const [
        Icons.lock_rounded,
        Icons.schedule_rounded,
      ],
      activeStep: activeStep,
    );
  }

  static Color accentColor(BuildContext context, MissionFinanceState state) {
    return switch (state) {
      MissionFinanceState.pending => context.colors.textTertiary,
      MissionFinanceState.secured => AppColors.primary,
      MissionFinanceState.awaitingRelease24h => AppColors.warning,
      MissionFinanceState.paidOut => AppColors.primary,
      MissionFinanceState.disputeHold => context.colors.error,
      MissionFinanceState.refund100 => AppColors.info,
      MissionFinanceState.refund50 => AppColors.warning,
    };
  }

  static IconData stateIcon(MissionFinanceState state) {
    return switch (state) {
      MissionFinanceState.pending => Icons.hourglass_bottom_rounded,
      MissionFinanceState.secured => Icons.lock_rounded,
      MissionFinanceState.awaitingRelease24h => Icons.schedule_rounded,
      MissionFinanceState.paidOut => Icons.check_circle_rounded,
      MissionFinanceState.disputeHold => Icons.flag_rounded,
      MissionFinanceState.refund100 || MissionFinanceState.refund50 =>
        Icons.replay_rounded,
    };
  }

  static String outsideLabel({
    required Mission mission,
    required MissionUiRole role,
    DateTime? now,
  }) {
    final state = resolveState(mission, now: now);

    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending => 'Attente paiement',
        MissionFinanceState.secured => 'Paye',
        MissionFinanceState.awaitingRelease24h => 'Paye',
        MissionFinanceState.paidOut => 'Paye',
        MissionFinanceState.disputeHold => 'Litige',
        MissionFinanceState.refund100 => 'Remboursement 100%',
        MissionFinanceState.refund50 => 'Remboursement 50%',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending => 'Attente paiement',
        MissionFinanceState.secured => 'Fonds bloques',
        MissionFinanceState.awaitingRelease24h => 'Versement 24h',
        MissionFinanceState.paidOut => 'Recu',
        MissionFinanceState.disputeHold => 'Litige',
        MissionFinanceState.refund100 || MissionFinanceState.refund50 =>
          'Mission annulee',
      },
    };
  }

  static String detailTitle({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending => 'Attente paiement',
        MissionFinanceState.secured => 'Paye',
        MissionFinanceState.awaitingRelease24h => 'Paye',
        MissionFinanceState.paidOut => 'Paye',
        MissionFinanceState.disputeHold => 'Litige',
        MissionFinanceState.refund100 => 'Remboursement integral',
        MissionFinanceState.refund50 => 'Remboursement partiel',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending => 'Attente paiement',
        MissionFinanceState.secured => 'Fonds bloques',
        MissionFinanceState.awaitingRelease24h => 'Versement 24h',
        MissionFinanceState.paidOut => 'Recu',
        MissionFinanceState.disputeHold => 'Litige',
        MissionFinanceState.refund100 || MissionFinanceState.refund50 =>
          'Mission annulee',
      },
    };
  }

  static String detailSubtitle({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending =>
          'Vous payez uniquement lorsque la mission est terminee et validee.',
        MissionFinanceState.secured =>
          'Le montant est preleve et conserve de maniere securisee.',
        MissionFinanceState.awaitingRelease24h =>
          'Le freelancer sera verse automatiquement apres 24h sans litige.',
        MissionFinanceState.paidOut =>
          'Le paiement a ete envoye au freelancer.',
        MissionFinanceState.disputeHold =>
          'L argent reste bloque jusqu a resolution du probleme.',
        MissionFinanceState.refund100 =>
          'Annulation plus de 24h avant la mission: remboursement 100%.',
        MissionFinanceState.refund50 =>
          'Annulation a moins de 24h ou le jour J: remboursement 50%.',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending =>
          'Le client n a pas encore valide et regle la mission.',
        MissionFinanceState.secured =>
          'Les fonds sont bloques, ils sont bien reserves pour vous.',
        MissionFinanceState.awaitingRelease24h =>
          'Le versement arrive automatiquement sous 24 heures sans litige.',
        MissionFinanceState.paidOut =>
          'Le versement est effectue sur votre portefeuille.',
        MissionFinanceState.disputeHold =>
          'Le versement est suspendu le temps de traiter le litige.',
        MissionFinanceState.refund100 || MissionFinanceState.refund50 =>
          'Mission annulee: aucun versement pour cette mission.',
      },
    };
  }

  static String amountLine({
    required Mission mission,
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    final total = mission.budget.averageAmount;
    final freelancerPayout = total * 0.9;

    if (role == MissionUiRole.client) {
      if (state == MissionFinanceState.pending) {
        return 'Montant a payer: ${_euro(total)}';
      }
      if (state == MissionFinanceState.refund100) {
        return 'Remboursement estime: ${_euro(total)}';
      }
      if (state == MissionFinanceState.refund50) {
        return 'Remboursement estime: ${_euro(total * 0.5)}';
      }
      return 'Montant paye: ${_euro(total)}';
    }

    if (state == MissionFinanceState.pending) {
      return 'Montant potentiel: ${_euro(freelancerPayout)}';
    }
    if (state == MissionFinanceState.paidOut) {
      return 'Montant recu: ${_euro(freelancerPayout)}';
    }
    if (isRefund(state)) {
      return 'Montant a recevoir: 0 €';
    }
    return 'Montant a recevoir: ${_euro(freelancerPayout)}';
  }

  static String _euro(double value) {
    final rounded = value.roundToDouble();
    if (rounded == value) return '${rounded.toInt()} €';
    return '${value.toStringAsFixed(2)} €';
  }
}

class MissionFinanceStatusBadge extends StatelessWidget {
  final Mission mission;
  final MissionUiRole role;

  const MissionFinanceStatusBadge({
    super.key,
    required this.mission,
    required this.role,
  });

  static bool shouldDisplay(Mission mission) {
    return MissionFinanceUi.isPaymentLinkedMission(mission);
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionFinanceUi.resolveState(mission);
    final accent = MissionFinanceUi.accentColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MissionFinanceUi.stateIcon(state), size: 13, color: accent),
          const SizedBox(width: 6),
          Text(
            MissionFinanceUi.outsideLabel(mission: mission, role: role),
            style: context.text.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionFinanceExposureCard extends StatelessWidget {
  final Mission mission;
  final MissionUiRole role;

  const MissionFinanceExposureCard({
    super.key,
    required this.mission,
    required this.role,
  });

  static bool shouldDisplay(Mission mission) {
    return MissionFinanceUi.isPaymentLinkedMission(mission);
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionFinanceUi.resolveState(mission);
    final accent = MissionFinanceUi.accentColor(context, state);
    final statusLabel = MissionFinanceUi.outsideLabel(mission: mission, role: role);
    final pipeline = MissionFinanceUi.pipeline(state: state, role: role);
    final stepIndex = pipeline.activeStep;
    final labels = pipeline.labels;
    final icons = pipeline.icons;
    final allStepsDone = stepIndex >= labels.length;
    final highlightedLabelIndex = allStepsDone
        ? labels.length - 1
        : stepIndex;
    final hasHighlightedLabel = highlightedLabelIndex >= 0;
    final title = MissionFinanceUi.detailTitle(state: state, role: role);
    final subtitle = MissionFinanceUi.detailSubtitle(state: state, role: role);
    final amountLine = MissionFinanceUi.amountLine(
      mission: mission,
      state: state,
      role: role,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MissionFinanceUi.stateIcon(state),
                  size: 13,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Suivi paiement',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.24)),
                ),
                child: Text(
                  statusLabel,
                  style: context.text.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPipelineTrack(
            labels: labels,
            icons: icons,
            activeStep: stepIndex,
            accent: accent,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              for (int i = 0; i < labels.length; i++)
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall?.copyWith(
                      fontSize: 10.5,
                      fontWeight: hasHighlightedLabel && i == highlightedLabelIndex
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: hasHighlightedLabel && i <= highlightedLabelIndex
                          ? context.colors.textPrimary
                          : context.colors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountLine,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineTrack({
    required List<String> labels,
    required List<IconData> icons,
    required int activeStep,
    required Color accent,
  }) {
    if (labels.length <= 1) {
      return Center(
        child: _FinanceStepNode(
          index: 0,
          icon: icons.isNotEmpty ? icons.first : Icons.payments_rounded,
          activeStep: activeStep,
          accent: accent,
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          _FinanceStepNode(
            index: i,
            icon: i < icons.length ? icons[i] : Icons.circle_rounded,
            activeStep: activeStep,
            accent: accent,
          ),
          if (i < labels.length - 1)
            _FinanceLine(done: i < activeStep, accent: accent),
        ],
      ],
    );
  }
}

class _FinanceStepNode extends StatelessWidget {
  final int index;
  final IconData icon;
  final int activeStep;
  final Color accent;

  const _FinanceStepNode({
    required this.index,
    required this.icon,
    required this.activeStep,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final done = index < activeStep;
    final active = index == activeStep;

    if (done) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 11, color: Colors.white),
      );
    }

    if (active) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 1.1),
        ),
        child: Icon(icon, size: 11, color: accent),
      );
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD7DEE7), width: 1.1),
      ),
      child: Icon(icon, size: 11, color: const Color(0xFFB5C0CD)),
    );
  }
}

class _FinanceLine extends StatelessWidget {
  final bool done;
  final Color accent;

  const _FinanceLine({required this.done, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.6,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: done ? accent.withValues(alpha: 0.72) : const Color(0xFFD7DEE7),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
