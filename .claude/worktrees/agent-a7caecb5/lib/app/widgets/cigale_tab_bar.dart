import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Données d'un onglet : icône + label.
class CigaleTab {
  final IconData icon;
  final String label;
  const CigaleTab({required this.icon, required this.label});
}

/// TabBar partagée avec style pill indicator.
/// Utilise [controller] si fourni, sinon s'appuie sur [DefaultTabController].
class CigaleTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CigaleTab> tabs;
  final TabController? controller;

  const CigaleTabBar({super.key, required this.tabs, this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: -0.1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: tabs
              .map(
                (t) => Tab(
                  height: 36,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon, size: 16),
                      const SizedBox(width: 5),
                      Text(t.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
