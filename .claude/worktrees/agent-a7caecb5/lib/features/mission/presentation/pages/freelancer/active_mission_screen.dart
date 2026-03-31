import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../../../../features/notifications/notification_provider.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';
import '../shared/mission_map_page.dart';
import '../../widgets/freelancer/freelancer_widgets.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🚀 Inkern - ActiveMissionScreen (Freelancer)
/// Page dédiée aux missions confirmed / onTheWay / inProgress / completed
/// ═══════════════════════════════════════════════════════════════════════════

class ActiveMissionScreen extends StatefulWidget {
  final Mission mission;

  const ActiveMissionScreen({super.key, required this.mission});

  @override
  State<ActiveMissionScreen> createState() => _ActiveMissionScreenState();
}

class _ActiveMissionScreenState extends State<ActiveMissionScreen> {
  late Mission _mission;
  Timer? _timer;
  Timer? _autoStartTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    if (_mission.status == MissionStatus.inProgress) {
      _startTime = DateTime.now();
      _startTimer();
    } else if (_mission.status == MissionStatus.onTheWay) {
      _startCountdownTimer();
      _scheduleAutoStart();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoStartTimer?.cancel();
    super.dispose();
  }

  // ─── Timer compte à rebours (onTheWay) ────────────────────────────────────

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  /// Planifie le passage automatique à inProgress à l'heure planifiée.
  void _scheduleAutoStart() {
    _autoStartTimer?.cancel();
    final delay = _mission.scheduledStart.difference(DateTime.now());
    if (delay.isNegative || delay == Duration.zero) {
      // Heure déjà passée → démarre immédiatement
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mission.status == MissionStatus.onTheWay) {
          _updateStatus(MissionStatus.inProgress);
        }
      });
    } else {
      _autoStartTimer = Timer(delay, () {
        if (mounted && _mission.status == MissionStatus.onTheWay) {
          _updateStatus(MissionStatus.inProgress);
        }
      });
    }
  }

  // ─── Timer durée écoulée (inProgress) ─────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  String get _elapsedText {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }

  /// Compte à rebours avant l'heure planifiée.
  String get _countdownText {
    final diff = _mission.scheduledStart.difference(DateTime.now());
    if (diff.isNegative) return 'Démarrage imminent...';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  /// Heure planifiée formatée "14h00".
  String get _scheduledStartLabel {
    final s = _mission.scheduledStart;
    return '${s.hour.toString().padLeft(2, '0')}h${s.minute.toString().padLeft(2, '0')}';
  }

  void _updateStatus(MissionStatus newStatus) {
    context.read<MissionProvider>().updateMissionStatus(_mission.id, newStatus);
    final notifProvider = context.read<NotificationProvider>();

    final (title, body) = switch (newStatus) {
      MissionStatus.onTheWay => (
          'Prestataire en route',
          '${_mission.assignedPresta?.name ?? 'Votre prestataire'} est en route pour "${_mission.title}"',
        ),
      MissionStatus.inProgress => (
          'Mission démarrée',
          '"${_mission.title}" a démarré à $_scheduledStartLabel',
        ),
      MissionStatus.waitingPayment => (
          'Mission terminée',
          '"${_mission.title}" est marquée terminée — en attente de votre validation',
        ),
      _ => ('', ''),
    };

    if (title.isNotEmpty) {
      notifProvider.addNotification(AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotifType.mission,
        title: title,
        body: body,
        timeAgo: 'À l\'instant',
      ));
    }

    setState(() {
      _mission = _mission.copyWith(status: newStatus);
      if (newStatus == MissionStatus.onTheWay) {
        _timer?.cancel();
        _startCountdownTimer();
        _scheduleAutoStart();
      }
      if (newStatus == MissionStatus.inProgress) {
        _timer?.cancel();
        _autoStartTimer?.cancel();
        _startTime = DateTime.now();
        _elapsed = Duration.zero;
        _startTimer();
      }
      if (newStatus == MissionStatus.waitingPayment || newStatus == MissionStatus.completed) {
        _timer?.cancel();
        _autoStartTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync live depuis le provider → détecte si le client valide/ferme la mission
    final liveMissions = context.watch<MissionProvider>().freelancerMissions;
    final live = liveMissions.firstWhere((m) => m.id == widget.mission.id, orElse: () => _mission);
    if (live.status != _mission.status) {
      _mission = live;
      if (live.status == MissionStatus.waitingPayment || live.status == MissionStatus.closed) {
        _timer?.cancel();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mission.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            if (_mission.status == MissionStatus.inProgress)
              Text(
                _elapsedText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MissionStatusBadge(status: _mission.status, compact: true),
          ),
        ],
      ),
      body: Column(
        children: [
          StatusTimeline(status: _mission.status),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_mission.client != null) ClientSection(
                    client: _mission.client!,
                    canViewProfile: true,
                    onMessage: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatPage(
                        contactName: _mission.client!.name,
                        contactAvatar: _mission.client!.avatarUrl,
                        isVerified: _mission.client!.isVerified,
                        missionTitle: _mission.title,
                      ),
                    )),
                    onPhone: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Text('Appel vers ${_mission.client!.name}...'),
                      ]),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    )),
                  ),
                  _buildLocation(),
                  _buildMissionRecap(),
                  if (_mission.status == MissionStatus.completed || _mission.status == MissionStatus.waitingPayment) _buildCompletedBanner(),
                  if (_mission.status == MissionStatus.closed) _buildPaidBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── Localisation ──────────────────────────────────────────────────────────

  Widget _buildLocation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MissionMapPage(address: _mission.address)),
          ),
          child: Padding(
            padding: AppPadding.cardLarge,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.urgent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lieu d\'intervention', style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        _mission.address.fullAddress,
                        style: AppTextStyles.label.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.map_rounded, color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Récap mission ─────────────────────────────────────────────────────────

  Widget _buildMissionRecap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: AppPadding.cardLarge,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_mission.categoryIcon, size: 18, color: _mission.categoryColor),
            const SizedBox(width: 8),
            Text(_mission.categoryName, style: TextStyle(fontSize: 13, color: _mission.categoryColor, fontWeight: FontWeight.w600)),
            const Spacer(),
            BudgetBadge(budget: _mission.budget),
          ]),
          const SizedBox(height: 12),
          Text(_mission.description, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(children: [
            InfoChip(icon: Icons.calendar_today_rounded, text: _mission.formattedDate, compact: true),
            const SizedBox(width: 16),
            InfoChip(icon: Icons.schedule_rounded, text: _mission.timeSlot, compact: true),
          ]),
        ],
      ),
    );
  }

  // ─── Bannière "en attente de validation" (completed) ───────────────────────

  Widget _buildCompletedBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)!),
      ),
      child: Row(children: [
        Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'En attente de validation client · 48h',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning),
              ),
              const SizedBox(height: 4),
              Text(
                'Le client a 48h pour valider. Le paiement sera automatiquement libéré.',
                style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.4),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPaidBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paiement reçu !',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Le client a validé la mission. Le montant a été crédité sur votre compte.',
                style: TextStyle(fontSize: 12, color: AppColors.success, height: 1.4),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── Bottom Bar adaptatif ──────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final bottom = MediaQuery.of(context).padding.bottom;

    Widget child;
    switch (_mission.status) {
      case MissionStatus.confirmed:
        child = ElevatedButton.icon(
          onPressed: () => _updateStatus(MissionStatus.onTheWay),
          icon: const Icon(Icons.directions_car_rounded),
          label: const Text('Je suis en route'),
          style: _primaryBtnStyle(AppColors.primary),
        );
        break;
      case MissionStatus.onTheWay:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text('En route vers le client...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule_rounded, color: Color(0xFF16A34A), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Mission démarre automatiquement à $_scheduledStartLabel',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _countdownText,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case MissionStatus.inProgress:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Durée écoulée : $_elapsedText', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(MissionStatus.waitingPayment),
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('Terminer la mission'),
                style: _primaryBtnStyle(AppColors.urgent),
              ),
            ),
          ],
        );
        break;
      case MissionStatus.completed:
      case MissionStatus.waitingPayment:
        child = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'En attente de validation client · 48h',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning),
              ),
            ],
          ),
        );
        break;
      case MissionStatus.closed:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: child,
    );
  }

  ButtonStyle _primaryBtnStyle(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    minimumSize: const Size(double.infinity, 0),
  );
}
