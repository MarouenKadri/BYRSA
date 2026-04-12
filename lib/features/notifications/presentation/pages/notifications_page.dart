import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/app_notification.dart';
import '../../notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final unreadCount = provider.unreadCount;
    final filtered = _showUnreadOnly
        ? notifications.where((notification) => !notification.isRead).toList()
        : notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF7B8188),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => context.read<NotificationProvider>().markAllRead(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Tout lire'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Toutes',
                    selected: !_showUnreadOnly,
                    onTap: () => setState(() => _showUnreadOnly = false),
                  ),
                  const SizedBox(width: 10),
                  _FilterPill(
                    label: unreadCount > 0 ? 'Non lues ($unreadCount)' : 'Non lues',
                    selected: _showUnreadOnly,
                    onTap: () => setState(() => _showUnreadOnly = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyNotifications(showUnreadOnly: _showUnreadOnly)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = filtered[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          background: const _DismissBackground(),
                          onDismissed: (_) {
                            context.read<NotificationProvider>().deleteNotification(notification.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                          child: _NotificationCard(
                            notification: notification,
                            onTap: () => context.read<NotificationProvider>().markRead(notification.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray50),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationAvatar(notification: notification),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5B6168),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9AA1A8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  final AppNotification notification;

  const _NotificationAvatar({required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.avatarUrl != null && notification.avatarUrl!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE7E9EC), width: 1),
        ),
        child: Image.network(
          notification.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _AvatarFallback(type: notification.type),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE7E9EC), width: 1),
      ),
      child: Center(
        child: Icon(
          _typeIcon(notification.type),
          size: 20,
          color: const Color(0xFF4F555C),
        ),
      ),
    );
  }

  static IconData _typeIcon(NotifType type) {
    switch (type) {
      case NotifType.message:
        return Icons.chat_bubble_outline_rounded;
      case NotifType.mission:
        return Icons.work_outline_rounded;
      case NotifType.candidature:
        return Icons.person_outline_rounded;
      case NotifType.payment:
        return Icons.account_balance_wallet_outlined;
      case NotifType.review:
        return Icons.star_outline_rounded;
    }
  }
}

class _AvatarFallback extends StatelessWidget {
  final NotifType type;

  const _AvatarFallback({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case NotifType.message:
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case NotifType.mission:
        icon = Icons.work_outline_rounded;
        break;
      case NotifType.candidature:
        icon = Icons.person_outline_rounded;
        break;
      case NotifType.payment:
        icon = Icons.account_balance_wallet_outlined;
        break;
      case NotifType.review:
        icon = Icons.star_outline_rounded;
        break;
    }

    return Container(
      color: const Color(0xFFF7F7F8),
      child: Center(
        child: Icon(icon, size: 20, color: const Color(0xFF4F555C)),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8EAEA),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Color(0xFFA55F5F),
        size: 20,
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final bool showUnreadOnly;

  const _EmptyNotifications({required this.showUnreadOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: Color(0xFF7B8188),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              showUnreadOnly ? 'Aucune notification non lue' : 'Aucune notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tout est a jour pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
