import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../data/models/post.dart';
import 'image_viewer_page.dart';

/// ─────────────────────────────────────────────────────────────
/// 📝 Inkern - Carte Post (fil d'actualité)
/// ─────────────────────────────────────────────────────────────

class PostCard extends StatelessWidget {
  final Post post;
  final Function(int) onVote;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onVote,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (post.images.isNotEmpty) ...[const SizedBox(height: 12), _buildImages(context)],
          const SizedBox(height: 12),
          _buildVoteBar(),
        ],
      ),
    );
  }

  // ─── Header : avatar + nom + badge + menu ────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F5F1),
            foregroundImage: post.authorAvatar.isNotEmpty ? NetworkImage(post.authorAvatar) : null,
            child: const Icon(Icons.person_rounded, color: Color(0xFF00C896), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(post.authorName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  _BadgeChip(label: post.authorBadge),
                ]),
                const SizedBox(height: 2),
                Text(_formatTime(post.createdAt), style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          if (post.isOwner) _buildMenu(),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Builder(builder: (context) => GestureDetector(
      onTap: () => _showPostOptions(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
        child: Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 20),
      ),
    ));
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppActionSheet(
        title: 'Options du post',
        items: [
          _AppActionItem(
            icon: Icons.edit_rounded,
            iconColor: AppColors.primary,
            label: 'Modifier le post',
            onTap: () { Navigator.pop(context); onEdit(); },
          ),
          _AppActionItem(
            icon: Icons.delete_rounded,
            iconColor: AppColors.error,
            label: 'Supprimer le post',
            isDestructive: true,
            onTap: () { Navigator.pop(context); onDelete(); },
          ),
        ],
      ),
    );
  }

  // ─── Contenu texte ───────────────────────────────────────────────────────

  Widget _buildContent() {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(post.content, style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
      ),
    );
  }

  // ─── Images ──────────────────────────────────────────────────────────────

  Widget _buildImages(BuildContext context) {
    final imgs = post.images;
    if (imgs.length == 1) {
      return GestureDetector(
        onTap: () => _viewImage(context, 0),
        child: Container(
          height: 200, width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(imgs[0]), fit: BoxFit.cover, onError: (_, __) {}),
            color: const Color(0xFFF5F5F5),
          ),
        ),
      );
    }
    if (imgs.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Expanded(child: _ImageTile(url: imgs[0], height: 150, onTap: () => _viewImage(context, 0))),
          const SizedBox(width: 6),
          Expanded(child: _ImageTile(url: imgs[1], height: 150, onTap: () => _viewImage(context, 1))),
        ]),
      );
    }
    // 3+
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        Expanded(flex: 2, child: _ImageTile(url: imgs[0], height: 180, onTap: () => _viewImage(context, 0))),
        const SizedBox(width: 6),
        Expanded(child: Column(children: [
          _ImageTile(url: imgs[1], height: 87, onTap: () => _viewImage(context, 1)),
          const SizedBox(height: 6),
          _ImageTile(
            url: imgs[2], height: 87, onTap: () => _viewImage(context, 2),
            overlay: imgs.length > 3 ? '+${imgs.length - 3}' : null,
          ),
        ])),
      ]),
    );
  }

  void _viewImage(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ImageViewerPage(images: post.images, initialIndex: index)));
  }

  // ─── Barre de votes ──────────────────────────────────────────────────────

  Widget _buildVoteBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
      child: Row(children: [
        VoteButton(icon: Icons.thumb_up_rounded, count: post.upvotes, isActive: post.userVote == 1, activeColor: AppColors.primary, onTap: () => onVote(1)),
      ]),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${time.day}/${time.month}/${time.year}';
  }
}

// ─── Widgets auxiliaires publics ─────────────────────────────────────────────

class VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const VoteButton({super.key, required this.icon, required this.count, required this.isActive, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? activeColor : AppColors.border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: isActive ? activeColor : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(count.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? activeColor : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Widgets privés ──────────────────────────────────────────────────────────

// ─── Action Sheet ─────────────────────────────────────────────────────────────

class _AppActionItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _AppActionItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });
}

class _AppActionSheet extends StatelessWidget {
  final String? title;
  final List<_AppActionItem> items;

  const _AppActionSheet({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          // Titre
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
            const SizedBox(height: 16),
          ],

          // Actions
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? const Radius.circular(16) : Radius.zero,
                        bottom: i == items.length - 1 ? const Radius.circular(16) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: item.isDestructive
                                    ? AppColors.error.withOpacity(0.1)
                                    : item.iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, size: 20,
                                  color: item.isDestructive ? AppColors.error : item.iconColor),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: item.isDestructive ? AppColors.error : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      Divider(height: 1, color: AppColors.divider, indent: 68),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Annuler
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Annuler', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String url;
  final double height;
  final VoidCallback onTap;
  final String? overlay;

  const _ImageTile({required this.url, required this.height, required this.onTap, this.overlay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover, onError: (_, __) {}),
          color: const Color(0xFFF5F5F5),
        ),
        child: overlay != null
            ? Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(overlay!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
              )
            : null,
      ),
    );
  }
}

