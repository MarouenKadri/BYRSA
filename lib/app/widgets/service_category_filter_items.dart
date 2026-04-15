import 'package:flutter/material.dart';

import '../../features/mission/data/models/service_category.dart';
import 'app_category_filter_bar.dart';

class ServiceCategoryFilterItems {
  const ServiceCategoryFilterItems._();

  static List<AppCategoryItem> build({bool includeAll = true}) {
    final items = <AppCategoryItem>[
      if (includeAll)
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
    return List<AppCategoryItem>.unmodifiable(items);
  }
}
