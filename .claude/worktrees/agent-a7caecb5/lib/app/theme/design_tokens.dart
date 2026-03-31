import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎨 Inkern - Design Tokens (source unique)
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Couleurs ─────────────────────────────────────────────────────────────────

class AppColors {
  // ── Principale — Inkern Mint (identité unique, ≠ Apple green) ──────────────
  static const Color primary     = Color(0xFF00C896); // Mint vif, signature Inkern
  static const Color primaryDark = Color(0xFF00A87E); // Hover / pressed
  static const Color primaryLight = Color(0xFFE5FAF5); // Fond teinté léger

  // ── Secondaire — Navy profond (contraste premium) ─────────────────────────
  static const Color secondary     = Color(0xFF1E3A5F);
  static const Color secondaryLight = Color(0xFFEAEFF6);

  // ── Statuts ────────────────────────────────────────────────────────────────
  static const Color urgent  = Color(0xFFEF4444); // Rouge doux (Tailwind red-500)
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B); // Ambre chaud
  static const Color info    = Color(0xFF3B82F6); // Bleu vif
  static const Color success = Color(0xFF00C896); // = primary
  static const Color rating  = Color(0xFFF59E0B); // = warning
  static const Color gold    = Color(0xFFF59E0B);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F9FC); // Blanc bleuté premium
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F4F8); // Cards secondaires
  static const Color chipBg     = Color(0xFFFFFFFF);

  // ── Bordures ───────────────────────────────────────────────────────────────
  static const Color border  = Color(0xFFE2E8F0); // Slate-200
  static const Color divider = Color(0xFFF1F5F9); // Slate-100

  // ── Textes ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A); // Slate-900 (plus riche que #1A1A1A)
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textTertiary  = Color(0xFF94A3B8); // Slate-400
  static const Color textHint      = Color(0xFFCBD5E1); // Slate-300

  // ── Sémantiques ────────────────────────────────────────────────────────────
  static const Color online     = Color(0xFF00C896);
  static const Color disabled   = Color(0xFFCBD5E1);
  static const Color draft      = Color(0xFFB45309); // Amber-700
  static const Color verifiedBg = Color(0xFFE5FAF5);

  // ── Mission status UI banners ──────────────────────────────────────────────
  static const Color greenActive        = Color(0xFF10B981); // Emerald-500 (en cours)
  static const Color greenActiveDark    = Color(0xFF059669); // Emerald-600 (gradient)
  static const Color greenActiveLight   = Color(0xFFECFDF5); // Emerald-50 (bg)
  static const Color blueTracking       = Color(0xFF2563EB); // Blue-600 (en route)
  static const Color blueTrackingBorder = Color(0xFF93C5FD); // Blue-300 (border)
  static const Color blueTrackingText   = Color(0xFF1D4ED8); // Blue-700 (text)
  static const Color iosBlue            = Color(0xFF007AFF); // iOS system blue
  static const Color purple             = Color(0xFF7C3AED); // Violet-600 (confirmée)
  static const Color purpleLight        = Color(0xFFF5F3FF); // Violet-50 (bg)
  static const Color greenSystem        = Color(0xFF34C759); // iOS green (terminée)
  static const Color amberLight         = Color(0xFFFFF8E1); // Amber-50 (rating bg)
  static const Color warningLight       = Color(0xFFFFF7ED); // Orange-50 (waitingPayment bg)
  static const Color errorLight         = Color(0xFFFFF1F0); // Red-50 (cancelled bg)
  static const Color cancelRed          = Color(0xFFFF3B30); // iOS red (annulée/litige)

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Color get lightBlue => const Color(0xFFEFF6FF);
}

// ─── Rayons ───────────────────────────────────────────────────────────────────

class AppRadius {
  static const double xs     = 6;
  static const double small  = 8;
  static const double badge  = 10;
  static const double input  = 12;
  static const double button = 14;
  static const double card   = 16;  // ← valeur unique, partout
  static const double cardLg = 20;  // modales, bottom sheets
  static const double chip   = 24;
  static const double full   = 999;
}

// ─── Espacement ───────────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 24;
  static const double xxxl = 32;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const SizedBox sectionGap = SizedBox(height: 24);
  static const SizedBox smallGap   = SizedBox(height: 8);
  static const SizedBox tinyGap    = SizedBox(height: 4);
}

// ─── Padding ──────────────────────────────────────────────────────────────────

class AppPadding {
  static const EdgeInsets card      = EdgeInsets.all(16);
  static const EdgeInsets cardLarge = EdgeInsets.all(20);
  static const EdgeInsets page      = EdgeInsets.all(16);
  static const EdgeInsets chip      = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
  static const EdgeInsets chipCompact = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
}

// ─── Styles de texte ──────────────────────────────────────────────────────────
// La police (Plus Jakarta Sans) est injectée globalement via ThemeData dans main.dart.
// Ces styles héritent automatiquement de la font family du thème.

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.25, letterSpacing: -0.3);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2);
  static const TextStyle h4 = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static const TextStyle body      = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const TextStyle caption   = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.1);

  static const TextStyle label      = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle labelSmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);

  static const TextStyle price      = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary);
  static const TextStyle priceLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5);
}

// ─── Ombres ───────────────────────────────────────────────────────────────────

class AppShadows {
  // Ombre neutre subtile pour les cards standard
  static List<BoxShadow> get card => [
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3)),
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 4,  offset: const Offset(0, 1)),
  ];

  // Ombre plus marquée pour les éléments flottants
  static List<BoxShadow> get elevated => [
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 6,  offset: const Offset(0, 2)),
  ];

  // Ombre colorée (signature premium) pour les boutons primaires
  static List<BoxShadow> get primaryButton => [
    BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
    BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 4,  offset: const Offset(0, 2)),
  ];

  // Ombre légère pour les éléments interactifs
  static List<BoxShadow> get button => [
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 3)),
  ];
}

// ─── Décorations ──────────────────────────────────────────────────────────────

class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.elevated,
  );

  static BoxDecoration primaryBadge({bool outlined = false}) => BoxDecoration(
    color: outlined ? Colors.transparent : AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppRadius.badge),
    border: outlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
  );
}
