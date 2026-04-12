/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - Profile Feature Barrel
/// Profil, paramètres, wallet, sécurité, compétences, vérification identité
/// ═══════════════════════════════════════════════════════════════════════════
library;

// ─── Data Models ──────────────────────────────────────────────────────────────
export 'data/models/transaction.dart';
export 'data/models/skill.dart';
export 'data/models/user_profile.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────
export 'profile_provider.dart';

// ─── Widgets - Shared ─────────────────────────────────────────────────────────
export 'presentation/widgets/shared/user_common_widgets.dart';

// ─── Widgets - Client ─────────────────────────────────────────────────────────
export 'presentation/widgets/client/client_widgets.dart';

// ─── Widgets - Freelancer ─────────────────────────────────────────────────────
export 'presentation/widgets/freelancer/freelancer_widgets.dart';

// ─── Pages - Shared ───────────────────────────────────────────────────────────
export 'presentation/pages/shared/account_page.dart';
export 'presentation/pages/shared/settings_page.dart';
export 'presentation/pages/shared/change_password_page.dart';
export 'presentation/pages/shared/security_page.dart';
export 'presentation/pages/shared/wallet_page.dart' hide TransactionType;
export 'presentation/pages/shared/payment_history_page.dart';
export 'presentation/pages/shared/notifications_settings_page.dart';
export 'presentation/pages/shared/privacy_page.dart';
export 'presentation/pages/shared/privacy_settings_page.dart';
export 'presentation/pages/shared/help_center_page.dart';

// ─── Pages - Client ───────────────────────────────────────────────────────────
export 'presentation/pages/client/client_wallet_page.dart';
export 'presentation/pages/client/client_payment_methods_page.dart';
export 'presentation/pages/client/client_payment_history_page.dart';

// ─── Pages - Freelancer ───────────────────────────────────────────────────────
export 'presentation/pages/freelancer/edit_profile_page.dart';
export 'presentation/pages/freelancer/skills_page.dart';
export 'presentation/pages/freelancer/identity_verification_page.dart';
export 'presentation/pages/freelancer/my_posts_page.dart';
export 'presentation/pages/freelancer/freelancer_payment_methods_page.dart';
