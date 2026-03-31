import 'package:flutter/material.dart';

// ─── 1. COULEURS ─────────────────────────────────────────────────────────────

abstract class AppColorsDark {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF34C759);
  static const primaryDark  = Color(0xFF28A745);
  static const secondary    = Color(0xFF007AFF);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const background   = Color(0xFF1A1A1A);
  static const surface      = Color(0xFF252525);
  static const surfaceAlt   = Color(0xFF2C2C2E);
  static const sheetBg      = Color(0xFF1C1C1E); // bottom sheets / modals
  static const inputFill    = Color(0xFF2A2A2A); // champs de formulaire

  // ── Bordures ─────────────────────────────────────────────────────────────
  static const border       = Color(0xFF3A3A3A);
  static const divider      = Color(0xFF3A3A3A);

  // ── Textes ───────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAAAAAA);
  static const textTertiary  = Color(0xFF8E8E93);
  static const textHint      = Color(0xFF636366);

  // ── Statuts ──────────────────────────────────────────────────────────────
  static const error    = Color(0xFFFF3B30);
  static const warning  = Color(0xFFFF9500);
  static const success  = Color(0xFF34C759);
  static const info     = Color(0xFF007AFF);
  static const rating   = Color(0xFFFFCC00);

  // ── Sémantiques missions ──────────────────────────────────────────────────
  static const errorLight   = Color(0xFF2A0A0A);
  static const warningLight = Color(0xFF2A1A00);
  static const successLight = Color(0xFF1A3A2A);
  static const infoLight    = Color(0xFF0A2A4A);
  static const purpleLight  = Color(0xFF2A1A3A);
}

abstract class AppColorsLight {
  // ── Brand (identique) ─────────────────────────────────────────────────────
  static const primary      = Color(0xFF34C759);
  static const primaryDark  = Color(0xFF28A745);
  static const secondary    = Color(0xFF007AFF);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const background   = Color(0xFFF5F5F5);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFF0F0F0);
  static const sheetBg      = Color(0xFFFFFFFF);
  static const inputFill    = Color(0xFFFFFFFF);

  // ── Bordures ─────────────────────────────────────────────────────────────
  static const border       = Color(0xFFE0E0E0);
  static const divider      = Color(0xFFEEEEEE);

  // ── Textes ───────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF111111);
  static const textSecondary = Color(0xFF555555);
  static const textTertiary  = Color(0xFF888888);
  static const textHint      = Color(0xFFBBBBBB);

  // ── Statuts ──────────────────────────────────────────────────────────────
  static const error    = Color(0xFFFF3B30);
  static const warning  = Color(0xFFFF9500);
  static const success  = Color(0xFF34C759);
  static const info     = Color(0xFF007AFF);
  static const rating   = Color(0xFFFFCC00);

  // ── Sémantiques ──────────────────────────────────────────────────────────
  static const errorLight   = Color(0xFFFFEDED);
  static const warningLight = Color(0xFFFFF3E0);
  static const successLight = Color(0xFFE8F5E9);
  static const infoLight    = Color(0xFFE3F2FD);
  static const purpleLight  = Color(0xFFF3E5F5);
}

abstract class AppColorsIndeed {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF0088CC);
  static const primaryDark  = Color(0xFF006699);
  static const secondary    = Color(0xFFE0F2FE);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const background   = Color(0xFFFFFFFF);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFF3F4F6); // empreinte unique pour détection
  static const sheetBg      = Color(0xFFFFFFFF);
  static const inputFill    = Color(0xFFF8FAFC);

  // ── Bordures ─────────────────────────────────────────────────────────────
  static const border       = Color(0xFFF1F5F9);
  static const divider      = Color(0xFFF1F5F9);

  // ── Textes ───────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary  = Color(0xFF94A3B8);
  static const textHint      = Color(0xFFCBD5E1);

  // ── Statuts ──────────────────────────────────────────────────────────────
  static const error    = Color(0xFFEF4444);
  static const warning  = Color(0xFFF59E0B);
  static const success  = Color(0xFF10B981);
  static const info     = Color(0xFF0088CC);
  static const rating   = Color(0xFFFFCC00);

  // ── Sémantiques ──────────────────────────────────────────────────────────
  static const errorLight   = Color(0xFFFEE2E2);
  static const warningLight = Color(0xFFFEF3C7);
  static const successLight = Color(0xFFD1FAE5);
  static const infoLight    = Color(0xFFE0F2FE);
  static const purpleLight  = Color(0xFFF3E5F5);
}

