import 'package:flutter/material.dart';

import '../../app/app_bar/location_app_bar.dart';
import '../../core/design/app_design_system.dart';
import '../mission/presentation/pages/freelancer/mission_browse_page.dart';

/// Page Explorer (onglet 0 du freelancer) — wrapper de MissionBrowsePage.
class FreelancerExploreContent extends StatelessWidget {
  final VoidCallback? onGoToAccount;

  const FreelancerExploreContent({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: LocationAppBar(onGoToAccount: onGoToAccount),
      body: MissionBrowsePage(
        onLocationTap: null,
      ),
    );
  }
}
