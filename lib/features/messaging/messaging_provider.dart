import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/message.dart';
import 'data/repositories/messaging_repository.dart';
import 'data/repositories/supabase_messaging_repository.dart';
import 'data/services/message_moderation_service.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repo;
  final SupabaseClient _supabase;
  final MessageModerationService _moderationService;

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  final Map<String, List<ChatMessage>> _messagesCache = {};
  String? currentConversationId;
  bool isLoadingConversations = false;
  bool isLoadingMessages = false;
  int _conversationLoadToken = 0;
  int _messageLoadToken = 0;
  bool _isClientMode = true;

  RealtimeChannel? _messagesChannel;
  StreamSubscription<AuthState>? _authSub;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<ChatMessage> get currentMessages => List.unmodifiable(_currentMessages);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  MessagingProvider({
    MessagingRepository? repository,
    SupabaseClient? supabaseClient,
    MessageModerationService? moderationService,
  }) : _repo = repository ?? SupabaseMessagingRepository(),
        _supabase = supabaseClient ?? Supabase.instance.client,
        _moderationService =
            moderationService ?? MessageModerationService.instance {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _resetState();
      }
    });
  }

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<void> loadConversations({bool forceRefresh = false, bool? isClientMode}) async {
    final userId = currentUserId;
    if (userId == null) return;
    if (isLoadingConversations && !forceRefresh) return;

    if (isClientMode != null) _isClientMode = isClientMode;

    final loadToken = ++_conversationLoadToken;
    _setConversationsLoading(true);

    final conversations = await _repo.getConversations(userId, isClientMode: _isClientMode);
    if (loadToken != _conversationLoadToken) return;

    _conversations = conversations;
    _setConversationsLoading(false);
  }

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  // ─── Messages (current conversation) ─────────────────────────────────────

  Future<void> openConversation(
    String conversationId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && currentConversationId == conversationId) {
      if (_messagesChannel == null) {
        _subscribeToMessages(conversationId);
      }
      return;
    }

    final hasCachedMessages = _messagesCache.containsKey(conversationId);
    currentConversationId = conversationId;
    _unsubscribe();

    if (hasCachedMessages && !forceRefresh) {
      _currentMessages = List<ChatMessage>.from(_messagesCache[conversationId]!);
      isLoadingMessages = false;
      notifyListeners();
      unawaited(_markConversationAsRead(conversationId));
      _subscribeToMessages(conversationId);
      return;
    }

    final loadToken = ++_messageLoadToken;
    _currentMessages = [];
    isLoadingMessages = true;
    notifyListeners();

    final messages = await _repo.getMessages(conversationId);
    if (loadToken != _messageLoadToken || currentConversationId != conversationId) {
      return;
    }

    _storeMessages(conversationId, messages);
    isLoadingMessages = false;
    notifyListeners();

    unawaited(_markConversationAsRead(conversationId));
    _subscribeToMessages(conversationId);
  }

  void closeConversation() {
    _unsubscribe();
    _messageLoadToken++;
    currentConversationId = null;
    _currentMessages = [];
    isLoadingMessages = false;
    notifyListeners();
  }

  Future<String?> sendMessage(String content) async {
    final userId = currentUserId;
    final conversationId = currentConversationId;
    if (userId == null || conversationId == null) return 'Non connecté';

    final moderation = _moderationService.check(content);
    if (moderation.blocked) return moderation.reason;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderId: userId,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    _appendMessage(conversationId, optimistic);

    final sent = await _repo.sendMessage(conversationId, userId, content);
    if (sent == null) {
      _replaceMessage(
        conversationId,
        tempId,
        optimistic.copyWith(status: MessageStatus.failed),
      );
      return 'Erreur lors de l\'envoi';
    }

    _replaceMessage(conversationId, tempId, sent);

    _syncConversationPreview(
      conversationId,
      lastMessage: content,
      lastMessageAt: sent.createdAt,
      unreadCount: 0,
    );
    unawaited(_repo.updateConversationLastMessage(conversationId, content));

    return null;
  }

  Future<String?> getOrCreateConversation({
    required String otherUserId,
    required bool iAmClient,
    String? missionId,
  }) async {
    // Messaging can only be initiated from the client side.
    if (!iAmClient) return null;

    final userId = currentUserId;
    if (userId == null) return null;

    // Empêcher l'auto-conversation (client == freelancer).
    if (userId == otherUserId) return null;

    final clientId = iAmClient ? userId : otherUserId;
    final freelancerId = iAmClient ? otherUserId : userId;
    return _repo.getOrCreateConversation(
      clientId: clientId,
      freelancerId: freelancerId,
      missionId: missionId,
    );
  }

  Future<String?> findConversation({
    required String otherUserId,
    required bool iAmClient,
    String? missionId,
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;
    final clientId = iAmClient ? userId : otherUserId;
    final freelancerId = iAmClient ? otherUserId : userId;
    return _repo.findConversation(
      clientId: clientId,
      freelancerId: freelancerId,
      missionId: missionId,
    );
  }

  // ─── Real-time ────────────────────────────────────────────────────────────

  void _subscribeToMessages(String conversationId) {
    _unsubscribe();
    _messagesChannel = _supabase
        .channel('messages_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final userId = currentUserId ?? '';
            final newMsg = ChatMessage.fromJson(
              payload.newRecord,
              userId,
            );

            // Si ce message est déjà dans la liste (UUID connu), ignorer.
            if (_hasMessage(conversationId, newMsg.id)) return;

            final isFromCurrentUser = newMsg.senderId == userId;

            if (isFromCurrentUser) {
              // Chercher un message optimiste (temp_*) avec le même contenu
              // en état "sending" — le Realtime est arrivé avant _replaceMessage.
              final tempId = _messagesFor(conversationId)
                  .where((m) =>
                      m.id.startsWith('temp_') &&
                      m.content == newMsg.content &&
                      m.status == MessageStatus.sending)
                  .map((m) => m.id)
                  .firstOrNull;
              if (tempId != null) {
                // Remplace l'optimiste par le vrai message (status=sent).
                _replaceMessage(conversationId, tempId, newMsg);
              } else {
                _appendMessage(conversationId, newMsg, notify: false);
              }
            } else {
              // Message d'un autre utilisateur : notifier l'UI immédiatement.
              _appendMessage(conversationId, newMsg);
              unawaited(_markConversationAsRead(conversationId));
            }

            _syncConversationPreview(
              conversationId,
              lastMessage: newMsg.content,
              lastMessageAt: newMsg.createdAt,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final userId = currentUserId ?? '';
            final updatedMsg = ChatMessage.fromJson(
              payload.newRecord,
              userId,
            );
            if (!_hasMessage(conversationId, updatedMsg.id)) return;

            _mergeMessage(conversationId, updatedMsg);
          },
        )
        .subscribe();
  }

  void _resetState() {
    _unsubscribe();
    _conversationLoadToken++;
    _messageLoadToken++;
    _conversations = [];
    _currentMessages = [];
    _messagesCache.clear();
    currentConversationId = null;
    isLoadingConversations = false;
    isLoadingMessages = false;
    notifyListeners();
  }

  void _setConversationsLoading(bool value) {
    if (isLoadingConversations == value) return;
    isLoadingConversations = value;
    notifyListeners();
  }

  void _storeMessages(String conversationId, List<ChatMessage> messages) {
    final copy = List<ChatMessage>.from(messages);
    _messagesCache[conversationId] = copy;
    if (currentConversationId == conversationId) {
      _currentMessages = List<ChatMessage>.from(copy);
    }
  }

  List<ChatMessage> _messagesFor(String conversationId) {
    if (currentConversationId == conversationId) {
      return _currentMessages;
    }
    return _messagesCache[conversationId] ?? const [];
  }

  bool _hasMessage(String conversationId, String messageId) {
    return _messagesFor(conversationId).any((m) => m.id == messageId);
  }

  void _appendMessage(
    String conversationId,
    ChatMessage message, {
    bool notify = true,
  }) {
    final updated = [..._messagesFor(conversationId), message];
    _storeMessages(conversationId, updated);
    if (notify) notifyListeners();
  }

  void _removeMessage(
    String conversationId,
    String messageId, {
    bool notify = true,
  }) {
    final updated = _messagesFor(
      conversationId,
    ).where((m) => m.id != messageId).toList(growable: false);
    _storeMessages(conversationId, updated);
    if (notify) notifyListeners();
  }

  void _replaceMessage(
    String conversationId,
    String previousMessageId,
    ChatMessage message, {
    bool notify = true,
  }) {
    final updated = _messagesFor(conversationId)
        .map((m) => m.id == previousMessageId ? message : m)
        .toList(growable: false);
    _storeMessages(conversationId, updated);
    if (notify) notifyListeners();
  }

  void _mergeMessage(
    String conversationId,
    ChatMessage message, {
    bool notify = true,
  }) {
    final updated = _messagesFor(conversationId)
        .map((m) => m.id == message.id ? message : m)
        .toList(growable: false);
    _storeMessages(conversationId, updated);
    if (notify) notifyListeners();
  }

  Future<void> _markConversationAsRead(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    // Mettre à jour localement les messages reçus (non envoyés par moi)
    // en status=read pour un retour visuel immédiat chez l'expéditeur
    // via Realtime UPDATE (maintenant activé grâce à REPLICA IDENTITY FULL).
    final updated = _messagesFor(conversationId).map((m) {
      if (m.senderId != userId &&
          m.status != MessageStatus.read &&
          !m.id.startsWith('temp_')) {
        return m.copyWith(status: MessageStatus.read);
      }
      return m;
    }).toList(growable: false);
    _storeMessages(conversationId, updated);

    _syncConversationPreview(
      conversationId,
      unreadCount: 0,
      preservePosition: true,
    );
    await _repo.markAsRead(conversationId, userId);
  }

  void _syncConversationPreview(
    String conversationId, {
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool preservePosition = false,
  }) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final current = _conversations[index];
    final updated = current.copyWith(
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
    final valuesChanged =
        updated.lastMessage != current.lastMessage ||
        updated.lastMessageAt != current.lastMessageAt ||
        updated.unreadCount != current.unreadCount;
    if (!valuesChanged && (preservePosition || index == 0)) return;

    final next = List<Conversation>.from(_conversations);
    if (preservePosition) {
      next[index] = updated;
    } else {
      next.removeAt(index);
      next.insert(0, updated);
    }
    _conversations = next;
    notifyListeners();
  }

  void _unsubscribe() {
    _messagesChannel?.unsubscribe();
    _messagesChannel = null;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _unsubscribe();
    super.dispose();
  }
}
