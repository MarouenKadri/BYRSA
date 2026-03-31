import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';

// ─── StatusBannerConfig ───────────────────────────────────────────────────────
// Data object — no Widget, testable unitairement

enum DetailBannerStyle { colored, card }

class StatusBannerConfig {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool pulse;
  final DetailBannerStyle style;

  const StatusBannerConfig({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pulse = false,
    this.style = DetailBannerStyle.colored,
  });
}

// ─── DetailCircleBtn ──────────────────────────────────────────────────────────

class DetailCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const DetailCircleBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.28),
          width: 0.6,
        ),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
  );
}

// ─── DetailMetaChip ───────────────────────────────────────────────────────────

class DetailMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailMetaChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: const Color(0xFF98A1AC)),
      AppGap.w6,
      Expanded(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF66707C),
          ),
        ),
      ),
    ],
  );
}

// ─── DetailLuxuryPill ─────────────────────────────────────────────────────────

class DetailLuxuryPill extends StatelessWidget {
  final String label;

  const DetailLuxuryPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFF161616), width: 0.5),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111111),
      ),
    ),
  );
}

// ─── DetailInlineDivider ──────────────────────────────────────────────────────

class DetailInlineDivider extends StatelessWidget {
  const DetailInlineDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 12,
    margin: AppInsets.h8,
    color: context.colors.divider,
  );
}

// ─── DetailInfoRow ────────────────────────────────────────────────────────────

class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final bool twoLines;

  const DetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.text,
    this.twoLines = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment:
          twoLines ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF98A1AC)),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9AA3AE),
                ),
              ),
              AppGap.h4,
              Text(
                text,
                maxLines: twoLines ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── DetailListDivider ────────────────────────────────────────────────────────

class DetailListDivider extends StatelessWidget {
  const DetailListDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFF0F1F3), indent: 31);
}

// ─── DetailBottomArea ─────────────────────────────────────────────────────────

class DetailBottomArea extends StatelessWidget {
  final Widget child;
  final String? caption;

  const DetailBottomArea({super.key, required this.child, this.caption});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (caption != null) ...[
            AppGap.h8,
            Text(
              caption!,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── DetailTealButton ─────────────────────────────────────────────────────────

class DetailTealButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;

  const DetailTealButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? const Color(0xFF000000);
    final fg = textColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: onTap != null ? bg : bg.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              AppGap.w8,
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: onTap != null ? fg : const Color(0xFF8F98A3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DetailReadonlyBadge ──────────────────────────────────────────────────────

class DetailReadonlyBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailReadonlyBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.button),
      border: Border.all(color: context.colors.divider),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: context.colors.textTertiary, size: 18),
        AppGap.w8,
        Text(
          label,
          style: context.text.titleSmall?.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ],
    ),
  );
}

// ─── DetailStatusBanner ───────────────────────────────────────────────────────
// Rend StatusBannerConfig — supporte 2 styles visuels (colored / card)

class DetailStatusBanner extends StatelessWidget {
  final StatusBannerConfig config;

  const DetailStatusBanner({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return config.style == DetailBannerStyle.card
        ? _buildCard(context)
        : _buildColored(context);
  }

  // Style client — fond coloré semi-transparent
  Widget _buildColored(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: AppInsets.a14,
    decoration: BoxDecoration(
      color: config.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.button),
      border: Border.all(color: config.color.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        config.pulse
            ? DetailPulsingDot(color: config.color)
            : Icon(config.icon, color: config.color, size: 20),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: config.color,
                ),
              ),
              AppGap.h2,
              Text(
                config.subtitle,
                style: context.text.labelMedium?.copyWith(
                  color: config.color.withValues(alpha: 0.75),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // Style freelancer — card blanche, icône muted
  Widget _buildCard(BuildContext context) {
    final iconColor = config.color == AppColors.error
        ? const Color(0xFF8F5656)
        : config.color == AppColors.warning
            ? const Color(0xFF8B6B2F)
            : const Color(0xFF4A4F55);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          config.pulse
              ? DetailPulsingDot(color: config.color)
              : Icon(config.icon, color: iconColor, size: 18),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                AppGap.h4,
                Text(
                  config.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7C8795),
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

// ─── DetailPulsingDot ─────────────────────────────────────────────────────────

class DetailPulsingDot extends StatefulWidget {
  final Color color;

  const DetailPulsingDot({super.key, required this.color});

  @override
  State<DetailPulsingDot> createState() => _DetailPulsingDotState();
}

class _DetailPulsingDotState extends State<DetailPulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: _anim.value),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: _anim.value * 0.5),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    ),
  );
}

// ─── DetailGradientPlaceholder ────────────────────────────────────────────────

class DetailGradientPlaceholder extends StatelessWidget {
  final Mission mission;

  const DetailGradientPlaceholder({super.key, required this.mission});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mission.categoryColor.withValues(alpha: 0.6),
          context.colors.background,
        ],
      ),
    ),
    child: Center(
      child: Icon(
        mission.categoryIcon,
        size: 72,
        color: Colors.white.withValues(alpha: 0.2),
      ),
    ),
  );
}

// ─── DetailMapPlaceholder ─────────────────────────────────────────────────────

class DetailMapPlaceholder extends StatelessWidget {
  final String address;

  const DetailMapPlaceholder({super.key, required this.address});

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Container(color: const Color(0xFFF5F6F8)),
      const Positioned.fill(child: CustomPaint(painter: _MiniMapPainter())),
      const Center(child: DetailMiniMapPin()),
    ],
  );
}

// ─── DetailMiniMapPin ─────────────────────────────────────────────────────────

class DetailMiniMapPin extends StatelessWidget {
  const DetailMiniMapPin({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: const BoxDecoration(
      color: Color(0xFF111111),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Center(
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

// ─── _MiniMapPainter ──────────────────────────────────────────────────────────

class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE4E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final minorRoadPaint = Paint()
      ..color = const Color(0xFFEEF0F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final waterPaint = Paint()
      ..color = const Color(0xFFD9E9F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.18, size.height * 0.16)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.28,
        size.width * 0.30,
        size.height * 0.62,
        size.width * 0.56,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.78,
        size.width * 0.79,
        size.height * 0.62,
        size.width * 0.88,
        size.height * 0.86,
      );
    canvas.drawPath(river, waterPaint);

    for (final y in [0.22, 0.46, 0.69]) {
      canvas.drawLine(
        Offset(size.width * 0.08, size.height * y),
        Offset(size.width * 0.92, size.height * y),
        roadPaint,
      );
    }
    for (final x in [0.22, 0.48, 0.74]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.12),
        Offset(size.width * x, size.height * 0.88),
        minorRoadPaint,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.18),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── DetailDualPillBar ────────────────────────────────────────────────────────

class DetailDualPillBar extends StatelessWidget {
  final IconData leftIcon;
  final String leftLabel;
  final VoidCallback onLeft;
  final IconData rightIcon;
  final String rightLabel;
  final VoidCallback onRight;

  const DetailDualPillBar({
    super.key,
    required this.leftIcon,
    required this.leftLabel,
    required this.onLeft,
    required this.rightIcon,
    required this.rightLabel,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Row(
        children: [
          Expanded(child: _Pill(icon: leftIcon, label: leftLabel, onTap: onLeft)),
          const SizedBox(width: 12),
          Expanded(child: _Pill(icon: rightIcon, label: rightLabel, onTap: onRight)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Pill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