abstract class AppColorsWarm {
  // ── Brand (identique à la charte Inkern) ──────────────────────────────────
  static const primary      = Color(0xFF34C759);
  static const primaryDark  = Color(0xFF28A745);
  static const secondary    = Color(0xFF007AFF);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const background   = Color(0xFFFFFFFF);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFF5F5F5); // sert à détecter le thème
  static const sheetBg      = Color(0xFFFFFFFF);
  static const inputFill    = Color(0xFFF5F5F5); // fond input sans bordure

  // ── Sans bordures ─────────────────────────────────────────────────────────
  static const border       = Color(0x00000000); // transparent
  static const divider      = Color(0xFFF2F2F2); // séparateur très discret

  // ── Textes noir pur / gris ────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF000000); // noir pur
  static const textSecondary = Color(0xFF666666); // gris moyen
  static const textTertiary  = Color(0xFF999999);
  static const textHint      = Color(0xFFBBBBBB);

  // ── Statuts (identiques au thème light) ──────────────────────────────────
  static const error    = Color(0xFFFF3B30);
  static const warning  = Color(0xFFFF9500);
  static const success  = Color(0xFF34C759);
  static const info     = Color(0xFF007AFF);
  static const rating   = Color(0xFFFFCC00);

  // ── Sémantiques ──────────────────────────────────────────────────────────
  static const errorLight   = Color(0xFFFFEDED);
  static const warningLight = Color(0xFFFFF3E0);
  static const successLight = Color(0xFFE8F5E9);
  static const infoLight    = Color(0xFFE3F2FD);
  static const purpleLight  = Color(0xFFF3E5F5);
}

// ─── 4. COLOR SCHEMES ────────────────────────────────────────────────────────

const darkColorScheme = ColorScheme.dark(
  primary:          AppColorsDark.primary,
  secondary:        AppColorsDark.secondary,
  surface:          AppColorsDark.surface,
  error:            AppColorsDark.error,
  onPrimary:        Colors.black,
  onSecondary:      Colors.white,
  onSurface:        AppColorsDark.textPrimary,
  onError:          Colors.white,
  outline:          AppColorsDark.border,
  outlineVariant:   AppColorsDark.divider,
  surfaceContainerHighest: AppColorsDark.surfaceAlt,
);

const lightColorScheme = ColorScheme.light(
  primary:          AppColorsLight.primary,
  secondary:        AppColorsLight.secondary,
  surface:          AppColorsLight.surface,
  error:            AppColorsLight.error,
  onPrimary:        Colors.white,
  onSecondary:      Colors.white,
  onSurface:        AppColorsLight.textPrimary,
  onError:          Colors.white,
  outline:          AppColorsLight.border,
  outlineVariant:   AppColorsLight.divider,
  surfaceContainerHighest: AppColorsLight.surfaceAlt,
);

const warmColorScheme = ColorScheme.light(
  primary:          AppColorsWarm.primary,
  secondary:        AppColorsWarm.secondary,
  surface:          AppColorsWarm.surface,
  error:            AppColorsWarm.error,
  onPrimary:        Colors.white,
  onSecondary:      Colors.white,
  onSurface:        AppColorsWarm.textPrimary,
  onError:          Colors.white,
  outline:          AppColorsWarm.border,
  outlineVariant:   AppColorsWarm.divider,
  surfaceContainerHighest: AppColorsWarm.surfaceAlt,
);

