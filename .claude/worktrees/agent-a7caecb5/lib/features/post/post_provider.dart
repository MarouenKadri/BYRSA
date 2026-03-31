import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/post.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/supabase_post_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - PostProvider
/// Source unique de vérité pour tous les posts du fil d'actualité.
/// ═══════════════════════════════════════════════════════════════════════════

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;

  List<Post> _posts = [];
  bool isLoading = false;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  PostProvider({PostRepository? repository})
      : _repository = repository ?? SupabasePostRepository() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _load();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _posts = [];
        notifyListeners();
      }
    });
    if (Supabase.instance.client.auth.currentUser != null) _load();
  }

  List<Post> get posts => List.unmodifiable(_posts);

  // ─── Chargement ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    _posts = await _repository.fetchPosts(_userId ?? '');
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  // ─── Créer un post ────────────────────────────────────────────────────────

  Future<Post?> createPost({
    required String content,
    required List<File> imageFiles,
  }) async {
    final userId = _userId;
    if (userId == null) return null;
    try {
      final imageUrls = await _uploadImages(userId, imageFiles);
      final post = await _repository.savePost(
        authorId: userId,
        content: content,
        imageUrls: imageUrls,
        currentUserId: userId,
      );
      _posts = [post, ..._posts];
      notifyListeners();
      return post;
    } catch (e) {
      debugPrint('createPost error: $e');
      return null;
    }
  }

  // ─── Modifier un post ─────────────────────────────────────────────────────

  Future<bool> editPost({
    required Post original,
    required String content,
    required List<File> newImageFiles,
    required List<String> existingImageUrls,
  }) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      final newUrls = await _uploadImages(userId, newImageFiles);
      final allUrls = [...existingImageUrls, ...newUrls];

      await _repository.updatePostContent(
        postId: original.id,
        content: content,
        imageUrls: allUrls,
      );

      final updated = original.copyWith(content: content, images: allUrls);
      final idx = _posts.indexWhere((p) => p.id == original.id);
      if (idx != -1) {
        final list = List<Post>.from(_posts);
        list[idx] = updated;
        _posts = list;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('editPost error: $e');
      return false;
    }
  }

  // ─── Supprimer un post ────────────────────────────────────────────────────

  void deletePost(String id) {
    _posts = _posts.where((p) => p.id != id).toList();
    notifyListeners();
    _repository.deletePost(id).catchError((e) => debugPrint('deletePost error: $e'));
  }

  // ─── Voter ────────────────────────────────────────────────────────────────

  void vote(String postId, int vote) {
    if (vote != -1 && vote != 1) return;
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final prev = post.userVote;
    final newUserVote = (vote == prev) ? 0 : vote;

    var newUpvotes = post.upvotes;
    var newDownvotes = post.downvotes;

    if (prev == 1 && newUpvotes > 0) newUpvotes--;
    else if (prev == -1 && newDownvotes > 0) newDownvotes--;

    if (newUserVote == 1) newUpvotes++;
    else if (newUserVote == -1) newDownvotes++;

    final list = List<Post>.from(_posts);
    list[index] = post.copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      userVote: newUserVote,
    );
    _posts = list;
    notifyListeners();

    final userId = _userId;
    if (userId != null) {
      _repository
          .voteOnPost(postId: postId, userId: userId, vote: newUserVote)
          .catchError((e) => debugPrint('vote error: $e'));
    }
  }

  // ─── Helper upload ────────────────────────────────────────────────────────

  Future<List<String>> _uploadImages(String userId, List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await _repository.uploadPostImage(
        userId: userId,
        imageFile: file,
      );
      urls.add(url);
    }
    return urls;
  }
}
