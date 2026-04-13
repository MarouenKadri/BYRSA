import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../story/story.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});
  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Story> stories) {
    setState(() => _selectedIds
      ..clear()
      ..addAll(stories.map((s) => s.id)));
  }

  bool _isAllSelected(List<Story> stories) =>
      stories.isNotEmpty && _selectedIds.length == stories.length;

  Future<void> _deleteSelected() async {
    final provider = context.read<StoryProvider>();
    for (final id in List.of(_selectedIds)) {
      await provider.deleteStory(id);
    }
    _exitSelection();
  }

  void _openOptions(BuildContext context, List<Story> stories, Story story, int index) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: _StoryOptionsSheet(
        story: story,
        onView: () {
          Navigator.pop(context);
          _openViewer(context, stories, index);
        },
        onDelete: () {
          Navigator.pop(context);
          context.read<StoryProvider>().deleteStory(story.id);
        },
      ),
    );
  }


  void _openViewer(BuildContext context, List<Story> stories, int index) {
    final groups = StoryGroup.fromStoriesByCategory(stories);
    final targetStory = stories[index];
    final groupIdx = groups.indexWhere((g) => g.stories.contains(targetStory));
    final safeIdx = groupIdx >= 0 ? groupIdx : 0;
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: safeIdx,
          onViewed: (_) {},
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myStories = context
        .watch<StoryProvider>()
        .stories
        .where((s) => s.isOwner)
        .toList();

    final allSelected = _isAllSelected(myStories);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: _selectionMode
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: context.colors.textPrimary),
                onPressed: _exitSelection,
              )
            : AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: _selectionMode
            ? Text(
                '${_selectedIds.length} sélectionné${_selectedIds.length > 1 ? 's' : ''}',
                style: context.profilePageTitleStyle,
              )
            : Text(
                '${myStories.length} publication${myStories.length > 1 ? 's' : ''}',
                style: context.profilePageTitleStyle,
              ),
        actions: _selectionMode
            ? [
                // Tout sélectionner
                TextButton(
                  onPressed: allSelected
                      ? _exitSelection
                      : () => _selectAll(myStories),
                  child: Text(
                    allSelected ? 'Désélectionner' : 'Tout',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Supprimer
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _deleteSelected(),
                ),
                AppGap.w4,
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.add_a_photo_rounded,
                      color: AppColors.primary),
                  onPressed: () => pickAndOpenComposer(context),
                ),
                AppGap.w4,
              ],
      ),
      body: myStories.isEmpty
          ? _buildEmpty(context)
          : Column(
              children: [
                // ─── Bandeau sélection ────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: _selectionMode
                      ? Container(
                          width: double.infinity,
                          color: context.colors.surfaceAlt,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: allSelected
                                    ? _exitSelection
                                    : () => _selectAll(myStories),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: allSelected
                                            ? context.colors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: allSelected
                                              ? context.colors.primary
                                              : context.colors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: allSelected
                                          ? const Icon(Icons.check_rounded,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    AppGap.w10,
                                    Text(
                                      'Tout sélectionner',
                                      style: context.text.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (_selectedIds.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _deleteSelected(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: AppColors.error),
                                        AppGap.w6,
                                        Text(
                                          'Supprimer (${_selectedIds.length})',
                                          style: context.text.bodySmall
                                              ?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ─── Grille ───────────────────────────────────────────────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: myStories.length,
                    itemBuilder: (context, i) {
                      final story = myStories[i];
                      final selected = _selectedIds.contains(story.id);
                      return GestureDetector(
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelect(story.id);
                          } else {
                            _openOptions(context, myStories, story, i);
                          }
                        },
                        onLongPress: () => _enterSelection(story.id),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image
                            story.imageUrl.isNotEmpty
                                ? Image.network(story.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.primaryLight,
                                      child: const Icon(Icons.image_rounded,
                                          color: AppColors.primary),
                                    ))
                                : Container(
                                    color: AppColors.primaryLight,
                                    child: const Icon(Icons.image_rounded,
                                        color: AppColors.primary),
                                  ),

                            // Légende
                            if (story.caption.isNotEmpty && !_selectionMode)
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                      5, 0, 5, 4),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      stops: [0, 0.7],
                                      colors: [
                                        Colors.black45,
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                  child: Text(story.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: AppFontSize.tiny)),
                                ),
                              ),

                            // Overlay sélection
                            if (_selectionMode)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                color: selected
                                    ? context.colors.primary
                                        .withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.08),
                              ),

                            // Checkbox
                            if (_selectionMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? context.colors.primary
                                        : Colors.white.withValues(alpha: 0.9),
                                    border: Border.all(
                                      color: selected
                                          ? context.colors.primary
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check_rounded,
                                          size: 13, color: Colors.white)
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppSurfaceCard(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: context.colors.border),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 26,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h16,
              Text(
                'Aucune publication pour le moment',
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h8,
              Text(
                'Ajoutez une photo pour commencer.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
              AppGap.h18,
              AppButton(
                label: 'Ajouter',
                variant: ButtonVariant.secondary,
                icon: Icons.add_rounded,
                iconTrailing: false,
                width: 170,
                height: 48,
                onPressed: () => pickAndOpenComposer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet options ─────────────────────────────────────────────────────

class _StoryOptionsSheet extends StatelessWidget {
  final Story story;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _StoryOptionsSheet({
    required this.story,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Options',
      children: <Widget>[
        AppActionSheetItem(
          icon: Icons.play_circle_outline_rounded,
          title: 'Voir la publication',
          onTap: onView,
        ),
        const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: Color(0x1FFFFFFF),
        ),
        AppActionSheetItem(
          icon: Icons.delete_outline_rounded,
          title: 'Supprimer la publication',
          destructive: true,
          onTap: onDelete,
        ),
      ],
    );
  }
}
