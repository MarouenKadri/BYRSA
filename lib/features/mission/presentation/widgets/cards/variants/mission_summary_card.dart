import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/mission.dart';
import '../../shared/mission_status_ui.dart';
import '../primitives/mission_card_frame.dart';
import '../primitives/mission_meta_row.dart';
import '../primitives/mission_status_chip.dart';

// ─── Variant : Missions engagées ─────────────────────────────────────────────
// Responsabilité : afficher une mission dont l'utilisateur fait partie
// (postulées, en cours côté freelancer — publiées, en cours côté client).
// Compose MissionCardFrame + MissionMetaRow + MissionStatusChip.
//
// Paramètres de configuration :
//   • role            — détermine le label de statut (freelancer vs client)
//   • showDescription — afficher la description (client : true, freelancer : false)
//   • showAddress     — inclure l'adresse dans les meta pills
//   • extra           — slot optionnel Template Method pour ajouts spécifiques
// ─────────────────────────────────────────────────────────────────────────────

class MissionSummaryCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final MissionUiRole role;
  final bool showDescription;
  final bool showAddress;
  final Widget? extra;

  const MissionSummaryCard({
    super.key,
    required this.mission,
    required this.onTap,
    required this.role,
    this.showDescription = false,
    this.showAddress = false,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = MissionStatusUi.badgeLabel(
      status: mission.status,
      role: role,
    );

    final metaItems = [
      MissionMetaItem(icon: Icons.calendar_today_outlined, text: mission.formattedDate),
      MissionMetaItem(icon: Icons.schedule_outlined, text: mission.timeSlot),
      if (showAddress)
        MissionMetaItem(icon: Icons.location_on_outlined, text: mission.address.shortAddress),
    ];

    return MissionCardFrame(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mission.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6F7782),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  mission.budget.displayText,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101214),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            if (showDescription && mission.description.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A929B),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: MissionMetaRow(items: metaItems)),
                const SizedBox(width: 12),
                MissionStatusChip.summary(label: statusLabel),
              ],
            ),
            if (extra != null) ...[
              const SizedBox(height: 12),
              extra!,
            ],
          ],
        ),
      ),
    );
  }
}
