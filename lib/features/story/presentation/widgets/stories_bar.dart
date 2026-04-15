import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../features/mission/data/models/service_category.dart';
import '../../data/models/story.dart';
import '../pages/story_composer_page.dart';

class StoriesBar extends StatelessWidget {
  final List<StoryGroup> groups;
  final bool isFreelancer;
  final Set<String> viewedIds;
  final void Function(int index) onTap;
  final VoidCallback? onAddTap;

  const StoriesBar({
    super.key,
    required this.groups,
    this.isFreelancer = false,
    required this.viewedIds,
    required this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final addSlot = isFreelancer ? 1 : 0;
    final total = groups.length + addSlot;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      color: context.colors.surface,
      child: Column(
        children: [
          const SizedBox(height: 2),
          SizedBox(
            height: 104,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppInsets.h12v8,
              itemCount: total,
              itemBuilder: (context, i) {
                if (isFreelancer && i == 0) {
                  return _StoryCircle(
                    isAdd: true,
                    label: 'Ma story',
                    onTap: onAddTap ?? () {},
                  );
                }
                final idx = isFreelancer ? i - 1 : i;
                final group = groups[idx];
                final viewed = viewedIds.contains(group.groupId);
                return _StoryCircle(
                  avatarUrl: group.isAuthorGroup ? group.avatarUrl : null,
                  categoryId: group.isAuthorGroup ? null : group.categoryId,
                  label: group.groupName,
                  viewed: viewed,
                  onTap: () => onTap(idx),
                );
              },
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
        ],
      ),
    );
  }
}

// Circle adapts to author group (avatar) or category group (icon)
class _StoryCircle extends StatelessWidget {
  final String? avatarUrl;   // non-null → author group (show avatar)
  final String? categoryId;  // non-null → category group (show icon)
  final String label;
  final bool viewed;
  final bool isAdd;
  final VoidCallback onTap;

  const _StoryCircle({
    this.avatarUrl,
    this.categoryId,
    required this.label,
    this.viewed = false,
    this.isAdd = false,
    required this.onTap,
  });

  TextStyle _storyLabelStyle(BuildContext context, {required bool viewed}) =>
      viewed ? context.storyViewedLabelStyle : context.storyLabelStyle;

  @override
  Widget build(BuildContext context) {
    final cat = categoryId != null ? ServiceCategory.findById(categoryId!) : null;
    const storySize = 68.0;
    const storyRingWidth = 1.4;
    const avatarInset = 2.0;
    const addIconSize = 22.0;
    const categoryIconSize = 28.0;
    const labelWidth = 78.0;
    final ringGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF7D37A), Color(0xFFE6A0C4)],
    );
    final categoryTone = cat?.themedColor(context) ?? context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: storySize,
              height: storySize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: (!isAdd && !viewed) ? ringGradient : null,
                color: isAdd ? Colors.white : viewed ? context.colors.border : null,
                border: isAdd
                    ? Border.all(color: context.colors.divider, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isAdd ? 0.04 : 0.08),
                    blurRadius: isAdd ? 8 : 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isAdd ? 0 : storyRingWidth),
              child: isAdd
                  ? Center(
                      child: Icon(
                        Icons.add,
                        color: context.colors.textTertiary,
                        size: addIconSize,
                      ),
                    )
                  : avatarUrl != null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(avatarInset),
                          child: ClipOval(
                            child: avatarUrl!.isNotEmpty
                                ? Image.network(
                                    avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fallback(context, categoryTone),
                                  )
                                : _fallback(context, categoryTone),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: viewed
                                ? context.colors.surfaceAlt
                                : categoryTone.withValues(alpha: 0.10),
                          ),
                          child: Center(
                            child: Icon(
                              cat?.icon ?? Icons.photo_library_rounded,
                              size: categoryIconSize,
                              color: viewed
                                  ? context.colors.textTertiary
                                  : categoryTone,
                            ),
                          ),
                        ),
            ),
            AppGap.h4,
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                style: _storyLabelStyle(context, viewed: viewed),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context, Color color) => Container(
    color: color.withValues(alpha: AppStoryMetrics.fallbackAlpha),
    child: Center(child: Text(
      label.isNotEmpty ? label[0].toUpperCase() : '?',
      style: context.storyFallbackStyle.copyWith(color: color),
    )),
  );
}

/// Cercle story pour profil / compte — catégorie + badge compteur + état viewed.
/// Partagé entre AccountPage (_MyStoriesSection) et FreelancerProfileView.
class StoryOwnerCircle extends StatelessWidget {
  final String? categoryId;
  final String label;
  final int count;
  final bool viewed;
  final bool isAdd;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const StoryOwnerCircle({
    super.key,
    this.categoryId,
    required this.label,
    this.count = 0,
    this.viewed = false,
    this.isAdd = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cat = categoryId != null ? ServiceCategory.findById(categoryId!) : null;
    final accent = cat?.color ?? const Color(0xFFB8C0CC);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAdd
                        ? const Color(0xFFFAFBFC)
                        : viewed
                            ? const Color(0xFFF6F8F9)
                            : Colors.white,
                    border: Border.all(
                      color: isAdd
                          ? const Color(0xFFE3E8EC)
                          : viewed
                              ? const Color(0xFFE7ECEF)
                              : accent.withValues(alpha: 0.42),
                      width: 1.15,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(15, 23, 42, 0.04),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: isAdd
                      ? const Center(
                          child: Icon(Icons.add_rounded,
                              color: Color(0xFF98A2AD), size: 21),
                        )
                      : Center(
                          child: Icon(
                            cat?.icon ?? Icons.photo_library_outlined,
                            size: 21,
                            color: viewed
                                ? const Color(0xFFADB5BE)
                                : const Color(0xFF5F6B76),
                          ),
                        ),
                ),
                if (!isAdd && count > 1)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF66707A),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppGap.h6,
            SizedBox(
              width: 64,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: viewed
                      ? const Color(0xFF9BA6B1)
                      : const Color(0xFF4D5965),
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable media picker sheet for stories
class StoryMediaPickerSheet extends StatelessWidget {
  const StoryMediaPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Ajouter une story',
      children: <Widget>[
        AppActionSheetItem(
          icon: Icons.photo_camera_outlined,
          title: 'Prendre une photo',
          subtitle: 'Utiliser la caméra',
          onTap: () => Navigator.pop(context, ImageSource.camera),
        ),
        const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: Color(0x1FFFFFFF),
        ),
        AppActionSheetItem(
          icon: Icons.photo_library_outlined,
          title: 'Choisir depuis la galerie',
          subtitle: 'Sélectionner une photo',
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    );
  }
}

/// Helper function to pick and navigate to composer
Future<void> pickAndOpenComposer(BuildContext context) async {
  final source = await showAppBottomSheet<ImageSource>(
    context: context,
    wrapWithSurface: false,
    child: const StoryMediaPickerSheet(),
  );
  if (source == null || !context.mounted) return;
  final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
  if (picked == null || !context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StoryComposerPage(mediaFile: File(picked.path)),
    ),
  );
}
