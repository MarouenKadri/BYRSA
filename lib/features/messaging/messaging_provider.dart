import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/message.dart';
import 'data/repositories/messaging_repository.dart';
import 'data/repositories/supabase_messaging_repository.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repo = SupabaseMessagingRepository();
  final _supabase = Supabase.instance.client;

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  String? currentConversationId;
  bool isLoadingConversations = false;
  bool isLoadingMessages = false;

  RealtimeChannel? _messagesChannel;
  StreamSubscription<AuthState>? _authSub;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<ChatMessage> get currentMessages => List.unmodifiable(_currentMessages);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  MessagingProvider() {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _unsubscribe();
        _conversations = [];
        _currentMessages = [];
        currentConversationId = null;
        notifyListeners();
      }
    });
  }

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<void> loadConversations() async {
    final userId = currentUserId;
    if (userId == null) return;
    isLoadingConversations = true;
    notifyListeners();
    _conversations = await _repo.getConversations(userId);
    isLoadingConversations = false;
    notifyListeners();
  }

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  // ─── Messages (current conversation) ─────────────────────────────────────

  Future<void> openConversation(String conversationId) async {
    if (currentConversationId == conversationId) return;
    currentConversationId = conversationId;
    isLoadingMessages = true;
    notifyListeners();

    _currentMessages = await _repo.getMessages(conversationId);
    isLoadingMessages = false;
    notifyListeners();

    // Mark as read
    final userId = currentUserId;
    if (userId != null) await _repo.markAsRead(conversationId, userId);

    // Subscribe to real-time
    _subscribeToMessages(conversationId);
  }

  void closeConversation() {
    _unsubscribe();
    currentConversationId = null;
    _currentMessages = [];
  }

  Future<String?> sendMessage(String content) async {
    final userId = currentUserId;
    if (userId == null || currentConversationId == null) return 'Non connecté';

    // Optimistic update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: currentConversationId!,
      senderId: userId,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    _currentMessages = [..._currentMessages, optimistic];
    notifyListeners();

    final sent = await _repo.sendMessage(currentConversationId!, userId, content);
    if (sent == null) {
      _currentMessages = _currentMessages.where((m) => m.id != tempId).toList();
      notifyListeners();
      return 'Erreur lors de l\'envoi';
    }

    // Replace optimistic with real message
    _currentMessages = [
      ..._currentMessages.where((m) => m.id != tempId),
      sent,
    ];
    notifyListeners();

    // Update conversation last_message
    unawaited(_repo.updateConversationLastMessage(currentConversationId!, content));

    // Refresh conversation list in memory
    final convIndex =
        _conversations.indexWhere((c) => c.id == currentConversationId);
    if (convIndex != -1) {
      final updated = _conversations[convIndex].copyWith(
        lastMessage: content,
        lastMessageAt: DateTime.now(),
      );
      final updated_ = List<Conversation>.from(_conversations);
      updated_[convIndex] = updated;
      _conversations = updated_;
      notifyListeners();
    }

    return null;
  }

  Future<String?> getOrCreateConversation({
    required String otherUserId,
    required bool iAmClient,
    String? missionId,
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;
    final clientId = iAmClient ? userId : otherUserId;
    final freelancerId = iAmClient ? otherUserId : userId;
    return _repo.getOrCreateConversation(
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
            // Avoid duplicate (already added via optimistic)
            if (!_currentMessages.any((m) => m.id == newMsg.id)) {
              _currentMessages = [..._currentMessages, newMsg];
              notifyListeners();
              // Mark as read immediately if it's from the other person
              if (newMsg.senderId != userId) {
                _repo.markAsRead(conversationId, userId);
              }
            }
          },
        )
        .subscribe();
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
