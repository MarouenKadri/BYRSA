import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'post_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - SupabasePostRepository
///
/// Table SQL requise :
///   posts       : id, author_id, content, images[], upvotes, downvotes, created_at
///   post_votes  : post_id, user_id, vote (PK composite)
///   Storage bucket "post-images" (public)
/// ═══════════════════════════════════════════════════════════════════════════

class SupabasePostRepository implements PostRepository {
  final _supabase = Supabase.instance.client;

  static const String _select =
      '*, author:profiles!author_id(first_name, last_name, avatar_url, user_type), '
      'votes:post_votes(user_id, vote)';

  // ─── Fetch ───────────────────────────────────────────────────────────────

  @override
  Future<List<Post>> fetchPosts(String currentUserId) async {
    try {
      final data = await _supabase
          .from('posts')
          .select(_select)
          .order('created_at', ascending: false);
      return data.map<Post>((j) => Post.fromJson(j, currentUserId)).toList();
    } catch (e) {
      debugPrint('fetchPosts error: $e');
      return [];
    }
  }

  // ─── Créer ───────────────────────────────────────────────────────────────

  @override
  Future<Post> savePost({
    required String authorId,
    required String content,
    required List<String> imageUrls,
    required String currentUserId,
  }) async {
    final data = await _supabase
        .from('posts')
        .insert({'author_id': authorId, 'content': content, 'images': imageUrls})
        .select(_select)
        .single();
    return Post.fromJson(data, currentUserId);
  }

  // ─── Modifier ────────────────────────────────────────────────────────────

  @override
  Future<void> updatePostContent({
    required String postId,
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      await _supabase
          .from('posts')
          .update({'content': content, 'images': imageUrls})
          .eq('id', postId);
    } catch (e) {
      debugPrint('updatePostContent error: $e');
      rethrow;
    }
  }

  // ─── Supprimer ───────────────────────────────────────────────────────────

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      debugPrint('deletePost error: $e');
      rethrow;
    }
  }

  // ─── Vote ─────────────────────────────────────────────────────────────────

  @override
  Future<void> voteOnPost({
    required String postId,
    required String userId,
    required int vote,
  }) async {
    try {
      if (vote == 0) {
        await _supabase
            .from('post_votes')
            .delete()
            .match({'post_id': postId, 'user_id': userId});
      } else {
        await _supabase.from('post_votes').upsert(
          {'post_id': postId, 'user_id': userId, 'vote': vote == 1 ? 'up' : 'down'},
          onConflict: 'post_id,user_id',
        );
      }
    } catch (e) {
      debugPrint('voteOnPost error: $e');
    }
  }

  // ─── Upload image ─────────────────────────────────────────────────────────

  @override
  Future<String> uploadPostImage({
    required String userId,
    required File imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from('post-images').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );
    return _supabase.storage.from('post-images').getPublicUrl(path);
  }
}
