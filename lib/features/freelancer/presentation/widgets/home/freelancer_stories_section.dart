import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/design/app_design_system.dart';
import 'package:flutter_application_1/features/story/story.dart';

/// Carrousel de stories affiché en haut du home freelancer.
class FreelancerStoriesSection extends StatefulWidget {
  final List<StoryGroup> storyGroups;

  const FreelancerStoriesSection({super.key, required this.storyGroups});

  @override
  State<FreelancerStoriesSection> createState() =>
      _FreelancerStoriesSectionState();
}

class _FreelancerStoriesSectionState extends State<FreelancerStoriesSection> {
  final Set<String> _viewed = {};

  @override
  Widget build(BuildContext context) {
    final groups = widget.storyGroups
        .where((g) => g.stories.isNotEmpty)
        .take(8)
        .toList();

    return SizedBox(
      height: 194,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        itemCount: groups.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => pickAndOpenComposer(context),
              child: Container(
                width: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: context.colors.surfaceAlt,
                  border: Border.all(color: context.colors.border, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, size: 24, color: context.colors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ma story',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Publier',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final group = groups[index - 1];
          final story = group.stories.first;
          final isViewed = group.stories.every((s) => _viewed.contains(s.id));

          return GestureDetector(
            onTap: () => _openViewer(context, groups, index - 1),
            child: Container(
              width: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isViewed
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFFDADFE6),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  story.imageUrl.isNotEmpty
                      ? Image.network(
                          story.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _StoryPhotoFallback(label: story.serviceCategory),
                        )
                      : _StoryPhotoFallback(label: story.serviceCategory),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.54),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.92),
                              width: 1.2,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: group.avatarUrl.isNotEmpty
                              ? Image.network(
                                  group.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _StoryAvatarFallback(
                                        name: group.groupName,
                                      ),
                                )
                              : _StoryAvatarFallback(name: group.groupName),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            group.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: index,
          onViewed: (id) => setState(() => _viewed.add(id)),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

// ─── Fallbacks ────────────────────────────────────────────────────────────────

class _StoryPhotoFallback extends StatelessWidget {
  final String label;
  const _StoryPhotoFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    final n = label.toLowerCase();
    final icon = n.contains('jardin')
        ? Icons.yard_outlined
        : n.contains('plomb')
        ? Icons.plumbing_outlined
        : n.contains('menage')
        ? Icons.bed_outlined
        : Icons.home_repair_service_outlined;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCE6DB), Color(0xFFC8D6D8)],
        ),
      ),
      child: Center(child: Icon(icon, size: 30, color: const Color(0xFF6E7781))),
    );
  }
}

class _StoryAvatarFallback extends StatelessWidget {
  final String name;
  const _StoryAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      color: const Color(0xFFE9EEF2),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4A4F55),
        ),
      ),
    );
  }
}
