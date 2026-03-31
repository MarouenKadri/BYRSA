import '../models/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations(String userId);
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage?> sendMessage(
      String conversationId, String senderId, String content);
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  });
  Future<void> markAsRead(String conversationId, String userId);
  Future<void> updateConversationLastMessage(
      String conversationId, String lastMessage);
}
