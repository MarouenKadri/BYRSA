import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Primitive : Badge statut ─────────────────────────────────────────────────
// Responsabilité unique : afficher un badge coloré pour le statut d'une mission.
// Deux factory constructors couvrent les deux styles visuels de l'app :
//   • summary  → fond blanc + bordure (cards postulées/en cours/publiées)
//   • archive  → fond coloré selon statut (cards archives)
// ─────────────────────────────────────────────────────────────────────────────

class MissionStatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double letterSpacing;

  const MissionStatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.letterSpacing = 0.35,
  });

  // Style summary : fond blanc + bordure subtile
  factory MissionStatusChip.summary({required String label}) {
    return MissionStatusChip(
      label: label,
      foreground: const Color(0xFF1A1A1A),
      background: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
    );
  }

  // Style archive : fond coloré résolu depuis le label
  factory MissionStatusChip.archive({required String label}) {
    final style = _resolveArchiveStyle(label);
    return MissionStatusChip(
      label: label,
      foreground: style.foreground,
      background: style.background,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      letterSpacing: 0.2,
    );
  }

  static _ChipStyle _resolveArchiveStyle(String label) {
    return switch (label) {
      'Annulee' => const _ChipStyle(
          foreground: Color(0xFFA56969),
          background: Color(0xFFF8F1F1),
        ),
      'Paiement en attente' => const _ChipStyle(
          foreground: Color(0xFF6A7280),
          background: Color(0xFFF0F2F5),
        ),
      _ => const _ChipStyle(
          foreground: Color(0xFF5A6169),
          background: Color(0xFFF0F1F2),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

class _ChipStyle {
  final Color foreground;
  final Color background;
  const _ChipStyle({required this.foreground, required this.background});
}
