import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../features/mission/data/models/service_category.dart';

class CategoryStoryStripAddAction {
  final String label;
  final VoidCallback onTap;

  const CategoryStoryStripAddAction({
    required this.label,
    required this.onTap,
  });
}

class CategoryStoryStripItem {
  final String categoryId;
  final String label;
  final int count;
  final bool viewed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CategoryStoryStripItem({
    required this.categoryId,
    required this.label,
    required this.count,
    required this.viewed,
    this.onTap,
    this.onLongPress,
  });
}

class CategoryStoryStrip extends StatelessWidget {
  final List<CategoryStoryStripItem> items;
  final CategoryStoryStripAddAction? addAction;

  const CategoryStoryStrip({
    super.key,
    required this.items,
    this.addAction,
  });

  @override
  Widget build(BuildContext context) {
    final total = items.length + (addAction == null ? 0 : 1);
    if (total == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.h12v8,
        itemCount: total,
        itemBuilder: (context, index) {
          if (addAction != null && index == 0) {
            return _CategoryStoryCircle(
              isAdd: true,
              label: addAction!.label,
              onTap: addAction!.onTap,
            );
          }

          final item = addAction == null ? items[index] : items[index - 1];
          return _CategoryStoryCircle(
            categoryId: item.categoryId,
            label: item.label,
            count: item.count,
            viewed: item.viewed,
            onTap: item.onTap,
            onLongPress: item.onLongPress,
          );
        },
      ),
    );
  }
}

class _CategoryStoryCircle extends StatelessWidget {
  final String? categoryId;
  final String label;
  final int count;
  final bool viewed;
  final bool isAdd;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _CategoryStoryCircle({
    this.categoryId,
    required this.label,
    this.count = 0,
    this.viewed = false,
    this.isAdd = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cat = categoryId != null ? ServiceCategory.resolve(categoryId!) : null;
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
                          child: Icon(
                            Icons.add_rounded,
                            color: Color(0xFF98A2AD),
                            size: 21,
                          ),
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
                        horizontal: 5,
                        vertical: 2,
                      ),
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
