import 'package:flutter/material.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/cigale_tab_bar.dart';
import '../../app/widgets/location_app_bar.dart';
import '../mission/presentation/pages/freelancer/freelancer_missions_page.dart';
import '../post/presentation/pages/posts_feed_page.dart';

/// ─────────────────────────────────────────────────────────────
/// 🏠 Inkern - Page d'accueil Freelancer
/// Combine : Missions disponibles + Fil d'actualité
/// ─────────────────────────────────────────────────────────────

class FreelancerHomePage extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  final VoidCallback? onGoToAccount;
  const FreelancerHomePage({super.key, this.onTabChanged, this.onGoToAccount});

  @override
  State<FreelancerHomePage> createState() => _FreelancerHomePageState();
}

class _FreelancerHomePageState extends State<FreelancerHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LocationAppBar(
        onGoToAccount: widget.onGoToAccount,
        bottom: CigaleTabBar(
          controller: _tabController,
          tabs: const [
            CigaleTab(icon: Icons.work_outline_rounded, label: 'Missions'),
            CigaleTab(icon: Icons.dynamic_feed_rounded, label: 'Actualité'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FreelancerMissionsPage(),
          PostsFeedPage(isFreelancer: true, showAppBar: false),
        ],
      ),
    );
  }
}
