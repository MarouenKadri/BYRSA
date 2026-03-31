import 'package:flutter/material.dart';
import '../../core/design/app_design_system.dart';
import '../../core/design/app_primitives.dart';

/// Données d'un onglet.
class CigaleTab {
  final IconData? icon; // ignoré dans le style mission harmonisé
  final String label;
  const CigaleTab({this.icon, required this.label});
}

class _MissionTabIndicator extends Decoration {
  final Color color;
  final double thickness;
  final double horizontalInset;

  const _MissionTabIndicator({
    required this.color,
    this.thickness = 2,
    this.horizontalInset = 10,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MissionTabIndicatorPainter(
      color: color,
      thickness: thickness,
      horizontalInset: horizontalInset,
    );
  }
}

class _MissionTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double thickness;
  final double horizontalInset;

  _MissionTabIndicatorPainter({
    required this.color,
    required this.thickness,
    required this.horizontalInset,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final width = (size.width - (horizontalInset * 2)).clamp(18.0, size.width);
    final left = offset.dx + ((size.width - width) / 2);
    final top = offset.dy + size.height - thickness - 3;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, thickness),
      Radius.circular(thickness),
    );
    final paint = Paint()..color = color;
    canvas.drawRRect(rect, paint);
  }
}

/// TabBar mission harmonisé : indicateur capsule ultra-fin sous le texte,
/// texte actif noir, inactif gris clair.
class CigaleTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CigaleTab> tabs;
  final TabController? controller;
  final bool isScrollable;

  const CigaleTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppNavMetrics.tabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppTabBarSurface(
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
        indicator: const _MissionTabIndicator(
          color: Color(0xFF0088CC),
          thickness: 2,
          horizontalInset: 12,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        labelColor: const Color(0xFF000000),
        unselectedLabelColor: const Color(0xFFB6BEC7),
        labelStyle: context.navTabLabelStyle.copyWith(
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: context.navTabUnselectedLabelStyle.copyWith(
          color: const Color(0xFFB6BEC7),
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((t) => Tab(
          height: AppNavMetrics.tabHeight,
          text: t.label,
        )).toList(),
      ),
    );
  }
}
