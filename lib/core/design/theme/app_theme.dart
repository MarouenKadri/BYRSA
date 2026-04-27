import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_radius.dart';
import '../components/app_text_field.dart';

// ─── 5. THEMES ───────────────────────────────────────────────────────────────

// ─── Tokens App ──────────────────────────────────────────────────────────────

class _AppTokens {
  const _AppTokens();
  Color get primary => const Color.fromARGB(255, 81, 86, 88);
  Color get error => const Color.fromARGB(255, 194, 118, 118);
  Color get background => AppColors.background;
  Color get surface => AppColors.surface;
  Color get surfaceAlt => AppColors.surfaceAlt;
  Color get sheetBg => AppColors.sheetBg;
  Color get inputFill => AppColors.inputFill;
  Color get border => AppColors.border;
  Color get divider => AppColors.divider;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textTertiary => AppColors.textTertiary;
  Color get textHint => AppColors.textHint;
  Color get appBarBg => AppColors.surface;
}

class AppThemeData {
  AppThemeData._();

  static ThemeData get theme => _build();

  static ThemeData _build() {
    const c = _AppTokens();

    final textTheme = AppType.buildTextTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
      tertiary: c.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: appColorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,

      // ── Typo ────────────────────────────────────────────────────────────
      textTheme: textTheme,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: c.appBarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
          letterSpacing: -0.2,
        ),
      ),

      // ── Bottom Nav ───────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Nav Bar M3 ────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? c.primary
                : c.textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? c.primary : c.textTertiary,
          );
        }),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textTertiary,
        indicatorColor: c.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: c.divider,
      ),

      // ── Boutons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusButton),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusButton),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        contentPadding: AppDesign.paddingInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(
            color: AppInputTokens.focusColor,
            width: AppInputTokens.focusBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: c.textHint),
        labelStyle: TextStyle(color: c.textSecondary),
        prefixIconColor: c.textTertiary,
        suffixIconColor: c.textTertiary,
        errorStyle: TextStyle(fontSize: 11, color: c.error),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusCard),
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.primary.withValues(alpha: 0.15),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusChip),
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: c.textPrimary,
        ),
        padding: AppDesign.paddingChip,
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.sheetBg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDesign.radiusSheet),
          ),
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radius16),
        ),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: c.textSecondary,
          height: 1.5,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusCard),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Switch ───────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Colors.white : c.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.border,
        ),
      ),

      // ── List Tile ────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: c.textTertiary,
        textColor: c.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: c.textSecondary, size: 22),
      primaryIconTheme: IconThemeData(color: c.primary),
    );
  }
}

class AppShadows {
  static List<BoxShadow> get storyCircle => [
    BoxShadow(
      // Story circles need a very subtle lift on light surfaces.
      color: AppColors.inkDark.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryButton => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}

class AppDecorations {
  static BoxDecoration card(BuildContext context) => BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: context.colors.border),
  );

  static BoxDecoration cardElevated(BuildContext context) => BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.elevated,
  );

  static BoxDecoration primaryBadge({bool outlined = false}) => BoxDecoration(
    color: outlined
        ? Colors.transparent
        : AppColors.primary.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(AppRadius.badge),
    border: outlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
  );
}

// ─── 6. BUILD CONTEXT EXTENSIONS ─────────────────────────────────────────────
// Usage : context.colors.primary  /  context.text.bodyM  /  context.isDark

extension AppDesignContext on BuildContext {
  /// Couleurs adaptées au thème courant
  AppColorTokens get colors => AppColorTokens(this);

  /// Styles de texte adaptés au thème courant
  TextTheme get text => Theme.of(this).textTheme;

  /// true si le thème courant est dark
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// ColorScheme du thème courant
  ColorScheme get scheme => Theme.of(this).colorScheme;

  bool get isAppTheme =>
      !isDark && scheme.surfaceContainerHighest == AppColors.surfaceAlt;
}

extension AppAccountTextStyles on BuildContext {
  TextStyle get accountProfileNameStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.h3,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get accountProfileMetaStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
  );

  TextStyle get accountSectionStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: colors.textTertiary,
    letterSpacing: 1.0,
  );

  TextStyle get accountMenuTitleStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get accountMenuSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get accountStoryLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
  );

  TextStyle get accountDialogTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );
}

