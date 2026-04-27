import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';

// ─── Couleurs locales luxury monochrome ──────────────────────────────────────
const _kBg          = AppColors.snow;
const _kWhite       = AppColors.surface;
const _kInk         = AppColors.ink;
const _kCharcoal    = AppColors.surfaceAlt;
const _kGrayMid     = AppColors.textTertiary;
const _kGrayLight   = AppColors.textHint;
const _kGrayXLight  = AppColors.textHint;
const _kBorder      = AppColors.divider;

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

  // Mode réservation : affiche le bouton "Réserver ce service"
  final bool showReserveButton;

  // Navigation vers le profil du contact
  final VoidCallback? onProfileTap;

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
    this.showReserveButton = false,
    this.onProfileTap,
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
  bool _missionBooked = false;

  // Patterns pour détecter les coordonnées interdites
  final List<RegExp> _forbiddenPatterns = [
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', caseSensitive: false),
    RegExp(r'(\+33|0033|0)[1-9](\s?[0-9]{2}){4}', caseSensitive: false),
    RegExp(r'\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}', caseSensitive: false),
    RegExp(r'\b(whatsapp|telegram|signal|viber|messenger|mon\s*(numéro|tel|téléphone|mail|email)|contacte[rz]?\s*moi\s*(sur|via|par)|appelle[rz]?\s*moi|sms)\b', caseSensitive: false),
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
      final error =
          await context.read<MessagingProvider>().sendMessage(text);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

  Future<void> _openReservation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PostMissionFlow()),
    );
    if (result == 'published' && mounted) {
      setState(() => _missionBooked = true);
    }
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
          GestureDetector(
            onTap: widget.onProfileTap,
            child: CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(widget.contactAvatar),
              backgroundColor: _kBorder,
            ),
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
    final showReserve = widget.showReserveButton && !_missionBooked;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16, 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: _kWhite,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showReserve) ...[
            GestureDetector(
              onTap: _openReservation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: _kInk,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Réserver ce service',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kWhite,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
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
                  // Localisation
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 11),
                    child: GestureDetector(
                      onTap: _sendLocation,
                      child: const Icon(Icons.location_on_outlined, color: _kGrayMid, size: 22),
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
        ],
      ),
    );
  }

  void _showChatOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: widget.contactName,
        dark: false,
        children: [
          if (widget.onProfileTap != null) ...[
            AppActionSheetItem(
              icon: Icons.person_outline_rounded,
              title: 'Voir le profil',
              dark: false,
              onTap: () {
                Navigator.pop(context);
                widget.onProfileTap!();
              },
            ),
          ],
          if (widget.missionTitle != null)
            AppActionSheetItem(
              icon: Icons.assignment_outlined,
              title: 'Voir la mission',
              subtitle: widget.missionTitle,
              dark: false,
              onTap: () => Navigator.pop(context),
            ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          AppActionSheetItem(
            icon: Icons.flag_outlined,
            title: 'Signaler',
            dark: false,
            destructive: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      if (mounted) showAppSnackBar(context, 'Permission de localisation refusée');
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await context.read<MessagingProvider>().sendMessage('📍 ${pos.latitude},${pos.longitude}');
      _scrollToBottom();
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Impossible d\'obtenir la position');
    }
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
            child: _isLocationMessage(message.content)
                ? _LocationBubble(
                    message: message,
                    isMe: isMe,
                  )
                : Container(
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
                        _TimeStatus(message: message, isMe: isMe),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers localisation ─────────────────────────────────────────────────────

bool _isLocationMessage(String content) {
  if (!content.startsWith('📍 ')) return false;
  final coords = content.substring(3).split(',');
  if (coords.length != 2) return false;
  return double.tryParse(coords[0].trim()) != null &&
      double.tryParse(coords[1].trim()) != null;
}

({double lat, double lng})? _parseLocation(String content) {
  try {
    final coords = content.substring(3).split(',');
    return (
      lat: double.parse(coords[0].trim()),
      lng: double.parse(coords[1].trim()),
    );
  } catch (_) {
    return null;
  }
}

// ─── Heure + statut (réutilisable) ───────────────────────────────────────────

class _TimeStatus extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _TimeStatus({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 10,
            color: isMe ? _kWhite.withValues(alpha: 0.55) : _kGrayLight,
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
    );
  }
}

// ─── Bulle localisation ───────────────────────────────────────────────────────

class _LocationBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _LocationBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final pos = _parseLocation(message.content);
    if (pos == null) return const SizedBox.shrink();

    // Image statique OpenStreetMap — aucune dépendance externe
    final mapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=${pos.lat},${pos.lng}'
        '&zoom=15&size=300x150'
        '&markers=${pos.lat},${pos.lng},red-pushpin';

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://maps.google.com/?q=${pos.lat},${pos.lng}'),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        width: 230,
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aperçu carte statique
            Stack(
              children: [
                Image.network(
                  mapUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: context.colors.surfaceAlt,
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 36,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 11, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Ouvrir', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Label + heure
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 14,
                      color: isMe ? _kWhite.withValues(alpha: 0.8) : AppColors.primary),
                  AppGap.w4,
                  Expanded(
                    child: Text(
                      'Position partagée',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isMe ? _kWhite : _kInk,
                      ),
                    ),
                  ),
                  _TimeStatus(message: message, isMe: isMe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet row ─────────────────────────────────────────────────────────

