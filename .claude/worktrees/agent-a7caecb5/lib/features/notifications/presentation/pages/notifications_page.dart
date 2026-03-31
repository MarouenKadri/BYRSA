import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../data/models/app_notification.dart';
import '../../notification_provider.dart';

/// ─────────────────────────────────────────────────────────────
/// 🔔 Inkern - Page Notifications
/// ─────────────────────────────────────────────────────────────
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
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => context.read<NotificationProvider>().markAllRead(),
              child: Text(
                'Tout lire',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ─── Filtre ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Toutes',
                  selected: !_showUnreadOnly,
                  onTap: () => setState(() => _showUnreadOnly = false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Non lues',
                  badge: unreadCount > 0 ? unreadCount : null,
                  selected: _showUnreadOnly,
                  onTap: () => setState(() => _showUnreadOnly = true),
                ),
              ],
            ),
          ),

          // ─── Liste ───
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = filtered[index];
                      return _NotifTile(
                        notif: notif,
                        onTap: () => context.read<NotificationProvider>().markRead(notif.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? 'Aucune notification non lue' : 'Aucune notification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous êtes à jour !',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tuile de notification
// ─────────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: notif.isRead
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Avatar / icône ───
            _NotifAvatar(notif: notif),
            const SizedBox(width: 12),

            // ─── Contenu ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.timeAgo,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar ou icône selon le type
// ─────────────────────────────────────────────────────────────
class _NotifAvatar extends StatelessWidget {
  final AppNotification notif;

  const _NotifAvatar({required this.notif});

  @override
  Widget build(BuildContext context) {
    if (notif.avatarUrl != null) {
      return Stack(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(notif.avatarUrl!)),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _typeColor(notif.type).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(_typeIcon(notif.type), size: 10, color: _typeColor(notif.type)),
            ),
          ),
        ],
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _typeColor(notif.type).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_typeIcon(notif.type), color: _typeColor(notif.type), size: 22),
    );
  }

  static IconData _typeIcon(NotifType type) {
    switch (type) {
      case NotifType.message:      return Icons.chat_rounded;
      case NotifType.mission:      return Icons.work_rounded;
      case NotifType.candidature:  return Icons.assignment_ind_rounded;
      case NotifType.payment:      return Icons.euro_rounded;
      case NotifType.review:       return Icons.star_rounded;
    }
  }

  static Color _typeColor(NotifType type) {
    switch (type) {
      case NotifType.message:     return const Color(0xFF3B82F6);
      case NotifType.mission:     return const Color(0xFF34C759);
      case NotifType.candidature: return const Color(0xFF8B5CF6);
      case NotifType.payment:     return const Color(0xFFF59E0B);
      case NotifType.review:      return const Color(0xFFFFB800);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Chip de filtre
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (badge != null && badge! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.3) : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
