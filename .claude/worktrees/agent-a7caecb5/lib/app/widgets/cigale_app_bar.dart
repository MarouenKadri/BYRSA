import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../theme/design_tokens.dart';
import '../../features/notifications/notifications.dart';
import '../../features/profile/profile_provider.dart';
import 'location_app_bar.dart' show RoleSwitchSheet;

/// AppBar partagée de l'application.
/// - Sans [pageTitle] : affiche le logo "La Cigale" dans une pill colorée (pages d'accueil)
/// - Avec [pageTitle] : affiche un titre de section avec accent Mint (Missions, Messages, Compte…)
/// Accepte un [bottom] optionnel pour les pages avec TabBar.
class CigaleAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String? pageTitle;
  final VoidCallback? onGoToAccount;

  const CigaleAppBar({super.key, this.bottom, this.pageTitle, this.onGoToAccount});

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  State<CigaleAppBar> createState() => _CigaleAppBarState();
}

class _CigaleAppBarState extends State<CigaleAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellScale;
  int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bellScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _triggerBellAnimation(int newCount) {
    if (newCount > _previousUnreadCount) {
      _bellController.forward(from: 0);
    }
    _previousUnreadCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    _triggerBellAnimation(unreadCount);
    final isSection = widget.pageTitle != null;
    final auth      = context.watch<AuthProvider>();
    final firstName = context.watch<ProfileProvider>().profile?.firstName ?? '';
    final isClient  = auth.currentRole == UserRole.client;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 0.8),
      ),
      title: isSection ? _buildSectionTitle() : _buildLogoPill(),
      actions: [
        _buildBellButton(context, unreadCount),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 2),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => RoleSwitchSheet(
                firstName: firstName,
                onGoToAccount: widget.onGoToAccount,
              ),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                isClient ? 'C' : 'F',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: widget.bottom,
    );
  }

  // ── Logo accueil dans une pill colorée ────────────────────────────────────
  Widget _buildLogoPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            'La Cigale',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Titre de section avec accent Mint ─────────────────────────────────────
  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.pageTitle!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ],
    );
  }

  // ── Cloche avec badge et animation ────────────────────────────────────────
  Widget _buildBellButton(BuildContext context, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ScaleTransition(
          scale: _bellScale,
          child: IconButton(
            icon: Icon(
              unreadCount > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined,
              color: unreadCount > 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 26,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.urgent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
