import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/core/design/app_design_system.dart';
import 'package:flutter_application_1/features/mission/data/models/mission.dart';

/// Barre de filtres par catégorie (scroll horizontal).
class FreelancerCategoryFilter extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;

  const FreelancerCategoryFilter({
    super.key,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = <({String? id, String label, IconData icon})>[
      (id: null, label: 'Toutes', icon: Icons.apps_outlined),
      (id: 'menage', label: 'Ménage', icon: Icons.cleaning_services_outlined),
      (id: 'jardinage', label: 'Jardinage', icon: Icons.yard_outlined),
      (id: 'bricolage', label: 'Brico', icon: Icons.handyman_outlined),
      ...ServiceCategory.all
          .where((c) =>
              c.id != 'menage' && c.id != 'jardinage' && c.id != 'bricolage')
          .map((c) => (id: c.id, label: c.name, icon: c.icon)),
    ];

    return Container(
      color: context.colors.surface,
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 18),
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = selectedCategoryId == item.id ||
                (selectedCategoryId == null && item.id == null);
            return _CategoryChip(
              id: item.id,
              label: item.label,
              icon: item.icon,
              selected: isSelected,
              onTap: () => onSelect(item.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String? id;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.id,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFFFFF), width: 0.8),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
              color: const Color(0xFF4A78B6),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 9, bottom: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: const Color(0xFF646B73)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    color: const Color(0xFF646B73),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Container(
              width: (label.length * 6).toDouble(),
              height: 1,
              color: const Color(0xFFD2D7DD),
            ),
          ],
        ),
      ),
    );
  }
}