const indeedColorScheme = ColorScheme.light(
  primary:          AppColorsIndeed.primary,
  secondary:        AppColorsIndeed.secondary,
  surface:          AppColorsIndeed.surface,
  error:            AppColorsIndeed.error,
  onPrimary:        Colors.white,
  onSecondary:      Colors.white,
  onSurface:        AppColorsIndeed.textPrimary,
  onError:          Colors.white,
  outline:          AppColorsIndeed.border,
  outlineVariant:   AppColorsIndeed.divider,
  surfaceContainerHighest: AppColorsIndeed.surfaceAlt,
);

abstract class AppPalette {
  static const primaryLight = AppColorsIndeed.infoLight;
  static const urgent = AppColorsIndeed.error;
  static const gold = AppColorsIndeed.rating;
  static const iosBlue = AppColorsIndeed.secondary;
  static const info = AppColorsIndeed.info;
  static const success = AppColorsIndeed.success;
  static const warning = AppColorsIndeed.warning;
  static const amber = Color(0xFFFFB800);
  static const amberBg = Color(0xFFFFF8E1);
  static const amberDark = Color(0xFFF59E0B);
  static const amberLight = Color(0xFF2A1F00);
  static const amberText = Color(0xFFB45309);
  static const blueAction = Color(0xFF2563EB);
  static const blueBg = Color(0xFFEFF6FF);
  static const blueBorder = Color(0xFFBFDBFE);
  static const blueDark = Color(0xFF1D4ED8);
  static const blueLight = Color(0xFF3B82F6);
  static const blueNavy = Color(0xFF1E40AF);
  static const blueTracking = AppColorsIndeed.secondary;
  static const borderLight = Color(0xFFE8E8E8);
  static const cancelRed = AppColorsIndeed.error;
  static const deepNavy = Color(0xFF0F172A);
  static const draftAmber = Color(0xFFAA7700);
  static const errorStrong = Color(0xFFEF4444);
  static const gray400 = Color(0xFF9CA3AF);
  static const grayD1 = Color(0xFFD1D5DB);
  static const grayStory = Color(0xFFCDD3DA);
  static const greenActiveLight = Color(0xFF1A3A2A);
  static const greenEmerald = Color(0xFF10B981);
  static const greenForest = Color(0xFF2E7D32);
  static const greenMint = Color(0xFF66BB6A);
  static const greenNatural = Color(0xFF22C55E);
  static const greenSystem = AppColorsIndeed.success;
  static const indigo = Color(0xFF5856D6);
  static const indigoTW = Color(0xFF6366F1);
  static const mapGradientEnd = Color(0xFF253659);
  static const mapGradientStart = Color(0xFF1A2744);
  static const mastercardOrange = Color(0xFFEA580C);
  static const pinkRed = Color(0xFFFF3B5C);
  static const purple = Color(0xFFAF52DE);
  static const purpleLight = Color(0xFFF3E5F5);
  static const rating = AppColorsIndeed.rating;
  static const successBg = AppColorsIndeed.successLight;
  static const successBorder = Color(0xFF6EE7B7);
  static const successDark = Color(0xFF059669);
  static const successDarker = Color(0xFF047857);
  static const successDeep = Color(0xFF065F46);
  static const teal = Color(0xFF00C896);
  static const violet = Color(0xFF8B5CF6);
  static const lightBlue = Color(0xFF0A2A4A);
}

class AppColorTokens {
  final BuildContext _ctx;
  const AppColorTokens(this._ctx);

  bool get _dark  => _ctx.isDark;
  /// Thème Warm actif : détecté via surfaceContainerHighest unique
  bool get _warm  => !_dark && _ctx.scheme.surfaceContainerHighest == AppColorsWarm.surfaceAlt;
  /// Thème Indeed (bleu) actif : détecté via surfaceContainerHighest unique
  bool get _blue  => !_dark && _ctx.scheme.surfaceContainerHighest == AppColorsIndeed.surfaceAlt;

