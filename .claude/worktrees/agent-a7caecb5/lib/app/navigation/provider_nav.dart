import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'main_bottom_nav.dart';

import '../../features/freelancer/freelancer_home_page.dart';
import '../../features/mission/presentation/pages/freelancer/freelancer_my_missions_page.dart';
import '../../features/messaging/presentation/pages/messages_page.dart';
import '../../features/messaging/messaging_provider.dart';
import '../../features/post/presentation/pages/create_post_page.dart';
import '../../features/profile/presentation/pages/shared/account_page.dart';
import '../../app/theme/design_tokens.dart';

class ProviderNav extends StatefulWidget {
  const ProviderNav({super.key});

  @override
  State<ProviderNav> createState() => _ProviderNavState();
}

class _ProviderNavState extends State<ProviderNav> {
  int index = 0;
  int _freelancerInnerTab = 0;
  bool _fabExpanded = true;

  late final List<Widget> pages;

  final List<NavItem> items = [
    NavItem(Icons.grid_view_outlined,  Icons.grid_view_rounded,   'Explorer'),
    NavItem(Icons.handyman_outlined,   Icons.handyman_rounded,    'Missions'),
    NavItem(Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 'Messages'),
    NavItem(Icons.badge_outlined,      Icons.badge_rounded,       'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      FreelancerHomePage(
        onTabChanged: (i) => setState(() => _freelancerInnerTab = i),
        onGoToAccount: () => setState(() => index = 3),
      ),
      FreelancerMyMissionsPage(onGoToAccount: () => setState(() => index = 3)),
      MessagesPage(onGoToAccount: () => setState(() => index = 3)),
      const AccountPage(),
    ];
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final shrink = notification.direction == ScrollDirection.reverse;
      if (_fabExpanded == shrink) setState(() => _fabExpanded = !shrink);
    }
    return false;
  }

  Widget? _buildFab() {
    if (index == 0 && _freelancerInnerTab == 1) {
      return AnimatedFab(
        expanded: _fabExpanded,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostPage()),
        ),
        icon: Icons.edit_rounded,
        label: 'Publier',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: pages[index],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: Consumer<MessagingProvider>(
        builder: (_, messaging, __) => MainBottomNav(
          currentIndex: index,
          onItemSelected: (i) => setState(() => index = i),
          items: items,
          badgeCounts: {2: messaging.totalUnread},
        ),
      ),
    );
  }
}
