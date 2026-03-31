import 'package:flutter/material.dart';

import '../../../data/models/mission.dart';
import '../../../theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📊 Inkern - Status Timeline Widget
/// Timeline horizontale scrollable montrant la progression de la mission.
/// ═══════════════════════════════════════════════════════════════════════════

// Étapes linéaires de la timeline (hors statuts spéciaux)
const _kTimelineSteps = [
  MissionStatus.waitingCandidates,
  MissionStatus.candidateReceived,
  MissionStatus.confirmed,
  MissionStatus.onTheWay,
  MissionStatus.inProgress,
  MissionStatus.completed,
  MissionStatus.waitingPayment,
  MissionStatus.closed,
];

const _kSpecialStatuses = {
  MissionStatus.cancelled,
  MissionStatus.dispute,
  MissionStatus.expired,
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

// ─── Bannière pour statuts spéciaux ──────────────────────────────────────────

class _SpecialStatusBanner extends StatelessWidget {
  final MissionStatus status;
  const _SpecialStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (status) {
      MissionStatus.cancelled => (AppColors.error.withOpacity(0.08)!, AppColors.error.withOpacity(0.3)!, AppColors.error!),
      MissionStatus.dispute   => (AppColors.warning.withOpacity(0.08)!, AppColors.warning.withOpacity(0.3)!, AppColors.warning!),
      _                       => (AppColors.background!, AppColors.divider, AppColors.textSecondary!),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Icon(status.icon, color: status.color, size: 22),
        const SizedBox(width: 12),
        Text(
          status.label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg),
        ),
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_kTimelineSteps.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Connecteur
              final stepIndex = i ~/ 2;
              final isDone = stepIndex < currentIdx;
              return _Connector(done: isDone);
            }
            final stepIndex = i ~/ 2;
            final isDone = stepIndex < currentIdx;
            final isCurrent = stepIndex == currentIdx;
            final step = _kTimelineSteps[stepIndex];
            return _TimelineStep(
              status: step,
              isDone: isDone,
              isCurrent: isCurrent,
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
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isCurrent) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _shortLabel(widget.status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isCurrent
            ? AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Transform.scale(
                  scale: _anim.value,
                  child: _circle(widget.status, widget.isDone, widget.isCurrent),
                ),
              )
            : _circle(widget.status, widget.isDone, widget.isCurrent),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: widget.isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: widget.isCurrent
                  ? AppColors.primary
                  : widget.isDone
                      ? AppColors.textSecondary
                      : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _circle(MissionStatus status, bool done, bool current) {
    if (done) {
      return Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }
    if (current) {
      return Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(status.icon, color: Colors.white, size: 15),
      );
    }
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Icon(status.icon, color: AppColors.border, size: 14),
    );
  }

  String _shortLabel(MissionStatus s) => switch (s) {
    MissionStatus.waitingCandidates => 'Publiée',
    MissionStatus.candidateReceived => 'Candidature',
    MissionStatus.confirmed        => 'Confirmée',
    MissionStatus.onTheWay         => 'En route',
    MissionStatus.inProgress       => 'En cours',
    MissionStatus.completed        => 'Terminée',
    MissionStatus.waitingPayment   => 'Validation',
    MissionStatus.closed           => 'Payée',
    _                              => s.label,
  };
}

// ─── Connecteur horizontal ────────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  final bool done;
  const _Connector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: done ? AppColors.primary : AppColors.border,
    );
  }
}
