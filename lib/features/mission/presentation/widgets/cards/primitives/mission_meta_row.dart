import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';

// ─── Primitive : Composite ────────────────────────────────────────────────────
// Responsabilité unique : afficher une ligne de métadonnées (date, heure,
// adresse) sous forme de pills. Les variants composent ce widget librement.
// ─────────────────────────────────────────────────────────────────────────────

class MissionMetaItem {
  final IconData icon;
  final String text;

  const MissionMetaItem({required this.icon, required this.text});
}

class MissionMetaRow extends StatelessWidget {
  final List<MissionMetaItem> items;

  const MissionMetaRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _MetaPill(item: item)).toList(),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final MissionMetaItem item;

  const _MetaPill({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: context.colors.textTertiary),
          const SizedBox(width: 6),
          Text(
            item.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
