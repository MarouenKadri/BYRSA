import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/design/app_design_system.dart';

/// Barre de tri (Plus récentes / Distance / Budget).
class FreelancerSortBar extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const FreelancerSortBar({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h20v12,
      color: context.colors.surface,
      child: Row(
        children: [
          Text(
            'Trier par :',
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppGap.w12,
          _SortChip(
            value: 'recent',
            label: 'Plus récentes',
            icon: Icons.schedule_rounded,
            selected: sortBy == 'recent',
            onTap: () => onSortChanged('recent'),
          ),
          AppGap.w8,
          _SortChip(
            value: 'distance',
            label: 'Distance',
            icon: Icons.near_me_rounded,
            selected: sortBy == 'distance',
            onTap: () => onSortChanged('distance'),
          ),
          AppGap.w8,
          _SortChip(
            value: 'budget',
            label: 'Budget',
            icon: Icons.euro_rounded,
            selected: sortBy == 'budget',
            onTap: () => onSortChanged('budget'),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppInsets.h12v8,
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          border: Border.all(
            color: selected ? context.colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            AppGap.w6,
            Text(
              label,
              style: context.text.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w600 : null,
                color: selected ? context.colors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