  Color get primary      => _blue ? AppColorsIndeed.primary     : (_warm ? AppColorsWarm.primary     : AppColorsDark.primary);
  Color get primaryDark  => _blue ? AppColorsIndeed.primaryDark : (_warm ? AppColorsWarm.primaryDark : AppColorsDark.primaryDark);
  Color get secondary    => _blue ? AppColorsIndeed.secondary   : (_warm ? AppColorsWarm.secondary   : AppColorsDark.secondary);

  Color get background   => _dark ? AppColorsDark.background : (_blue ? AppColorsIndeed.background : (_warm ? AppColorsWarm.background : AppColorsLight.background));
  Color get surface      => _dark ? AppColorsDark.surface    : (_blue ? AppColorsIndeed.surface    : (_warm ? AppColorsWarm.surface    : AppColorsLight.surface));
  Color get surfaceAlt   => _dark ? AppColorsDark.surfaceAlt : (_blue ? AppColorsIndeed.surfaceAlt : (_warm ? AppColorsWarm.surfaceAlt : AppColorsLight.surfaceAlt));
  Color get sheetBg      => _dark ? AppColorsDark.sheetBg    : (_blue ? AppColorsIndeed.sheetBg    : (_warm ? AppColorsWarm.sheetBg    : AppColorsLight.sheetBg));
  Color get inputFill    => _dark ? AppColorsDark.inputFill  : (_blue ? AppColorsIndeed.inputFill  : (_warm ? AppColorsWarm.inputFill  : AppColorsLight.inputFill));

  Color get border       => _dark ? AppColorsDark.border  : (_blue ? AppColorsIndeed.border  : (_warm ? AppColorsWarm.border  : AppColorsLight.border));
  Color get divider      => _dark ? AppColorsDark.divider : (_blue ? AppColorsIndeed.divider : (_warm ? AppColorsWarm.divider : AppColorsLight.divider));

  Color get textPrimary   => _dark ? AppColorsDark.textPrimary   : (_blue ? AppColorsIndeed.textPrimary   : (_warm ? AppColorsWarm.textPrimary   : AppColorsLight.textPrimary));
  Color get textSecondary => _dark ? AppColorsDark.textSecondary : (_blue ? AppColorsIndeed.textSecondary : (_warm ? AppColorsWarm.textSecondary : AppColorsLight.textSecondary));
  Color get textTertiary  => _dark ? AppColorsDark.textTertiary  : (_blue ? AppColorsIndeed.textTertiary  : (_warm ? AppColorsWarm.textTertiary  : AppColorsLight.textTertiary));
  Color get textHint      => _dark ? AppColorsDark.textHint      : (_blue ? AppColorsIndeed.textHint      : (_warm ? AppColorsWarm.textHint      : AppColorsLight.textHint));

  Color get error    => _blue ? AppColorsIndeed.error   : (_warm ? AppColorsWarm.error   : AppColorsDark.error);
  Color get warning  => _blue ? AppColorsIndeed.warning : (_warm ? AppColorsWarm.warning : AppColorsDark.warning);
  Color get success  => _blue ? AppColorsIndeed.success : (_warm ? AppColorsWarm.success : AppColorsDark.success);
  Color get info     => _blue ? AppColorsIndeed.info    : (_warm ? AppColorsWarm.info    : AppColorsDark.info);
  Color get rating   => AppColorsDark.rating;

  Color get errorLight   => _dark ? AppColorsDark.errorLight   : (_blue ? AppColorsIndeed.errorLight   : (_warm ? AppColorsWarm.errorLight   : AppColorsLight.errorLight));
  Color get warningLight => _dark ? AppColorsDark.warningLight : (_blue ? AppColorsIndeed.warningLight : (_warm ? AppColorsWarm.warningLight : AppColorsLight.warningLight));
  Color get successLight => _dark ? AppColorsDark.successLight : (_blue ? AppColorsIndeed.successLight : (_warm ? AppColorsWarm.successLight : AppColorsLight.successLight));
  Color get infoLight    => _dark ? AppColorsDark.infoLight    : (_blue ? AppColorsIndeed.infoLight    : (_warm ? AppColorsWarm.infoLight    : AppColorsLight.infoLight));
}

