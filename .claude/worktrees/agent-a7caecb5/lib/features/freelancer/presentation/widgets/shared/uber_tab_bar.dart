import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// 🚗 UberTabBar - TabBar style Uber
/// 
/// Caractéristiques :
/// - Underline noir épais (3px) sous l'onglet actif
/// - Texte noir (actif) / gris (inactif)
/// - Font bold pour actif, medium pour inactif
/// - Aligné à gauche, scrollable
/// - Pas d'effet ripple/splash
/// ─────────────────────────────────────────────────────────────
class UberTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsetsGeometry? padding;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final Color backgroundColor;
  final Color borderColor;
  final double indicatorWeight;
  final double fontSize;
  final bool showBorder;

  const UberTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.padding,
    this.activeColor = Colors.black,
    this.inactiveColor = const Color(0xFF6B6B6B),
    this.indicatorColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE8E8E8),
    this.indicatorWeight = 3.0,
    this.fontSize = 16.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: padding ?? const EdgeInsets.only(left: 16),

        // ⭐ Underline indicator style Uber
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: indicatorColor,
            width: indicatorWeight,
          ),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.label,

        // ⭐ Couleurs
        labelColor: activeColor,
        unselectedLabelColor: inactiveColor,

        // ⭐ Styles texte
        labelStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),

        // Pas d'effet splash/ripple (comme Uber)
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        dividerColor: Colors.transparent,

        tabs: tabs
            .map((label) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(label),
                  ),
                ))
            .toList(),
      ),
    );
  }
}