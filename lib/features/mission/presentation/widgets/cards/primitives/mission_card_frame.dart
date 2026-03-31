import 'package:flutter/material.dart';

// ─── Primitive : Decorator ────────────────────────────────────────────────────
// Responsabilité unique : encadrement visuel partagé (shadow, radius, ripple).
// Les variants composent ce widget sans en connaître les détails.
// ─────────────────────────────────────────────────────────────────────────────

class MissionCardFrame extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final Color color;
  final List<BoxShadow> shadows;

  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> browseShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> noShadow = [];

  const MissionCardFrame({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 24,
    this.color = Colors.white,
    this.shadows = defaultShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