extension AppBarTextStyles on BuildContext {
  TextStyle get appBarTitleStyle =>
      (Theme.of(this).appBarTheme.titleTextStyle ?? text.titleLarge ?? const TextStyle())
          .copyWith(color: colors.textPrimary);

  TextStyle get appBarSubtitleStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: colors.primary,
  );

  TextStyle get appBarPillStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w800,
    color: colors.primary,
    letterSpacing: -0.3,
  );

  TextStyle get appBarAccentTitleStyle => text.headlineLarge!.copyWith(
    fontSize: AppFontSize.h2Lg,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
    letterSpacing: -0.3,
  );

  TextStyle get appBarLocationLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get appBarAvatarLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get appBarBadgeStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  TextStyle get appBarPanelTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get appBarSectionLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: colors.textTertiary,
    letterSpacing: 0.8,
  );

  TextStyle get appBarSheetAccountTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get appBarSheetAccountSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get appBarSheetItemTitleStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get appBarSheetItemSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get appBarMutedMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textTertiary,
  );

  TextStyle get appBarEmptyStateStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textTertiary,
  );

  TextStyle get appBarSheetActionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get appBarDangerActionStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  TextStyle get appBarSearchHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textHint,
  );
}

extension AppNavTextStyles on BuildContext {
  TextStyle get navLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w400,
    color: colors.textTertiary,
  );

  TextStyle get navLabelSelectedStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  TextStyle get navFabLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get navTabLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  TextStyle get navTabUnselectedLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );
}

extension AppStoryTextStyles on BuildContext {
  TextStyle get storyLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get storyViewedLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get storyFallbackStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  TextStyle get storySheetTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get storyCategoryPillStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get storyCaptionInputStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    height: 1.4,
    color: Colors.white,
  );

  TextStyle get storyCaptionHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    color: Colors.white.withValues(alpha: 0.5),
  );

  TextStyle get storyOverlayCaptionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.5,
    color: Colors.white,
  );

  TextStyle get storyAuthorNameStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get storyMetaStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: Colors.white.withValues(alpha: 0.7),
  );

  TextStyle get storyActionStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  TextStyle get storySheetBodyStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get storyDangerActionStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  TextStyle get storySheetPrimaryTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get storyEditFieldStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.45,
    color: colors.textPrimary,
  );

  TextStyle get storyEditHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textHint,
  );

  TextStyle get storyEditCounterStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    color: colors.textHint,
  );

  TextStyle get storySectionFieldLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textSecondary,
  );

  TextStyle get storySecondaryActionStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  TextStyle get storyChipLabelStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
  );

  TextStyle get storyOwnerSheetActionStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get storyOwnerSheetDangerActionStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
}

extension AppReviewTextStyles on BuildContext {
  TextStyle get reviewPageTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get reviewSummaryScoreStyle => text.displaySmall!.copyWith(
    fontSize: AppFontSize.d4,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get reviewSummaryMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get reviewDistributionLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get reviewDistributionCountStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get reviewEmptyStateStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
  );

  TextStyle get reviewAuthorStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get reviewMissionStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get reviewDateStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: colors.textTertiary,
  );

  TextStyle get reviewBadgeStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  TextStyle get reviewCommentStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
    height: 1.5,
  );
}

extension AppProfileTextStyles on BuildContext {
  TextStyle get profilePageTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get profileSectionTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get profilePrimaryLabelStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get profileSecondaryLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get profileMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textSecondary,
  );

  TextStyle get profileTertiaryStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get profileTagStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get profileValueStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetFieldLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w400,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetFieldValueStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetPlaceholderStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textHint,
  );

  TextStyle get profileSheetSectionStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetCounterStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetActionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
    decoration: TextDecoration.underline,
    decorationColor: colors.textSecondary,
  );

  TextStyle get profileErrorStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: AppColors.error,
  );

  TextStyle get profileSliderValueStyle => text.labelSmall!.copyWith(
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}
