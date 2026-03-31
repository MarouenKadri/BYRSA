import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem(this.icon, this.activeIcon, this.label);
}

/// ─── Floating bottom nav bar ─────────────────────────────────────────────────
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> items;
  final Map<int, int> badgeCounts;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.badgeCounts = const {},
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) => Expanded(
            child: _NavTile(
              item: items[i],
              selected: currentIndex == i,
              onTap: () => onItemSelected(i),
              badgeCount: badgeCounts[i] ?? 0,
              isFirst: i == 0,
              isLast: i == items.length - 1,
            ),
          )),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isFirst;
  final bool isLast;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _tapScale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.selected ? widget.item.activeIcon : widget.item.icon,
                    size: 22,
                    color: widget.selected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
              if (widget.badgeCount > 0)
                Positioned(
                  top: -2,
                  right: 6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.urgent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      widget.badgeCount > 9 ? '9+' : '${widget.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 11,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
              color: widget.selected ? AppColors.primary : AppColors.textTertiary,
            ),
            child: Text(widget.item.label),
          ),
        ],
      ),
    );
  }
}

/// FAB animé — étendu par défaut, réduit au scroll
class AnimatedFab extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const AnimatedFab({
    super.key,
    required this.expanded,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.35),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: expanded
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ])
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
