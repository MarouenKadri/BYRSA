import 'dart:io';
import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/service_category.dart';
import '../../../data/models/mission.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🧩 Inkern - Widgets Communs Mission (Partagés Client & Freelancer)
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Badge Statut ────────────────────────────────────────────────────────────

class MissionStatusBadge extends StatelessWidget {
  final MissionStatus status;
  final bool showIcon;
  final bool compact;

  const MissionStatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 4),
            Icon(status.icon, size: 14, color: status.color),
          ],
        ],
      ),
    );
  }
}

// ─── Chip Catégorie ───────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.compact = false,
  });

  factory CategoryChip.fromCategory(ServiceCategory category, {bool compact = false}) {
    return CategoryChip(icon: category.icon, label: category.name, color: category.color, compact: compact);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip Info (date, lieu, durée) ────────────────────────────────────────────

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final bool compact;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 14 : 16, color: iconColor ?? AppColors.textTertiary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Badge Budget ─────────────────────────────────────────────────────────────

class BudgetBadge extends StatelessWidget {
  final BudgetInfo budget;
  final bool large;
  final bool outlined;

  const BudgetBadge({super.key, required this.budget, this.large = false, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 12, vertical: large ? 8 : 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(large ? 10 : 8),
        border: outlined ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1) : null,
      ),
      child: Text(
        budget.displayText,
        style: TextStyle(fontSize: large ? 16 : 15, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }
}

class BudgetText extends StatelessWidget {
  final BudgetInfo budget;
  final bool large;

  const BudgetText({super.key, required this.budget, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Text(budget.displayText, style: large ? AppTextStyles.priceLarge : AppTextStyles.price);
  }
}

// ─── Avatar Utilisateur ───────────────────────────────────────────────────────

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool showVerified;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 18, this.showVerified = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.surfaceAlt,
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _AvatarShimmer(radius: radius);
                    },
                    errorBuilder: (_, __, ___) => _AvatarPlaceholder(radius: radius),
                  )
                : _AvatarPlaceholder(radius: radius),
          ),
        ),
        if (showVerified)
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.verified_rounded, size: radius * 0.6, color: AppColors.info),
            ),
          ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final double radius;
  const _AvatarPlaceholder({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: AppColors.surfaceAlt,
      child: Icon(Icons.person_rounded, size: radius, color: AppColors.textHint),
    );
  }
}

class _AvatarShimmer extends StatefulWidget {
  final double radius;
  const _AvatarShimmer({required this.radius});

  @override
  State<_AvatarShimmer> createState() => _AvatarShimmerState();
}

class _AvatarShimmerState extends State<_AvatarShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        color: AppColors.border.withOpacity(_anim.value),
      ),
    );
  }
}

// ─── Rating ──────────────────────────────────────────────────────────────────

class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final int? missionsCount;
  final bool compact;
  final bool showStars;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewsCount,
    this.missionsCount,
    this.compact = false,
    this.showStars = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showStars) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) => Icon(
          i < rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
          size: compact ? 14 : 16,
          color: i < rating.round() ? AppColors.rating : AppColors.border,
        )),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        if (missionsCount != null)
          Text(
            ' • $missionsCount mission${missionsCount! > 1 ? 's' : ''}',
            style: TextStyle(fontSize: compact ? 11 : 12, color: AppColors.textTertiary),
          )
        else if (reviewsCount != null)
          Text(
            ' ($reviewsCount)',
            style: TextStyle(fontSize: compact ? 10 : 11, color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

// ─── Image Header ─────────────────────────────────────────────────────────────

class MissionImageHeader extends StatelessWidget {
  final List<String> images;
  final IconData fallbackIcon;
  final bool showImageCount;
  final double height;
  final BorderRadius? borderRadius;
  final String? heroTag;

  const MissionImageHeader({
    super.key,
    required this.images,
    required this.fallbackIcon,
    this.showImageCount = true,
    this.height = 140,
    this.borderRadius,
    this.heroTag,
  });

  static Widget _buildImage(String src, double height, IconData fallback) {
    final isLocal = !src.startsWith('http');
    final errorWidget = (_, __, ___) => Container(
      height: height, color: AppColors.divider,
      child: Icon(fallback, size: 48, color: AppColors.textHint),
    );
    if (isLocal) {
      return Image.file(
        File(src), height: height, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: errorWidget,
      );
    }
    return Image.network(
      src, height: height, width: double.infinity, fit: BoxFit.cover,
      errorBuilder: errorWidget,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height, color: AppColors.surfaceAlt,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textHint)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final child = ClipRRect(
      borderRadius: borderRadius ?? const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      child: Stack(
        children: [
          _buildImage(images.first, height, fallbackIcon),
          if (showImageCount && images.length > 1)
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${images.length}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (heroTag != null) return Hero(tag: heroTag!, child: child);
    return child;
  }
}

// ─── État Vide ────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.textTertiary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 28),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: AppShadows.primaryButton,
                ),
                child: ElevatedButton.icon(
                  onPressed: onButtonPressed,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(buttonText!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Transition de page Slide-Up + Fade ───────────────────────────────────────

PageRoute<T> slideUpRoute<T>({required Widget page}) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 350),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  },
);

// ─── Skeleton Loaders ─────────────────────────────────────────────────────────

class SkeletonList extends StatefulWidget {
  final int count;
  const SkeletonList({super.key, this.count = 3});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: widget.count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => _MissionCardSkeleton(opacity: _anim.value),
        ),
      ),
    );
  }
}

class _MissionCardSkeleton extends StatelessWidget {
  final double opacity;
  const _MissionCardSkeleton({required this.opacity});

  Widget _box(double? w, double h, [double r = 6]) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: AppColors.border.withOpacity(opacity),
      borderRadius: BorderRadius.circular(r),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
            child: _box(double.infinity, 120, 0),
          ),
          Padding(
            padding: AppPadding.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _box(80, 22, AppRadius.badge),
                  const Spacer(),
                  _box(70, 22, AppRadius.badge),
                ]),
                const SizedBox(height: 12),
                _box(double.infinity, 18),
                const SizedBox(height: 6),
                _box(200, 14),
                const SizedBox(height: 12),
                Row(children: [
                  _box(90, 14),
                  const SizedBox(width: 10),
                  _box(80, 14),
                ]),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                Row(children: [
                  _box(70, 20),
                  const Spacer(),
                  _box(110, 32, AppRadius.chip),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Container ───────────────────────────────────────────────────────────

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const CardContainer({super.key, required this.child, this.margin, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(padding: padding ?? AppPadding.cardLarge, child: child),
        ),
      ),
    );
  }
}
