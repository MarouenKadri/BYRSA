import 'package:flutter/material.dart';
import '../../core/design/app_design_system.dart';

/// Data model for one segmented tab.
class AppSegmentedTab {
  final IconData? icon; // ignoré dans le style mission harmonisé
  final String label;
  const AppSegmentedTab({this.icon, required this.label});
}

/// Reusable pill-style segmented tab bar.
class AppSegmentedTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<AppSegmentedTab> tabs;
  final TabController? controller;
  final bool isScrollable;

  const AppSegmentedTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final resolvedController = controller ?? DefaultTabController.maybeOf(context);
    if (resolvedController == null) {
      return const SizedBox.shrink();
    }

    return AppTabBarSurface(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: AnimatedBuilder(
          animation: resolvedController,
          builder: (context, _) {
            final chips = List<Widget>.generate(tabs.length, (index) {
              final selected = resolvedController.index == index;
              final chip = GestureDetector(
                onTap: () => resolvedController.animateTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.ink : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.ink : const Color(0xFFE6E9ED),
                    ),
                  ),
                  child: Text(
                    tabs[index].label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF6A7380),
                    ),
                  ),
                ),
              );

              if (isScrollable) {
                return Padding(
                  padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
                  child: chip,
                );
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
                  child: chip,
                ),
              );
            });

            return isScrollable
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: chips),
                  )
                : Row(children: chips);
          },
        ),
      ),
    );
  }
}
