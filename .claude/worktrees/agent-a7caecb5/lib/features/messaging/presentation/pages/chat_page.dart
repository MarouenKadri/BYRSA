import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';

class ChatPage extends StatefulWidget {
  final String? conversationId;
  final String contactName;
  final String contactAvatar;
  final bool isOnline;
  final bool isVerified;
  final String? missionTitle;

  // Mode candidat : permet d'accepter depuis le chat
  final bool candidateMode;
  final String? candidatePrice;
  final VoidCallback? onAcceptCandidate;

  const ChatPage({
    super.key,
    this.conversationId,
    required this.contactName,
    required this.contactAvatar,
    this.isOnline = false,
    this.isVerified = false,
    this.missionTitle,
    this.candidateMode = false,
    this.candidatePrice,
    this.onAcceptCandidate,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _showContactWarning = false;
  bool _candidateAccepted = false;

  // Patterns pour détecter les coordonnées interdites
  final List<RegExp> _forbiddenPatterns = [
    // Email
    RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    ),
    // Téléphone français (06, 07, +33, etc.)
    RegExp(r'(\+33|0033|0)[1-9](\s?[0-9]{2}){4}', caseSensitive: false),
    RegExp(
      r'\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}',
      caseSensitive: false,
    ),
    // Mots clés suspects
    RegExp(
      r'\b(whatsapp|telegram|signal|viber|messenger|mon\s*(numéro|tel|téléphone|mail|email)|contacte[rz]?\s*moi\s*(sur|via|par)|appelle[rz]?\s*moi|envoie|sms)\b',
      caseSensitive: false,
    ),
    // Domaines email courants
    RegExp(
      r'\b(gmail|yahoo|hotmail|outlook|orange|sfr|free|wanadoo)\b',
      caseSensitive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MessagingProvider>().openConversation(widget.conversationId!);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    if (widget.conversationId != null) {
      // Use a post-frame callback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Provider may already be disposed, guard with try/catch
        try {
          context.read<MessagingProvider>().closeConversation();
        } catch (_) {}
      });
    }
    super.dispose();
  }

  bool _containsForbiddenContent(String text) {
    for (final pattern in _forbiddenPatterns) {
      if (pattern.hasMatch(text)) return true;
    }
    return false;
  }

  void _showForbiddenContentAlert() {
    setState(() => _showContactWarning = true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showContactWarning = false);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_containsForbiddenContent(text)) {
      _showForbiddenContentAlert();
      return;
    }

    _messageController.clear();

    if (widget.conversationId != null) {
      await context.read<MessagingProvider>().sendMessage(text);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _acceptCandidateFromChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        title: const Text('Accepter ce prestataire ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                children: [
                  const TextSpan(text: 'Vous allez accepter '),
                  TextSpan(
                    text: widget.contactName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (widget.candidatePrice != null) ...[
                    const TextSpan(text: ' pour '),
                    TextSpan(
                      text: widget.candidatePrice,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 20, color: Color(0xFFFF9500)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les autres candidats seront automatiquement refusés.',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAcceptance();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small)),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _confirmAcceptance() {
    setState(() => _candidateAccepted = true);
    widget.onAcceptCandidate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (widget.missionTitle != null) _buildMissionBanner(),
          if (_showContactWarning) _buildContactWarning(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (widget.conversationId != null) {
      return Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingMessages) {
            return const Center(child: CircularProgressIndicator());
          }
          final messages = provider.currentMessages;
          final currentUserId = provider.currentUserId ?? '';
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
          return GestureDetector(
            onTap: () => _focusNode.unfocus(),
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.isMe(currentUserId);
                final showAvatar = !isMe &&
                    (index == 0 || messages[index - 1].isMe(currentUserId));
                return _MessageBubbleFromModel(
                  message: msg,
                  isMe: isMe,
                  showAvatar: showAvatar,
                  contactAvatar: widget.contactAvatar,
                );
              },
            ),
          );
        },
      );
    }

    // Demo mode — no conversationId
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text('Démarrez la conversation',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context, _candidateAccepted),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.contactAvatar),
              ),
              if (widget.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.contactName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ],
                ),
                Text(
                  widget.isOnline ? 'En ligne' : 'Vu récemment',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isOnline
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.input)),
          onSelected: (_) {},
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('Voir le profil')),
            if (widget.missionTitle != null)
              const PopupMenuItem(
                  value: 'mission', child: Text('Voir la mission')),
            const PopupMenuItem(
                value: 'report',
                child: Text('Signaler',
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionBanner() {
    final bool showAcceptButton = widget.candidateMode && !_candidateAccepted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _candidateAccepted ? AppColors.verifiedBg : AppColors.lightBlue,
        border: _candidateAccepted
            ? Border(
                bottom:
                    BorderSide(color: AppColors.primary.withOpacity(0.3)))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            _candidateAccepted
                ? Icons.check_circle_rounded
                : Icons.assignment_rounded,
            size: 20,
            color:
                _candidateAccepted ? AppColors.primary : AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.missionTitle!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        _candidateAccepted ? AppColors.primary : AppColors.info,
                  ),
                ),
                if (widget.candidatePrice != null)
                  Text(
                    _candidateAccepted
                        ? '✓ Prestataire choisi • ${widget.candidatePrice}'
                        : 'Tarif proposé : ${widget.candidatePrice}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _candidateAccepted
                          ? AppColors.primary
                          : AppColors.info,
                      fontWeight: _candidateAccepted
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          if (showAcceptButton)
            OutlinedButton(
              onPressed: _acceptCandidateFromChat,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.cardLg)),
              ),
              child: const Text('Accepter',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildContactWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: AppColors.error.withOpacity(0.08),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partage de coordonnées interdit',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pour votre sécurité, le partage de coordonnées personnelles n\'est pas autorisé.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.error, height: 1.3),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _showContactWarning = false),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration:
          BoxDecoration(color: Colors.white, boxShadow: AppShadows.card),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded,
                color: AppColors.textSecondary),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Votre message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (_containsForbiddenContent(value)) {
                          _showForbiddenContentAlert();
                        }
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: _messageController.text.trim().isNotEmpty
                ? CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _containsForbiddenContent(_messageController.text)
                            ? Colors.red
                            : AppColors.primary,
                    child: IconButton(
                      icon: Icon(
                        _containsForbiddenContent(_messageController.text)
                            ? Icons.block_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: _sendMessage,
                    ),
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () {},
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachmentOption(
                    icon: Icons.image_rounded,
                    label: 'Photo',
                    color: Colors.purple,
                    onTap: () => Navigator.pop(context)),
                _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Caméra',
                    color: Colors.pink,
                    onTap: () => Navigator.pop(context)),
                _AttachmentOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: AppColors.info,
                    onTap: () => Navigator.pop(context)),
                _AttachmentOption(
                    icon: Icons.location_on_rounded,
                    label: 'Position',
                    color: AppColors.success,
                    onTap: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}

// ─── Bulle message depuis model Supabase ────────────────────────────────────
class _MessageBubbleFromModel extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String contactAvatar;

  const _MessageBubbleFromModel({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.contactAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.verifiedBg,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border:
              Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
          top: 4, bottom: 4, left: isMe ? 60 : 0, right: isMe ? 0 : 60),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            showAvatar
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(contactAvatar),
                  )
                : const SizedBox(width: 32),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white70
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option d'attachment ─────────────────────────────────────────────────────
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
