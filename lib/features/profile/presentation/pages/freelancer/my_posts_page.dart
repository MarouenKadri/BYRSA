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
  @override
  Widget build(BuildContext context) {
    final myStories = context.watch<StoryProvider>().stories
        .where((s) => s.isOwner)
        .toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          '${myStories.length} story${myStories.length > 1 ? 's' : ''}',
          style: context.profilePageTitleStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
            onPressed: () => pickAndOpenComposer(context),
          ),
          AppGap.w4,
        ],
      ),
      body: myStories.isEmpty
          ? _buildEmpty(context)
          : GridView.builder(
              padding: AppInsets.a12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              itemCount: myStories.length,
              itemBuilder: (context, i) {
                final story = myStories[i];
                return GestureDetector(
                  onTap: () => _openViewer(context, myStories, i),
                  onLongPress: () => _confirmDelete(context, story),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(story.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight,
                            child: const Icon(Icons.image_rounded, color: AppColors.primary))),
                    if (story.caption.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              stops: [0, 0.7],
                              colors: [Colors.black45, Colors.transparent],
                            ),
                          ),
                          child: Text(story.caption, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: AppFontSize.tiny)),
                        ),
                      ),
                  ]),
                );
              },
            ),
    );
  }

  void _openViewer(BuildContext context, List<Story> stories, int index) {
    final groups = StoryGroup.fromStoriesByCategory(stories);
    final targetStory = stories[index];
    final groupIdx = groups.indexWhere((g) => g.stories.contains(targetStory));
    final safeIdx = groupIdx >= 0 ? groupIdx : 0;
    Navigator.push(context, PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => StoryViewerPage(
        groups: groups,
        initialIndex: safeIdx,
        onViewed: (_) {},
      ),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ));
  }

  void _confirmDelete(BuildContext context, Story story) {
    showAppDialog(
      context: context,
      title: const Text('Supprimer la story'),
      content: const Text('Cette action est irréversible.'),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () => context.read<StoryProvider>().deleteStory(story.id),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.auto_stories_rounded, size: 36, color: AppColors.primary)),
          AppGap.h16,
          Text('Aucune story', style: context.text.titleLarge),
          AppGap.h8,
          Text('Publiez vos premières réalisations photo',
              style: context.text.bodySmall),
          AppGap.h24,
          AppButton(
            label: 'Ajouter une story',
            variant: ButtonVariant.primary,
            icon: Icons.add_a_photo_rounded,
            onPressed: () => pickAndOpenComposer(context),
          ),
        ],
      ),
    );
  }
}
