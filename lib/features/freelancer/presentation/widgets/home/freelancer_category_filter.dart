import 'package:flutter/material.dart';

import 'package:flutter_application_1/app/widgets/app_category_filter_bar.dart';
import 'package:flutter_application_1/core/design/app_design_system.dart';
import 'package:flutter_application_1/features/mission/data/models/service_category.dart';

/// Barre de filtres par catégorie (scroll horizontal).
class FreelancerCategoryFilter extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;

  const FreelancerCategoryFilter({
    super.key,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  List<AppCategoryItem> _items() => [
    const AppCategoryItem(
      id: null,
      label: ServiceCategory.allFilterLabel,
      icon: Icons.apps_outlined,
      color: Color(0xFF64748B),
    ),
    ...ServiceCategory.ordered.map(
      (category) => AppCategoryItem(
        id: category.id,
        label: category.chipLabel,
        icon: category.icon,
        color: category.color,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: AppCategoryFilterBar(
        items: _items(),
        selectedId: selectedCategoryId,
        onSelect: onSelect,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        spacing: 10,
        height: 50,
      ),
    );
  }
}
