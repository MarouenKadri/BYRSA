import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sheet components
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Center(
        child: Container(
          width: 30,
          height: 2.5,
          decoration: BoxDecoration(
            color: const Color(0xFF9AA4AF).withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }
}

class AppSheetSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppSheetSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.80),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.10),
                blurRadius: 28,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  final String title;

  const AppSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppBottomSheetHandle(),
        AppGap.h16,
        Text(title, style: context.profileSheetTitleStyle),
        AppGap.h14,
        Divider(color: context.colors.divider, height: 1),
      ],
    );
  }
}

/// Bottom sheet dark glassmorphism — design partagé par tous les pickers sombres.
/// Pour changer le design, modifier uniquement cette classe.
class AppDarkSheet extends StatelessWidget {
  final Widget child;

  const AppDarkSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.78),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBarSheetSurface extends StatelessWidget {
  final Widget child;

  const AppBarSheetSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.10),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBarOptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppBarOptionTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.padding = AppInsets.h16v14,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            leading,
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.appBarSheetItemTitleStyle),
                  if (subtitle != null) ...[
                    AppGap.h2,
                    Text(
                      subtitle!,
                      style: context.appBarSheetItemSubtitleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            AppGap.w12,
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// showAppBottomSheet — helper centralisé pour les bottom sheets
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool wrapWithSurface = true,
}) {
  assert(child != null || builder != null, 'Provide either child or builder');
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final content = builder != null ? builder(ctx) : child!;
      return wrapWithSurface ? AppSheetSurface(child: content) : content;
    },
  );
}
