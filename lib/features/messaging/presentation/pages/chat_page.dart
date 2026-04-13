import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';

// ─── Couleurs locales luxury monochrome ──────────────────────────────────────
const _kBg          = AppColors.snow;
const _kWhite       = Colors.white;
const _kInk         = Color(0xFF0D0D0D);
const _kCharcoal    = Color(0xFF2C2C2C);
const _kGrayMid     = Color(0xFF8A8A8A);
const _kGrayLight   = Color(0xFFBBBBBB);
const _kGrayXLight  = Color(0xFFCCCCCC);
const _kBorder      = Color(0xFFEEEEEE);

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
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', caseSensitive: false),
    RegExp(r'(\+33|0033|0)[1-9](\s?[0-9]{2}){4}', caseSensitive: false),
    RegExp(r'\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}', caseSensitive: false),
    RegExp(r'\b(whatsapp|telegram|signal|viber|messenger|mon\s*(numéro|tel|téléphone|mail|email)|contacte[rz]?\s*moi\s*(sur|via|par)|appelle[rz]?\s*moi|envoie|sms)\b', caseSensitive: false),
    RegExp(r'\b(gmail|yahoo|hotmail|outlook|orange|sfr|free|wanadoo)\b', caseSensitive: false),
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try { context.read<MessagingProvider>().closeConversation(); } catch (_) {}
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
    showAppDialog(
      context: context,
      title: const Text('Accepter ce prestataire ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: context.text.bodyMedium?.copyWith(color: _kCharcoal),
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
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
                const TextSpan(text: '.'),
              ],
            ),
          ),
          AppGap.h12,
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppColors.warning),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Les autres candidats seront automatiquement refusés.',
                    style: context.text.bodySmall?.copyWith(fontSize: AppFontSize.md),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Confirmer',
      onConfirm: () {
        Navigator.pop(context);
        _confirmAcceptance();
      },
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
      backgroundColor: _kBg,
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

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: _kBorder),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kInk, size: 18),
        onPressed: () => Navigator.pop(context, _candidateAccepted),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundImage: NetworkImage(widget.contactAvatar),
            backgroundColor: _kBorder,
          ),
          AppGap.w12,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kInk,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      AppGap.w4,
                      const Icon(Icons.verified_rounded, size: 14, color: _kInk),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  widget.isOnline ? 'En ligne' : 'Vu récemment',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _kGrayLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: _kInk, size: 22),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  // ─── Mission banner ───────────────────────────────────────────────────────

  Widget _buildMissionBanner() {
    final bool showAcceptButton = widget.candidateMode && !_candidateAccepted;

    final summaryParts = <String>[
      if (widget.missionTitle != null) widget.missionTitle!,
      if (widget.candidatePrice != null)
        _candidateAccepted ? '✓ Prestataire choisi • ${widget.candidatePrice}' : widget.candidatePrice!,
    ];
    final summaryText = summaryParts.join(' • ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              summaryText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kCharcoal,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showAcceptButton) ...[
            AppGap.w12,
            GestureDetector(
              onTap: _acceptCandidateFromChat,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _kInk,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Accepter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kWhite,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Contact warning ──────────────────────────────────────────────────────

  Widget _buildContactWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: AppInsets.h16v12,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
          AppGap.w10,
          Expanded(
            child: Text(
              'Le partage de coordonnées personnelles n\'est pas autorisé.',
              style: TextStyle(
                fontSize: AppFontSize.sm,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showContactWarning = false),
            child: Icon(Icons.close_rounded, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }

  // ─── Message list ─────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    if (widget.conversationId != null) {
      return Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingMessages) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: _kGrayMid,
              ),
            );
          }
          final messages = provider.currentMessages;
          final currentUserId = provider.currentUserId ?? '';
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          return GestureDetector(
            onTap: () => _focusNode.unfocus(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.isMe(currentUserId);
                final showAvatar = !isMe && (index == 0 || messages[index - 1].isMe(currentUserId));
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
        child: Text(
          'Démarrez la conversation',
          style: TextStyle(
            fontSize: AppFontSize.base,
            fontWeight: FontWeight.w300,
            color: _kGrayXLight,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  // ─── Input area ───────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final isForbidden = hasText && _containsForbiddenContent(_messageController.text);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16, 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: _kWhite,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pill input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: _kWhite,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kBorder, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // '+' icon
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 11),
                    child: GestureDetector(
                      onTap: _showAttachmentOptions,
                      child: const Icon(Icons.add_rounded, color: _kGrayLight, size: 20),
                    ),
                  ),
                  // TextField
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _kInk,
                        height: 1.45,
                      ),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: 'Votre message...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _kGrayXLight,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                        noBorder: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (_containsForbiddenContent(value)) _showForbiddenContentAlert();
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  // Emoji icon
                  Padding(
                    padding: const EdgeInsets.only(right: 14, bottom: 11),
                    child: Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: _kGrayLight,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Send button — apparaît uniquement en cas de saisie
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: hasText
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isForbidden ? AppColors.error : _kInk,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isForbidden ? Icons.block_rounded : Icons.arrow_upward_rounded,
                          color: _kWhite,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) {
        final bottomPad = MediaQuery.of(ctx).padding.bottom;
        return Container(
          decoration: const BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(18, 0, 18, 18 + bottomPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              // Rows container
              Container(
                decoration: BoxDecoration(
                  color: _kWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _kBorder, width: 0.8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ChatSheetRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Voir le profil',
                      onTap: () => Navigator.pop(ctx),
                    ),
                    if (widget.missionTitle != null) ...[
                      const _ChatSheetDivider(),
                      _ChatSheetRow(
                        icon: Icons.assignment_outlined,
                        label: 'Voir la mission',
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ],
                    const _ChatSheetDivider(),
                    _ChatSheetRow(
                      icon: Icons.flag_outlined,
                      label: 'Signaler',
                      labelColor: const Color(0xFFB45C5C),
                      trailingColor: const Color(0xFFB45C5C),
                      onTap: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Bouton Fermer
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _kBorder, width: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _kGrayMid,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) {
        return AppPickerSheet(
          title: 'Pièces jointes',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRoundIconTile(
                icon: Icons.image_rounded,
                iconColor: AppColors.primary,
                title: 'Photo',
                subtitle: 'Envoyer une image',
                onTap: () => Navigator.pop(ctx),
              ),
              Divider(height: 1, color: ctx.colors.divider, indent: 16, endIndent: 16),
              AppRoundIconTile(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.primary,
                title: 'Caméra',
                subtitle: 'Prendre une photo',
                onTap: () => Navigator.pop(ctx),
              ),
              Divider(height: 1, color: ctx.colors.divider, indent: 16, endIndent: 16),
              AppRoundIconTile(
                icon: Icons.insert_drive_file_rounded,
                iconColor: AppColors.primary,
                title: 'Document',
                subtitle: 'Partager un fichier',
                onTap: () => Navigator.pop(ctx),
              ),
              Divider(height: 1, color: ctx.colors.divider, indent: 16, endIndent: 16),
              AppRoundIconTile(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.primary,
                title: 'Position',
                subtitle: 'Partager votre localisation',
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
          footer: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16 + MediaQuery.of(ctx).padding.bottom),
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Text(
                'Fermer',
                style: ctx.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w500,
                  color: ctx.colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Bulle message ────────────────────────────────────────────────────────────

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
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _kBorder,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kGrayMid,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 3,
        bottom: 3,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            showAvatar
                ? CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(contactAvatar),
                    backgroundColor: _kBorder,
                  )
                : const SizedBox(width: 30),
          if (!isMe) AppGap.w6,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _kInk : _kWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isMe ? _kWhite : _kInk,
                      height: 1.45,
                    ),
                  ),
                  AppGap.h3,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? _kWhite.withValues(alpha: 0.55)
                              : _kGrayLight,
                        ),
                      ),
                      if (isMe) ...[
                        AppGap.w4,
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 13,
                          color: message.status == MessageStatus.read
                              ? _kWhite
                              : _kWhite.withValues(alpha: 0.45),
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

// ─── Bottom sheet row ─────────────────────────────────────────────────────────

class _ChatSheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? trailingColor;
  final VoidCallback onTap;

  const _ChatSheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? _kInk;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: trailingColor ?? _kGrayLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatSheetDivider extends StatelessWidget {
  const _ChatSheetDivider();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        color: _kBorder,
        indent: 18,
        endIndent: 18,
      );
}
