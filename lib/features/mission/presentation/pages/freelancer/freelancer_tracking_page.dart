import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';
import '../../../../../features/notifications/notification_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🗺️ FreelancerTrackingPage
/// Cockpit dédié au trajet et au démarrage sécurisé par code client.
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerTrackingPage extends StatefulWidget {
  final Mission mission;

  const FreelancerTrackingPage({super.key, required this.mission});

  @override
  State<FreelancerTrackingPage> createState() => _FreelancerTrackingPageState();
}

class _FreelancerTrackingPageState extends State<FreelancerTrackingPage>
    with TickerProviderStateMixin {
  late Mission _mission;
  late AnimationController _moveController;
  late Animation<Offset> _moveAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Timer? _etaTimer;
  int _etaMinutes = 8;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _moveAnim = Tween<Offset>(
      begin: const Offset(0.2, 0.65),
      end: const Offset(0.55, 0.35),
    ).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      if (_etaMinutes > 1 && _mission.status == MissionStatus.onTheWay) {
        setState(() => _etaMinutes--);
      }
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _pulseController.dispose();
    _etaTimer?.cancel();
    super.dispose();
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
          'Mission demarree',
          '"${_mission.title}" est maintenant en cours',
        ),
      MissionStatus.completionRequested => (
          'Fin de mission signalee',
          '"${_mission.title}" attend maintenant la reponse du client',
        ),
      _ => ('', ''),
    };

    if (title.isNotEmpty) {
      notifProvider.addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotifType.mission,
          title: title,
          body: body,
          timeAgo: 'A l\'instant',
        ),
      );
    }

    setState(() {
      _mission = _mission.copyWith(status: newStatus);
      if (newStatus == MissionStatus.onTheWay) {
        _etaMinutes = 8;
      }
    });
  }

  Future<void> _openStartCodeSheet() async {
    await showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      isScrollControlled: true,
      child: _StartCodeSheet(
        missionTitle: _mission.title,
        onSubmit: (code) async {
          final ok = await context.read<MissionProvider>().unlockMissionStart(
                _mission.id,
                code,
              );
          if (!mounted) return ok;
          if (ok) {
            showAppSnackBar(
              context,
              'Code valide. Mission demarree.',
              icon: Icons.check_circle_rounded,
            );
          }
          return ok;
        },
      ),
    );
  }

  String get _title => switch (_mission.status) {
        MissionStatus.confirmed => 'Pret pour le code de demarrage',
        MissionStatus.onTheWay => 'Vous etes en route',
        MissionStatus.inProgress => 'Mission en cours',
        MissionStatus.completionRequested => 'Fin signalee au client',
        MissionStatus.waitingPayment => 'Mission terminee',
        _ => 'Suivi de mission',
      };

  @override
  Widget build(BuildContext context) {
    final liveMissions = context.watch<MissionProvider>().freelancerMissions;
    final live = liveMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => _mission,
    );
    if (live.status != _mission.status) {
      _mission = live;
    }

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          _FreelancerMockMap(
            moveAnim: _moveAnim,
            pulseAnim: _pulseAnim,
            isMoving: _mission.status == MissionStatus.onTheWay,
          ),
          Positioned(
            top: topPadding + 4,
            left: 4,
            child: Padding(
              padding: AppInsets.a8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDesign.radiusFull),
                  onTap: () => Navigator.pop(context),
                  child: AppIconCircle(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 42,
                    iconSize: 18,
                    backgroundColor: context.colors.surface,
                    iconColor: context.colors.textPrimary,
                    boxShadow: AppShadows.button,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 0,
            right: 0,
            child: Center(
              child: AppSurfaceCard(
                padding: AppInsets.h16v8,
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
                boxShadow: AppShadows.card,
                child: Text(
                  _title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          AppScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.24,
            maxChildSize: 0.68,
            builder: (_, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              children: [
                _FreelancerTrackingPanel(
                  mission: _mission,
                  etaMinutes: _etaMinutes,
                  onStartRoute: _mission.status == MissionStatus.confirmed
                      ? () => _updateStatus(MissionStatus.onTheWay)
                      : null,
                  onEnterStartCode:
                      _mission.status == MissionStatus.confirmed ||
                              _mission.status == MissionStatus.onTheWay
                          ? _openStartCodeSheet
                          : null,
                  startCodeHint: _mission.startCode,
                  onCopyHint: _mission.startCode == null
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: _mission.startCode!),
                          );
                          if (context.mounted) {
                            showAppSnackBar(
                              context,
                              'Code copie pour test local',
                              icon: Icons.copy_rounded,
                            );
                          }
                        },
                  onFinishMission: _mission.status == MissionStatus.inProgress
                      ? () => _updateStatus(MissionStatus.completionRequested)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCodeSheet extends StatefulWidget {
  final String missionTitle;
  final Future<bool> Function(String code) onSubmit;

  const _StartCodeSheet({
    required this.missionTitle,
    required this.onSubmit,
  });

  @override
  State<_StartCodeSheet> createState() => _StartCodeSheetState();
}

class _StartCodeSheetState extends State<_StartCodeSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Entrez un code a 6 chiffres.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await widget.onSubmit(code);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _loading = false;
      _error = 'Code invalide. Verifiez avec le client.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: AppFormSheet(
        title: 'Entrer le code client',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demandez au client le code de demarrage pour lancer "${widget.missionTitle}".',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.45,
              ),
            ),
            AppGap.h18,
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
              ),
              decoration: AppInputDecorations.formField(
                context,
                hintText: '000000',
                errorText: _error,
              ),
            ),
          ],
        ),
        footer: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _verify,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verifier le code'),
          ),
        ),
      ),
    );
  }
}

