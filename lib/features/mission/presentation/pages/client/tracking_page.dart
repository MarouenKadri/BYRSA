import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import '../../widgets/shared/mission_shared_widgets.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🗺️ Inkern - TrackingPage (Client · Mock)
/// Simule le suivi GPS du prestataire en route / en cours.
/// ═══════════════════════════════════════════════════════════════════════════

class TrackingPage extends StatefulWidget {
  final Mission mission;

  const TrackingPage({super.key, required this.mission});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<Offset> _moveAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Timer? _etaTimer;
  int _etaMinutes = 8;

  @override
  void initState() {
    super.initState();

    // Animation de déplacement du point bleu (freelancer)
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _moveAnim = Tween<Offset>(
      begin: const Offset(0.2, 0.65),
      end: const Offset(0.55, 0.35),
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOut));

    // Pulsation du point bleu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulation ETA décroissant
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _etaMinutes > 1) {
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Fond carte simulée ─────────────────────────────────────────
          _MockMap(moveAnim: _moveAnim, pulseAnim: _pulseAnim),

          // ─── AppBar transparente ────────────────────────────────────────
          Positioned(
            top: topPadding + 4, left: 4,
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
            top: topPadding + 12, left: 0, right: 0,
            child: Center(
              child: AppSurfaceCard(
                padding: AppInsets.h16v8,
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
                boxShadow: AppShadows.card,
                child: Text(
                  widget.mission.status == MissionStatus.onTheWay ? 'Prestataire en route' : 'Mission en cours',
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          // ─── Panneau inférieur draggable ────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (_, controller) => AppSheetSurface(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                children: [
                  const Center(child: AppBottomSheetHandle()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: _BottomPanel(
                      mission: widget.mission,
                      etaMinutes: _etaMinutes,
                      onCall: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte simulée ────────────────────────────────────────────────────────────

class _MockMap extends StatelessWidget {
  final Animation<Offset> moveAnim;
  final Animation<double> pulseAnim;

  const _MockMap({required this.moveAnim, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Gradient sombre fond de carte
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mapGradientStart, AppColors.mapGradientEnd],
              ),
            ),
          ),
          // Grille simulant les rues
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _GridPainter(),
          ),

          // Pin destination (vert) — fixe
          Positioned(
            left: size.width * 0.55 - 18,
            top: size.height * 0.35 - 40,
            child: const _DestinationPin(),
          ),

          // Point freelancer (bleu animé)
          AnimatedBuilder(
            animation: Listenable.merge([moveAnim, pulseAnim]),
            builder: (_, __) {
              return Positioned(
                left: moveAnim.value.dx * size.width - 12,
                top: moveAnim.value.dy * size.height - 12,
                child: Transform.scale(
                  scale: pulseAnim.value,
                  child: const _FreelancerDot(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    // Lignes horizontales
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Lignes verticales
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Quelques "rues" plus larges
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.2, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), streetPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: AppInsets.a8,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
        ),
        Container(width: 2, height: 12, color: AppColors.primary),
      ],
    );
  }
}

class _FreelancerDot extends StatelessWidget {
  const _FreelancerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: AppColors.iosBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: AppColors.iosBlue.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
      ),
    );
  }
}

// ─── Panneau inférieur ────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final Mission mission;
  final int etaMinutes;
  final VoidCallback onCall;

  const _BottomPanel({required this.mission, required this.etaMinutes, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final presta = mission.assignedPresta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prestataire + ETA
        Row(children: [
          if (presta != null) ...[
            UserAvatar(imageUrl: presta.avatarUrl, radius: 28, showVerified: presta.isVerified),
            AppGap.w14,
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(presta?.name ?? 'Prestataire', style: context.text.titleLarge),
              AppGap.h2,
              Row(children: [
                MissionStatusBadge(status: mission.status, compact: true),
                if (mission.status == MissionStatus.onTheWay) ...[
                  AppGap.w10,
                  Text('~$etaMinutes min', style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ]),
            ]),
          ),
          // Bouton appeler
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDesign.radiusFull),
              onTap: onCall,
              child: AppIconCircle(
                icon: Icons.phone_rounded,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                iconColor: AppColors.primary,
              ),
            ),
          ),
        ]),

        if (mission.status == MissionStatus.inProgress) ...[
          AppGap.h16,
          AppSurfaceCard(
            padding: AppInsets.a14,
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(AppDesign.radius14),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
            child: Row(children: [
              const Icon(Icons.play_circle_rounded, color: AppColors.primary, size: 20),
              AppGap.w10,
              Text('Mission en cours', style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ],

        AppGap.h16,
        const Divider(height: 1),
        AppGap.h12,
        Row(children: [
          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.urgent),
          AppGap.w6,
          Expanded(
            child: Text(
              mission.address.fullAddress,
              style: context.text.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ],
    );
  }
}
