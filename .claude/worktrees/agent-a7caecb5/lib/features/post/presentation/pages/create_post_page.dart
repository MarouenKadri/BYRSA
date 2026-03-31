import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../profile/profile_provider.dart';
import '../../data/models/post.dart';
import '../../post_provider.dart';

class CreatePostPage extends StatefulWidget {
  final Post? postToEdit;

  const CreatePostPage({super.key, this.postToEdit});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  final _picker = ImagePicker();

  // Images existantes (mode édition) = URLs déjà uploadées
  List<String> _existingUrls = [];
  // Nouveaux fichiers sélectionnés = à uploader
  List<File> _newFiles = [];

  bool _isLoading = false;

  bool get _isEditing => widget.postToEdit != null;
  int get _totalImages => _existingUrls.length + _newFiles.length;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _contentController.text = widget.postToEdit!.content;
      _existingUrls = List<String>.from(widget.postToEdit!.images);
    }
    // Charge le profil si pas encore fait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile == null) context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final charCount = _contentController.text.length;
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: _showDiscardSheet,
        ),
        title: Text(
          _isEditing ? 'Modifier la publication' : 'Nouvelle publication',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Auteur ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.border,
                      backgroundImage: (profile?.avatarUrl != null &&
                              profile!.avatarUrl!.isNotEmpty)
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: (profile?.avatarUrl == null ||
                              profile!.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person_rounded,
                              color: AppColors.textTertiary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile != null
                          ? '${profile.firstName} ${profile.lastName}'.trim()
                          : '...',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Contenu scrollable ───
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      minLines: 6,
                      maxLength: 1000,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText:
                            'Partagez vos dernières réalisations, conseils ou expériences...',
                        hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 16,
                            height: 1.5),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        counterStyle: AppTextStyles.caption,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTextStyles.body,
                    ),
                  ),

                  if (_totalImages > 0) ...[
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildSelectedImages(),
                    ),
                  ],

                  const SizedBox(height: 8),

                  if (charCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$charCount / 1000',
                            style: AppTextStyles.caption.copyWith(
                              color: charCount > 900
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ─── Barre d'actions + bouton Publier ───
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                // ── Actions gauche (scrollables si trop larges) ──
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToolbarAction(
                          icon: Icons.photo_library_rounded,
                          label: 'Galerie',
                          onTap: _openGallery,
                        ),
                        const SizedBox(width: 4),
                        _ToolbarAction(
                          icon: Icons.camera_alt_rounded,
                          label: 'Caméra',
                          onTap: _openCamera,
                        ),
                        const SizedBox(width: 4),
                        _ToolbarAction(
                          icon: Icons.emoji_emotions_rounded,
                          label: 'Emoji',
                          onTap: _addEmoji,
                        ),
                        if (_totalImages > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '$_totalImages/10',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ── Bouton Publier ──
                ElevatedButton(
                  onPressed: _canPublish() ? _publish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textTertiary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.button)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Enregistrer' : 'Publier'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Images sélectionnées ─────────────────────────────────────────────────

  Widget _buildSelectedImages() {
    final all = [
      ..._existingUrls.map<_ImageItem>((url) => _ImageItem.url(url)),
      ..._newFiles.map<_ImageItem>((file) => _ImageItem.file(file)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Photos', style: AppTextStyles.label),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6)),
              child: Text('${all.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
            const Spacer(),
            if (all.length < 10)
              GestureDetector(
                onTap: _openGallery,
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Ajouter',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: all.length,
            itemBuilder: (context, index) {
              final item = all[index];
              return _ImagePreviewTile(
                item: item,
                onRemove: () => setState(() {
                  if (item.isUrl) {
                    _existingUrls.remove(item.url);
                  } else {
                    _newFiles.remove(item.file);
                  }
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  bool _canPublish() => _contentController.text.trim().isNotEmpty && !_isLoading;

  Future<void> _publish() async {
    if (!_canPublish()) return;
    setState(() => _isLoading = true);

    final provider = context.read<PostProvider>();
    final content = _contentController.text.trim();

    bool success;
    if (_isEditing) {
      success = await provider.editPost(
        original: widget.postToEdit!,
        content: content,
        newImageFiles: _newFiles,
        existingImageUrls: _existingUrls,
      );
    } else {
      final post = await provider.createPost(
        content: content,
        imageFiles: _newFiles,
      );
      success = post != null;
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openGallery() async {
    if (_totalImages >= 10) return;
    final remaining = 10 - _totalImages;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _newFiles.addAll(picked.map((x) => File(x.path)));
        if (_totalImages > 10) {
          _newFiles.removeRange(10 - _existingUrls.length, _newFiles.length);
        }
      });
    }
  }

  Future<void> _openCamera() async {
    if (_totalImages >= 10) return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null && mounted) {
      setState(() => _newFiles.add(File(picked.path)));
    }
  }

  void _addEmoji() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmojiPickerSheet(
        onEmojiSelected: (emoji) {
          _contentController.text += emoji;
          _contentController.selection = TextSelection.fromPosition(
              TextPosition(offset: _contentController.text.length));
          setState(() {});
        },
      ),
    );
  }

  void _showDiscardSheet() {
    if (_contentController.text.isEmpty && _totalImages == 0) {
      Navigator.pop(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).padding.bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              const Text('Abandonner la publication ?',
                  style: AppTextStyles.h4, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Le contenu rédigé sera perdu.',
                  style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button)),
                      ),
                      child: const Text('Continuer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button)),
                        elevation: 0,
                      ),
                      child: const Text('Abandonner'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Modèle interne pour image (URL ou File) ──────────────────────────────────

class _ImageItem {
  final String? url;
  final File? file;

  const _ImageItem.url(this.url) : file = null;
  const _ImageItem.file(this.file) : url = null;

  bool get isUrl => url != null;
}

// ─── Thumbnail ────────────────────────────────────────────────────────────────

class _ImagePreviewTile extends StatelessWidget {
  final _ImageItem item;
  final VoidCallback onRemove;

  const _ImagePreviewTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: item.isUrl
                  ? Image.network(item.url!, fit: BoxFit.cover)
                  : Image.file(item.file!, fit: BoxFit.cover),
            ),
            Positioned(
              top: 6,
              right: 16,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toolbar action button ────────────────────────────────────────────────────

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Emoji picker sheet ───────────────────────────────────────────────────────

class _EmojiPickerSheet extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const _EmojiPickerSheet({required this.onEmojiSelected});

  static const List<String> _emojis = [
    '👍', '❤️', '🎉', '🔥', '💪', '✨', '🙌', '👏',
    '🏠', '🔧', '🪴', '🧹', '🎨', '🔨', '⚡', '🪜',
    '🌿', '🌸', '🛠️', '🧰', '🪣', '🧽', '💡', '🔌',
    '😊', '😍', '🤩', '😎', '🥳', '💯', '👌', '✅',
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.emoji_emotions_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                  child:
                      Text('Ajouter un emoji', style: AppTextStyles.h4)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojis
                .map((emoji) => GestureDetector(
                      onTap: () {
                        onEmojiSelected(emoji);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppRadius.small),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 24))),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
