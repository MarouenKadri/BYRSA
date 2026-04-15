import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/design/app_design_system.dart';
import '../main_bottom_nav.dart';
import 'app_nav_config.dart';

class AppNavShell extends StatefulWidget {
  final AppNavConfig config;
  final Map<int, int> badgeCounts;

  const AppNavShell({
    super.key,
    required this.config,
    this.badgeCounts = const {},
  });

  @override
  State<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends State<AppNavShell> {
  int _index = 0;
  bool _fabExpanded = true;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = widget.config.pagesBuilder(_goToIndex);
  }

  void _goToIndex(int value) {
    setState(() => _index = value);
  }

  void _setFabExpanded(bool value) {
    setState(() => _fabExpanded = value);
  }

  bool _onScroll(ScrollNotification notification) {
    if (!widget.config.trackScrollForFab) return false;
    if (notification is UserScrollNotification) {
      final shouldShrink = notification.direction == ScrollDirection.reverse;
      if (_fabExpanded == shouldShrink) {
        _setFabExpanded(!shouldShrink);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.config.trackScrollForFab
        ? NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: _pages[_index],
          )
        : _pages[_index];

    return Scaffold(
      extendBody: true,
      backgroundColor: context.colors.background,
      body: body,
      floatingActionButton: widget.config.fabBuilder?.call(
        context,
        _index,
        _fabExpanded,
        _setFabExpanded,
        _goToIndex,
      ),
      floatingActionButtonLocation: widget.config.fabBuilder != null
          ? const _CenterAlignedNavFabLocation()
          : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MainBottomNav(
        currentIndex: _index,
        onItemSelected: _goToIndex,
        items: widget.config.items,
        badgeCounts: widget.badgeCounts,
        hasCenterGap: widget.config.fabBuilder != null,
      ),
    );
  }
}

/// Places the center action at the same visual level as nav icons.
class _CenterAlignedNavFabLocation extends FloatingActionButtonLocation {
  const _CenterAlignedNavFabLocation();

  static const double _iconRowOffset = 8;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final fabX =
        (geometry.scaffoldSize.width - geometry.floatingActionButtonSize.width) /
            2;

    final barTop = geometry.bottomNavigationBarTop;
    final barHeight = geometry.scaffoldSize.height - barTop;
    final centeredY =
        barTop + (barHeight - geometry.floatingActionButtonSize.height) / 2;
    final minY = barTop;
    final maxY = barTop + barHeight - geometry.floatingActionButtonSize.height;
    final fabY = (centeredY - _iconRowOffset).clamp(minY, maxY).toDouble();

    return Offset(fabX, fabY);
  }
}
