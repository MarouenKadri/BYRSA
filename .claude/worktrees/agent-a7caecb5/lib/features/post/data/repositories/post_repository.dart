import 'dart:io';
import '../models/post.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - PostRepository (interface async)
/// ═══════════════════════════════════════════════════════════════════════════

abstract class PostRepository {
  Future<List<Post>> fetchPosts(String currentUserId);

  Future<Post> savePost({
    required String authorId,
    required String content,
    required List<String> imageUrls,
    required String currentUserId,
  });

  Future<void> updatePostContent({
    required String postId,
    required String content,
    required List<String> imageUrls,
  });

  Future<void> deletePost(String postId);

  Future<void> voteOnPost({
    required String postId,
    required String userId,
    required int vote,
  });

  Future<String> uploadPostImage({
    required String userId,
    required File imageFile,
  });
}
