/// ─────────────────────────────────────────────────────────────
/// 📦 Inkern - Modèle Post (immuable)
/// ─────────────────────────────────────────────────────────────

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String authorBadge;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final int userVote;
  final bool isOwner;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.authorBadge,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.upvotes,
    required this.downvotes,
    required this.userVote,
    required this.isOwner,
  });

  factory Post.fromJson(Map<String, dynamic> json, String currentUserId) {
    final author = json['author'] as Map<String, dynamic>?;
    final votesList = json['votes'] as List<dynamic>? ?? [];

    int userVote = 0;
    for (final v in votesList) {
      if (v['user_id'] == currentUserId) {
        final raw = v['vote'];
        userVote = raw == 'up' ? 1 : (raw == 'down' ? -1 : (raw as num?)?.toInt() ?? 0);
        break;
      }
    }

    final authorName =
        '${author?['first_name'] ?? ''} ${author?['last_name'] ?? ''}'.trim();
    final badge =
        author?['user_type'] == 'freelancer' ? 'Prestataire' : 'Membre';

    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: authorName.isEmpty ? 'Utilisateur' : authorName,
      authorAvatar: author?['avatar_url'] as String? ?? '',
      authorBadge: badge,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      userVote: userVote,
      isOwner: json['author_id'] == currentUserId,
    );
  }

  Post copyWith({
    String? content,
    List<String>? images,
    bool? isOwner,
    int? upvotes,
    int? downvotes,
    int? userVote,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorBadge: authorBadge,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      userVote: userVote ?? this.userVote,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}
