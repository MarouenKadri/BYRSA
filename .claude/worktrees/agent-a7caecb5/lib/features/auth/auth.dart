// ─── Models ───────────────────────────────────────────────────────────────────
export 'data/models/user_type.dart';
export 'data/models/service_type.dart';
export 'data/models/registration_data.dart';
export 'data/models/freelancer.dart';

// ─── Services ─────────────────────────────────────────────────────────────────
export 'services/image_picker_service.dart';

// ─── Widgets partagés ─────────────────────────────────────────────────────────
export 'presentation/widgets/google_sign_in_button.dart';
export 'presentation/widgets/auth_header.dart';
export 'presentation/widgets/auth_scaffold.dart';
export 'presentation/widgets/category_chip.dart';
export 'presentation/widgets/custom_text_field.dart';
export 'presentation/widgets/payment_security_card.dart';
export 'presentation/widgets/phone_input_field.dart';
export 'presentation/widgets/photo_picker.dart';
export 'presentation/widgets/primary_button.dart';
export 'presentation/widgets/service_chip.dart';
export 'presentation/widgets/status_dot_badge.dart';
export 'presentation/widgets/step_indicator.dart';
export 'presentation/widgets/top_freelancer_card.dart';
export 'presentation/widgets/user_type_card.dart';

// ─── Pages : Accueil ──────────────────────────────────────────────────────────
export 'presentation/pages/home/home_page.dart';

// ─── Pages : Connexion ────────────────────────────────────────────────────────
export 'presentation/pages/login/login_page.dart';

// ─── Pages : Mot de passe oublié ──────────────────────────────────────────────
export 'presentation/pages/forgot_password/forgot_password_page.dart';
export 'presentation/pages/forgot_password/reset_otp_page.dart';
export 'presentation/pages/forgot_password/reset_password_page.dart';

// ─── Pages : Vérification ─────────────────────────────────────────────────────
export 'presentation/pages/verification/verification_method_page.dart';
export 'presentation/pages/verification/otp_verification_page.dart';

// ─── Pages : Inscription (flux PageView BlaBlaCar-style) ─────────────────────
export 'presentation/pages/register/register_flow.dart';
export 'presentation/pages/register/step6_usertype_page.dart'; // RegistrationSuccessPage
