import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: const Color(0xFF7E8792)),
          const SizedBox(width: 6),
          Text(
            item.text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7E8792),
            ),
          ),
        ],
      ),
    );
  }
}
