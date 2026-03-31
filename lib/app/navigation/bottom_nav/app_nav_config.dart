import 'package:flutter/material.dart';

import '../main_bottom_nav.dart';

typedef AppNavPagesBuilder = List<Widget> Function(ValueChanged<int> goToIndex);
typedef AppNavFabBuilder = Widget? Function(
  BuildContext context,
  int currentIndex,
  bool fabExpanded,
  ValueChanged<bool> setFabExpanded,
  ValueChanged<int> goToIndex,
);

class AppNavConfig {
  final List<NavItem> items;
  final AppNavPagesBuilder pagesBuilder;
  final AppNavFabBuilder? fabBuilder;
  final bool trackScrollForFab;

  const AppNavConfig({
    required this.items,
    required this.pagesBuilder,
    this.fabBuilder,
    this.trackScrollForFab = false,
  });
}
