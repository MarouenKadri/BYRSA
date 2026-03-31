import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';
import 'chat_page.dart';
import '../../../../app/app_bar/app_section_bar.dart';

class MessagesPage extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  const MessagesPage({super.key, this.onGoToAccount});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppSectionBar(pageTitle: 'Messages', onGoToAccount: widget.onGoToAccount),
      body: AppPageBody(
        child: Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingConversations) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.conversations.isEmpty) {
            return const AppEmptyStateBlock(
              icon: Icons.forum_rounded,
              title: 'Aucune conversation',
              message:
                  'Vos échanges avec vos clients\net freelancers apparaîtront ici.',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadConversations,
            color: AppColors.primary,
            child: ListView.separated(
              padding: AppInsets.v8,
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1, indent: 80, color: context.colors.divider),
              itemBuilder: (context, i) => _ConversationTile(
                conversation: provider.conversations[i],
                currentUserId: provider.currentUserId ?? '',
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;

  const _ConversationTile(
      {required this.conversation, required this.currentUserId});

  TextStyle? _nameStyle(BuildContext context, bool hasUnread) =>
      context.text.titleMedium?.copyWith(
        fontSize: AppFontSize.lg,
        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
        color: context.colors.textPrimary,
      );

  TextStyle? _metaStyle(BuildContext context, bool hasUnread) =>
      context.text.labelMedium?.copyWith(
        fontSize: AppFontSize.sm,
        color: hasUnread ? AppColors.primary : context.colors.textTertiary,
        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
      );

  TextStyle? _messageStyle(BuildContext context, bool hasUnread) =>
      context.text.bodyMedium?.copyWith(
        fontSize: AppFontSize.base,
        color: hasUnread
            ? context.colors.textPrimary
            : context.colors.textSecondary,
        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
      );

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversation.id,
            contactName: conversation.otherUserName,
            contactAvatar: conversation.otherUserAvatar ??
                'https://api.dicebear.com/7.x/avataaars/png?seed=${conversation.otherUserId}',
            isVerified: conversation.isOtherVerified,
            missionTitle: conversation.missionTitle,
          ),
        ),
      ).then((_) {
        if (context.mounted) context.read<MessagingProvider>().loadConversations();
      }),
      child: Padding(
        padding: AppInsets.h16v12,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                conversation.otherUserAvatar ??
                    'https://api.dicebear.com/7.x/avataaars/png?seed=${conversation.otherUserId}',
              ),
            ),
            AppGap.w14,
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: _nameStyle(context, hasUnread),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: _metaStyle(context, hasUnread),
                        ),
                    ],
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      if (conversation.missionTitle != null) ...[
                        AppTagPill(
                          label: conversation.missionTitle!,
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          fontSize: AppFontSize.xs,
                          fontWeight: FontWeight.w600,
                        ),
                        AppGap.w6,
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'Démarrez la conversation',
                          style: _messageStyle(context, hasUnread),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        AppCountBadge(
                          label: '${conversation.unreadCount}',
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 6) return '${time.day}/${time.month}';
    if (diff.inDays >= 1) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[time.weekday - 1];
    }
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
