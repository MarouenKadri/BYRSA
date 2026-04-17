import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📊 Inkern - Status Timeline Widget — dark theme
/// ═══════════════════════════════════════════════════════════════════════════

const _kTeal = AppColors.primary;

const _kTimelineSteps = [
  MissionStatus.waitingCandidates,
  MissionStatus.candidateReceived,
  MissionStatus.prestaChosen,
  MissionStatus.confirmed,
  MissionStatus.onTheWay,
  MissionStatus.inProgress,
  MissionStatus.completionRequested,
  MissionStatus.completed,
  MissionStatus.paymentHeld,
  MissionStatus.awaitingRelease,
  MissionStatus.closed,
];

const _kSpecialStatuses = {
  MissionStatus.cancelled,
  MissionStatus.inDispute,
  MissionStatus.expired,
  MissionStatus.draft,
};

class StatusTimeline extends StatelessWidget {
  final MissionStatus status;
  const StatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (_kSpecialStatuses.contains(status)) {
      return _SpecialStatusBanner(status: status);
    }
    return _TimelineTrack(currentStatus: status);
  }
}

// ─── Bannière statuts spéciaux ────────────────────────────────────────────────

class _SpecialStatusBanner extends StatelessWidget {
  final MissionStatus status;
  const _SpecialStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MissionStatus.cancelled  => AppColors.error,
      MissionStatus.inDispute  => AppColors.error,
      _                        => context.colors.textTertiary,
    };

    return Container(
      padding: AppInsets.h16v12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(status.icon, color: color, size: 20),
        AppGap.w12,
        Text(status.label, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ─── Track de la timeline ─────────────────────────────────────────────────────

class _TimelineTrack extends StatelessWidget {
  final MissionStatus currentStatus;
  const _TimelineTrack({required this.currentStatus});

  int get _currentIndex {
    final idx = _kTimelineSteps.indexOf(currentStatus);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius14),
        border: Border.all(color: context.colors.divider),
      ),
      padding: AppInsets.v14,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.h16,
        child: Row(
          children: List.generate(_kTimelineSteps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              final isDone = stepIndex < currentIdx;
              return _Connector(done: isDone);
            }
            final stepIndex = i ~/ 2;
            return _TimelineStep(
              status: _kTimelineSteps[stepIndex],
              isDone: stepIndex < currentIdx,
              isCurrent: stepIndex == currentIdx,
            );
          }),
        ),
      ),
    );
  }
}

// ─── Étape individuelle ───────────────────────────────────────────────────────

class _TimelineStep extends StatefulWidget {
  final MissionStatus status;
  final bool isDone;
  final bool isCurrent;
  const _TimelineStep({required this.status, required this.isDone, required this.isCurrent});

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isCurrent) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _TimelineStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _ctrl.repeat(reverse: true);
      return;
    }
    if (!widget.isCurrent && oldWidget.isCurrent) {
      _ctrl
        ..stop()
        ..value = 1.0;
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isCurrent
            ? AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Transform.scale(scale: _anim.value, child: _buildCircle()),
              )
            : _buildCircle(),
        AppGap.h6,
        SizedBox(
          width: 52,
          child: Text(
            _shortLabel(widget.status),
            style: context.text.labelSmall?.copyWith(
              fontSize: AppFontSize.micro,
              fontWeight: widget.isCurrent ? FontWeight.w700 : null,
              color: widget.isCurrent ? _kTeal : widget.isDone ? Colors.white60 : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    if (widget.isDone) {
      return Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: _kTeal.withValues(alpha: 0.15), shape: BoxShape.circle,
            border: Border.all(color: _kTeal, width: 1.5)),
        child: const Icon(Icons.check_rounded, color: _kTeal, size: 16),
      );
    }
    if (widget.isCurrent) {
      return Container(
        width: 30, height: 30,
        decoration: const BoxDecoration(color: _kTeal, shape: BoxShape.circle),
        child: Icon(widget.status.icon, color: Colors.black, size: 15),
      );
    }
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.background,
        border: Border.all(color: context.colors.divider, width: 1.5),
      ),
      child: Icon(widget.status.icon, color: context.colors.textTertiary, size: 14),
    );
  }

  String _shortLabel(MissionStatus s) => switch (s) {
    MissionStatus.waitingCandidates => 'Publiée',
    MissionStatus.candidateReceived => 'Candidats',
    MissionStatus.prestaChosen      => 'Sélection',
    MissionStatus.confirmed         => 'Confirmée',
    MissionStatus.onTheWay          => 'En route',
    MissionStatus.inProgress        => 'En cours',
    MissionStatus.completionRequested => 'Validation',
    MissionStatus.completed         => 'Terminée',
    MissionStatus.paymentHeld       => 'Sécurisé',
    MissionStatus.awaitingRelease   => 'Sous 24h',
    MissionStatus.closed            => 'Payée',
    _                               => s.label,
  };
}

// ─── Connecteur horizontal ────────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  final bool done;
  const _Connector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 1.5,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: done ? _kTeal : context.colors.divider,
        borderRadius: BorderRadius.circular(AppRadius.micro),
      ),
    );
  }
}