class _FreelancerMockMap extends StatelessWidget {
  final Animation<Offset> moveAnim;
  final Animation<double> pulseAnim;
  final bool isMoving;

  const _FreelancerMockMap({
    required this.moveAnim,
    required this.pulseAnim,
    required this.isMoving,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mapGradientStart, AppColors.mapGradientEnd],
              ),
            ),
          ),
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _FreelancerGridPainter(),
          ),
          Positioned(
            left: size.width * 0.55 - 18,
            top: size.height * 0.35 - 40,
            child: const _TrackingDestinationPin(),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([moveAnim, pulseAnim]),
            builder: (_, __) {
              final dx = isMoving ? moveAnim.value.dx : 0.55;
              final dy = isMoving ? moveAnim.value.dy : 0.35;
              return Positioned(
                left: dx * size.width - 12,
                top: dy * size.height - 12,
                child: Transform.scale(
                  scale: isMoving ? pulseAnim.value : 1.0,
                  child: const _TrackingFreelancerDot(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FreelancerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final streetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.2, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TrackingDestinationPin extends StatelessWidget {
  const _TrackingDestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: AppInsets.a8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
        ),
        Container(width: 2, height: 12, color: AppColors.primary),
      ],
    );
  }
}

class _TrackingFreelancerDot extends StatelessWidget {
  const _TrackingFreelancerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.iosBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.iosBlue.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _FreelancerTrackingPanel extends StatelessWidget {
  final Mission mission;
  final int etaMinutes;
  final VoidCallback? onStartRoute;
  final VoidCallback? onEnterStartCode;
  final VoidCallback? onFinishMission;
  final String? startCodeHint;
  final VoidCallback? onCopyHint;

  const _FreelancerTrackingPanel({
    required this.mission,
    required this.etaMinutes,
    this.onStartRoute,
    this.onEnterStartCode,
    this.onFinishMission,
    this.startCodeHint,
    this.onCopyHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: mission.status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                mission.status.icon,
                color: mission.status.color,
                size: 28,
              ),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      MissionStatusBadge(status: mission.status, compact: true),
                      if (mission.status == MissionStatus.onTheWay) ...[
                        AppGap.w10,
                        Text(
                          '~$etaMinutes min',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        AppGap.h18,
        AppSurfaceCard(
          padding: AppInsets.a14,
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(AppDesign.radius14),
          child: Row(
            children: [
              Icon(
                mission.status == MissionStatus.inProgress
                    ? Icons.handyman_rounded
                    : Icons.password_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              AppGap.w10,
              Expanded(
                child: Text(
                  switch (mission.status) {
                    MissionStatus.confirmed =>
                      'Partez vers le client puis demandez le code a 6 chiffres une fois sur place.',
                    MissionStatus.onTheWay =>
                      'Quand vous arrivez, entrez le code donne par le client pour demarrer la mission.',
                    MissionStatus.inProgress =>
                      'La mission est en cours. Terminez-la ici a la fin de l intervention.',
                    MissionStatus.completionRequested =>
                      'Vous avez signale la fin. Le client doit maintenant confirmer ou contester.',
                    _ => 'Le suivi de mission est termine.',
                  },
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF344150),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (startCodeHint != null &&
            (mission.status == MissionStatus.confirmed ||
                mission.status == MissionStatus.onTheWay)) ...[
          AppGap.h12,
          Row(
            children: [
              Expanded(
                child: Text(
                  'Test local: code ${startCodeHint!.substring(0, 3)} ${startCodeHint!.substring(3)}',
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              if (onCopyHint != null)
                TextButton(
                  onPressed: onCopyHint,
                  child: const Text('Copier'),
                ),
            ],
          ),
        ],
        AppGap.h16,
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: AppColors.urgent,
            ),
            AppGap.w6,
            Expanded(
              child: Text(
                mission.address.fullAddress,
                style: context.text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AppGap.h18,
        if (onStartRoute != null)
          _TrackingPrimaryButton(
            label: 'Je suis en route',
            icon: Icons.navigation_rounded,
            onTap: onStartRoute!,
          ),
        if (onEnterStartCode != null) ...[
          if (onStartRoute != null) AppGap.h10,
          _TrackingPrimaryButton(
            label: 'Entrer le code client',
            icon: Icons.password_rounded,
            onTap: onEnterStartCode!,
          ),
        ],
        if (onFinishMission != null) ...[
          AppGap.h10,
          _TrackingPrimaryButton(
            label: 'J ai termine',
            icon: Icons.check_circle_rounded,
            onTap: onFinishMission!,
          ),
        ],
      ],
    );
  }
}

class _TrackingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TrackingPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
