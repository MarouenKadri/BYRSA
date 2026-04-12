import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../../features/messaging/messaging_provider.dart';
import '../../features/messaging/presentation/pages/messages_page.dart';
import '../../features/profile/presentation/pages/shared/account_page.dart';
import 'bottom_nav/app_nav_config.dart';
import 'bottom_nav/app_nav_shell.dart';
import 'main_bottom_nav.dart';
import 'shell/discover_shell.dart';
import 'shell/missions_shell.dart';

/// Navigation principale unifiée — un seul arbre pour les deux rôles.
/// Les onglets Découvrir et Missions délèguent le contenu
/// à leurs shells rôle-aware respectifs.
class AppNav extends StatelessWidget {
  const AppNav({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentRole;
    final isClient = role == UserRole.client;

    return Consumer<MessagingProvider>(
      builder: (_, messaging, __) => AppNavShell(
        // ValueKey(role) force la réinitialisation des pages au changement de rôle.
        key: ValueKey(role),
        config: AppNavConfig(
          items: [
            NavItem(
              isClient ? Icons.home_outlined : Icons.search_outlined,
              isClient ? Icons.home_rounded : Icons.search_rounded,
              isClient ? 'Découvrir' : 'Explorer',
            ),
            NavItem(
              isClient ? Icons.assignment_outlined : Icons.work_outline_rounded,
              isClient ? Icons.assignment_rounded : Icons.work_rounded,
              'Missions',
            ),
            NavItem(
              Icons.chat_bubble_outline,
              Icons.chat_bubble_rounded,
              'Messages',
            ),
            NavItem(
              Icons.person_outline_rounded,
              Icons.person_rounded,
              isClient ? 'Compte' : 'Profil',
            ),
          ],
          pagesBuilder: (goToIndex) => [
            DiscoverShell(onGoToAccount: () => goToIndex(3)),
            MissionsShell(onGoToAccount: () => goToIndex(3)),
            MessagesPage(onGoToAccount: () => goToIndex(3)),
            const AccountPage(),
          ],
        ),
        badgeCounts: {2: messaging.totalUnread},
      ),
    );
  }
}
