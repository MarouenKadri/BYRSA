import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import 'messaging_repository.dart';

class SupabaseMessagingRepository implements MessagingRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Conversation>> getConversations(String userId) async {
    try {
      final rows = await _supabase
          .from('conversations')
          .select('*, missions(title)')
          .or('client_id.eq.$userId,freelancer_id.eq.$userId')
          .order('last_message_at', ascending: false);

      final List<Conversation> result = [];
      for (final row in rows as List) {
        final isClient = row['client_id'] == userId;
        final otherUserId =
            isClient ? row['freelancer_id'] as String : row['client_id'] as String;

        // Fetch other user's profile
        String otherName = 'Utilisateur';
        String? otherAvatar;
        try {
          final profile = await _supabase
              .from('profiles')
              .select('first_name, last_name, avatar_url')
              .eq('id', otherUserId)
              .single();
          otherName =
              '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
          otherAvatar = profile['avatar_url'] as String?;
        } catch (_) {}

        // Count unread messages
        int unreadCount = 0;
        try {
          final countResult = await _supabase
              .from('messages')
              .select('id')
              .eq('conversation_id', row['id'] as String)
              .eq('is_read', false)
              .neq('sender_id', userId);
          unreadCount = (countResult as List).length;
        } catch (_) {}

        final missionData = row['missions'] as Map<String, dynamic>?;
        result.add(Conversation(
          id: row['id'] as String,
          clientId: row['client_id'] as String,
          freelancerId: row['freelancer_id'] as String,
          missionId: row['mission_id'] as String?,
          missionTitle: missionData?['title'] as String?,
          lastMessage: row['last_message'] as String?,
          lastMessageAt: row['last_message_at'] != null
              ? DateTime.parse(row['last_message_at'] as String)
              : null,
          unreadCount: unreadCount,
          otherUserId: otherUserId,
          otherUserName: otherName.isEmpty ? 'Utilisateur' : otherName,
          otherUserAvatar: otherAvatar,
        ));
      }
      return result;
    } catch (e) {
      debugPrint('getConversations error: $e');
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id ?? '';
      final rows = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return (rows as List)
          .map((r) => ChatMessage.fromJson(r as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (e) {
      debugPrint('getMessages error: $e');
      return [];
    }
  }

  @override
  Future<ChatMessage?> sendMessage(
      String conversationId, String senderId, String content) async {
    try {
      final row = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'is_read': false,
      }).select().single();
      return ChatMessage.fromJson(row, senderId);
    } catch (e) {
      debugPrint('sendMessage error: $e');
      return null;
    }
  }

  @override
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) async {
    try {
      // Check if conversation already exists
      var query = _supabase
          .from('conversations')
          .select('id')
          .eq('client_id', clientId)
          .eq('freelancer_id', freelancerId);

      if (missionId != null) {
        query = query.eq('mission_id', missionId);
      }

      final existing = await query.maybeSingle();
      if (existing != null) return existing['id'] as String;

      // Create new conversation
      final data = <String, dynamic>{
        'client_id': clientId,
        'freelancer_id': freelancerId,
      };
      if (missionId != null) data['mission_id'] = missionId;

      final row =
          await _supabase.from('conversations').insert(data).select('id').single();
      return row['id'] as String;
    } catch (e) {
      debugPrint('getOrCreateConversation error: $e');
      return null;
    }
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  @override
  Future<void> updateConversationLastMessage(
      String conversationId, String lastMessage) async {
    try {
      await _supabase.from('conversations').update({
        'last_message': lastMessage,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
    } catch (e) {
      debugPrint('updateConversationLastMessage error: $e');
    }
  }
}