// ─── 7. LEGACY COMPATIBILITY ALIASES ────────────────────────────────────────
// These names are kept so older UI files still compile while the source of
// truth remains centralized in this single module.

class AppColors {
  static const Color primary = AppColorsIndeed.primary;
  static const Color primaryDark = AppColorsIndeed.primaryDark;
  static const Color primaryLight = AppPalette.primaryLight;
  static const Color secondary = AppColorsIndeed.secondary;
  static const Color background = AppColorsIndeed.background;
  static const Color textTertiary = AppColorsIndeed.textTertiary;
  static const Color error = AppColorsIndeed.error;
  static const Color warning = AppPalette.warning;
  static const Color info = AppPalette.info;
  static const Color success = AppPalette.success;
  static const Color urgent = AppPalette.urgent;
  static const Color rating = AppPalette.rating;
  static const Color gold = AppPalette.gold;
  static const Color amber = AppPalette.amber;
  static const Color amberBg = AppPalette.amberBg;
  static const Color amberDark = AppPalette.amberDark;
  static const Color amberLight = AppPalette.amberLight;
  static const Color amberText = AppPalette.amberText;
  static const Color blueAction = AppPalette.blueAction;
  static const Color blueBg = AppPalette.blueBg;
  static const Color blueBorder = AppPalette.blueBorder;
  static const Color blueDark = AppPalette.blueDark;
  static const Color blueLight = AppPalette.blueLight;
  static const Color blueNavy = AppPalette.blueNavy;
  static const Color blueTracking = AppPalette.blueTracking;
  static const Color borderLight = AppPalette.borderLight;
  static const Color cancelRed = AppPalette.cancelRed;
  static const Color deepNavy = AppPalette.deepNavy;
  static const Color draftAmber = AppPalette.draftAmber;
  static const Color errorStrong = AppPalette.errorStrong;
  static const Color gray400 = AppPalette.gray400;
  static const Color grayD1 = AppPalette.grayD1;
  static const Color grayStory = AppPalette.grayStory;
  static const Color greenActiveLight = AppPalette.greenActiveLight;
  static const Color greenEmerald = AppPalette.greenEmerald;
  static const Color greenForest = AppPalette.greenForest;
  static const Color greenMint = AppPalette.greenMint;
  static const Color greenNatural = AppPalette.greenNatural;
  static const Color greenSystem = AppPalette.greenSystem;
  static const Color indigo = AppPalette.indigo;
  static const Color indigoTW = AppPalette.indigoTW;
  static const Color iosBlue = AppPalette.iosBlue;
  static const Color lightBlue = AppPalette.lightBlue;
  static const Color mapGradientEnd = AppPalette.mapGradientEnd;
  static const Color mapGradientStart = AppPalette.mapGradientStart;
  static const Color mastercardOrange = AppPalette.mastercardOrange;
  static const Color pinkRed = AppPalette.pinkRed;
  static const Color purple = AppPalette.purple;
  static const Color purpleLight = AppPalette.purpleLight;
  static const Color successBg = AppPalette.successBg;
  static const Color successBorder = AppPalette.successBorder;
  static const Color successDark = AppPalette.successDark;
  static const Color successDarker = AppPalette.successDarker;
  static const Color successDeep = AppPalette.successDeep;
  static const Color teal = AppPalette.teal;
  static const Color violet = AppPalette.violet;
}

// BuildContext extensions needed by AppColorTokens
extension _AppColorTokensBuildContextExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get scheme => Theme.of(this).colorScheme;
}
