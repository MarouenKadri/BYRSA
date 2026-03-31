import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../mission/presentation/mission_provider.dart';
import '../../../../mission/presentation/pages/client/client_mission_detail_page.dart';
import '../../../../mission/presentation/pages/freelancer/freelancer_mission_detail_page.dart';
import '../../../../mission/presentation/widgets/shared/mission_status_ui.dart';
import '../../../../mission/presentation/widgets/cards/variants/mission_archive_card.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        context.watch<AuthProvider>().currentRole == UserRole.provider;
    final provider = context.watch<MissionProvider>();
    final source = isFreelancer ? provider.freelancerMissions : provider.clientMissions;
    final role = isFreelancer ? MissionUiRole.freelancer : MissionUiRole.client;
    final missions = source
        .where((mission) => MissionStatusUi.belongsToTab(
              status: mission.status,
              role: role,
              tab: MissionUiTab.archived,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppPageAppBar(
        backgroundColor: Colors.white,
        leading: AppBackButtonLeading(onPressed: () => Navigator.of(context).pop()),
        titleWidget: Text(
          'Archives',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222629),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: missions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Aucune mission archivee pour le moment.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A9199),
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              itemCount: missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return MissionArchiveCard(
                  mission: mission,
                  role: role,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isFreelancer
                          ? FreelancerMissionDetailPage(mission: mission, isOwn: true)
                          : ClientMissionDetailPage(mission: mission),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

