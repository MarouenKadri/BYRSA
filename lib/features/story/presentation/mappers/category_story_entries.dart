import '../../../mission/data/models/service_category.dart';
import '../../data/models/story.dart';
import 'story_category_presentation.dart';

class CategoryStoryEntry {
  final String categoryId;
  final String label;
  final StoryGroup? group;

  const CategoryStoryEntry({
    required this.categoryId,
    required this.label,
    this.group,
  });

  bool get hasStories => group != null && group!.stories.isNotEmpty;
  int get count => group?.stories.length ?? 0;
}

class CategoryStoryEntries {
  const CategoryStoryEntries._();

  static List<CategoryStoryEntry> build({
    required List<String> selectedCategories,
    required List<StoryGroup> groups,
  }) {
    final selectedResolvedCategoryIds = ServiceCategory.resolveIds(
      selectedCategories,
    );
    final selectedUnresolvedCategoryIds = <String>[];
    final unresolvedSeen = <String>{};
    for (final raw in selectedCategories) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      if (ServiceCategory.resolve(value) != null) continue;
      final key = _normalizeCategoryKey(value);
      if (key.isEmpty || !unresolvedSeen.add(key)) continue;
      selectedUnresolvedCategoryIds.add(value);
    }

    final groupsById = <String, StoryGroup>{
      for (final group in groups) group.groupId: group,
    };

    final orderedCategoryIds = <String>[];
    final orderedSeen = <String>{};
    void addCategory(String id) {
      final key = _normalizeCategoryKey(id);
      if (key.isEmpty || !orderedSeen.add(key)) return;
      orderedCategoryIds.add(id);
    }

    for (final category in ServiceCategory.ordered) {
      if (selectedResolvedCategoryIds.contains(category.id)) {
        addCategory(category.id);
      }
    }
    for (final categoryId in selectedUnresolvedCategoryIds) {
      addCategory(categoryId);
    }
    for (final group in groups) {
      addCategory(group.groupId);
    }

    return orderedCategoryIds
        .map((categoryId) {
          final group = groupsById[categoryId];
          final category = ServiceCategory.resolve(categoryId);
          final label = group != null
              ? (category?.name ??
                    StoryCategoryPresentation.label(
                      group.groupName,
                      fallback: 'Autres',
                    ))
              : (category?.name ??
                    StoryCategoryPresentation.label(
                      categoryId,
                      fallback: 'Autres',
                    ));
          return CategoryStoryEntry(
            categoryId: categoryId,
            label: label,
            group: group,
          );
        })
        .toList(growable: false);
  }

  static String _normalizeCategoryKey(String raw) {
    var value = raw.trim().toLowerCase();
    if (value.isEmpty) return '';
    return value.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
