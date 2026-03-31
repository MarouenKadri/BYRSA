import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import 'main_bottom_nav.dart';
import '../../features/messaging/messaging_provider.dart';

import '../../features/client/presentation/pages/client_home_page.dart';
import '../../features/mission/presentation/pages/client/client_missions_page.dart';
import '../../features/mission/presentation/pages/client/create_mission_page.dart';
import '../../features/mission/presentation/widgets/shared/mission_common_widgets.dart';
import '../../features/messaging/presentation/pages/messages_page.dart';
import '../../features/profile/presentation/pages/shared/account_page.dart';

class ClientNav extends StatefulWidget {
  const ClientNav({super.key});

  @override
  State<ClientNav> createState() => _ClientNavState();
}

class _ClientNavState extends State<ClientNav> {
  int index = 0;
  bool _fabExpanded = true;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      ClientHomePage(onGoToAccount: () => setState(() => index = 3)),
      ClientMissionsPage(onGoToAccount: () => setState(() => index = 3)),
      MessagesPage(onGoToAccount: () => setState(() => index = 3)),
      const AccountPage(),
    ];
  }

  final List<NavItem> items = [
    NavItem(Icons.explore_outlined,       Icons.explore_rounded,      'Découvrir'),
    NavItem(Icons.receipt_long_outlined,  Icons.receipt_long_rounded, 'Missions'),
    NavItem(Icons.chat_bubble_outline,    Icons.chat_bubble_rounded,  'Messages'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded,       'Compte'),
  ];

  bool _onScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final shrink = notification.direction == ScrollDirection.reverse;
      if (_fabExpanded == shrink) setState(() => _fabExpanded = !shrink);
    }
    return false;
  }

  Widget? _buildFab() {
    if (index == 0 || index == 1) {
      return AnimatedFab(
        expanded: _fabExpanded,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            slideUpRoute(page: const PostMissionFlow()),
          );
          if (result == 'published' && mounted) {
            setState(() => index = 1);
          }
        },
        icon: Icons.add_rounded,
        label: 'Nouvelle mission',
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
