import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../data/models/post.dart';
import '../../post_provider.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';

/// ─────────────────────────────────────────────────────────────
/// 📰 Inkern - Fil d'actualité
/// isFreelancer: true  → bouton "Publier" visible + peut créer
/// isFreelancer: false → lecture seule (client)
/// ─────────────────────────────────────────────────────────────

class PostsFeedPage extends StatelessWidget {
  final bool isFreelancer;
  final bool showAppBar;

  const PostsFeedPage({super.key, this.isFreelancer = true, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Fil d\'actualité',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              centerTitle: true,
              actions: [
                IconButton(icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary), onPressed: () {}),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<PostProvider>().refresh(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            // Un client ne peut jamais éditer/supprimer un post,
            // même s'il en est l'auteur (créé en mode freelancer).
            final viewPost = isFreelancer ? post : post.copyWith(isOwner: false);
            return PostCard(
              post: viewPost,
              onVote: (vote) => context.read<PostProvider>().vote(post.id, vote),
              onEdit: () => _editPost(context, post),
              onDelete: () => _deletePost(context, post),
              onTap: () => _viewPost(context, post),
            );
          },
        ),
      ),
      // FAB uniquement quand la page est affichée de façon autonome (avec AppBar)
      floatingActionButton: isFreelancer && showAppBar
          ? FloatingActionButton.extended(
              onPressed: () => _createPost(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Publier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _createPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );
  }

  void _editPost(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatePostPage(postToEdit: post)),
    );
  }

  void _deletePost(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la publication'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              context.read<PostProvider>().deletePost(post.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _viewPost(BuildContext context, Post post) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(post: post)));
  }
}

// ─── Post Detail Page ─────────────────────────────────────────────────────────

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Publication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE8F5F1),
              foregroundImage: post.authorAvatar.isNotEmpty ? NetworkImage(post.authorAvatar) : null,
              child: const Icon(Icons.person_rounded, color: Color(0xFF00C896), size: 24),
            ),
              title: Row(children: [
                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(post.authorBadge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ]),
              subtitle: Text(_formatDate(post.createdAt)),
              trailing: TextButton(onPressed: () {}, child: const Text('Voir profil')),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(post.content, style: const TextStyle(fontSize: 16, height: 1.6)),
            ),
            ...post.images.map((img) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.network(
                img,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xFFF5F5F5),
                  child: const Center(child: Icon(Icons.image_not_supported_rounded, color: Color(0xFFBBBBBB), size: 40)),
                ),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime time) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${time.day} ${months[time.month - 1]} ${time.year} à ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
