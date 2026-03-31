import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/google_sign_in_button.dart';
import '../forgot_password/forgot_password_page.dart';
import '../register/register_flow.dart';

// ─── Statut check email ───────────────────────────────────────────────────────

enum _EmailStatus { idle, checking, found, notFound }

// ─────────────────────────────────────────────────────────────────────────────
// LoginPage — 2-step flow : Email → Mot de passe
// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _pageController = PageController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  int _page = 0;
  static const int _totalSteps = 2;

  _EmailStatus _emailStatus = _EmailStatus.idle;
  Timer? _emailTimer;
  bool _isSubmitting = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailTimer?.cancel();
    _pageController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─── Logique ─────────────────────────────────────────────────────────────────

  bool _canAdvance() {
    if (_page == 0) return _emailStatus == _EmailStatus.found;
    if (_page == 1) return _passCtrl.text.isNotEmpty;
    return false;
  }

  void _onEmailChanged() {
    setState(() {});
    _emailTimer?.cancel();
    final email = _emailCtrl.text.trim();
    final valid = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
    if (!valid) {
      setState(() => _emailStatus = _EmailStatus.idle);
      return;
    }
    setState(() => _emailStatus = _EmailStatus.checking);
    _emailTimer = Timer(
      const Duration(milliseconds: 800),
      () => _checkEmail(email),
    );
  }

  Future<void> _checkEmail(String email) async {
    try {
      final exists = await Supabase.instance.client
          .rpc('check_email_exists', params: {'p_email': email});
      if (!mounted) return;
      final status = exists == true ? _EmailStatus.found : _EmailStatus.notFound;
      setState(() => _emailStatus = status);
      // Auto-advance si trouvé
      if (status == _EmailStatus.found) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _page == 0) _advance();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _emailStatus = _EmailStatus.idle);
    }
  }

  void _advance() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_page == 0) {
      Navigator.pop(context);
    } else {
      _passCtrl.clear();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _goNext() async {
    if (_page == 0) {
      _advance();
    } else {
      await _login();
    }
  }

  Future<void> _login() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final error = await context.read<AuthProvider>().login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      showAppSnackBar(context, error, type: SnackBarType.error);
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _isGoogleLoading = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    final showKbBar = kbOpen && _canAdvance();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          AppPageBody(
            useSafeAreaTop: true,
            child: Column(
              children: [
                AppProgressHeader(
                  currentStep: _page + 1,
                  totalSteps: _totalSteps,
                  onBack: _goBack,
                  stepLabel: const ['Adresse e-mail', 'Mot de passe'][_page],
                ),

                // ── PageView ───────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _EmailStep(
                        ctrl: _emailCtrl,
                        status: _emailStatus,
                        onGoogleSignIn: _handleGoogleSignIn,
                        isGoogleLoading: _isGoogleLoading,
                        onRegister: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => RegisterFlow(
                                    initialEmail: _emailCtrl.text.trim()))),
                      ),
                      _PasswordStep(
                        ctrl: _passCtrl,
                        email: _emailCtrl.text.trim(),
                        onForgot: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage())),
                      ),
                    ],
                  ),
                ),

                // ── Bouton bas (masqué clavier ouvert) ────────────────────
                if (!kbOpen) _buildBottom(),
              ],
            ),
          ),

          // ── Barre clavier ──────────────────────────────────────────────
          if (showKbBar)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(
                enabled: _canAdvance(),
                onTap: _goNext,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    // Page 0 — email
    if (_page == 0) {
      final showContinue = _emailStatus != _EmailStatus.notFound;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showContinue) ...[
              AppButton(
                label: 'Continuer',
                variant: ButtonVariant.black,
                isEnabled: _canAdvance(),
                onPressed: _canAdvance() ? _goNext : null,
              ),
              AppGap.h16,
            ],
            _GoogleDivider(),
            AppGap.h14,
            GoogleSignInButton(
              isLoading: _isGoogleLoading,
              onPressed: _handleGoogleSignIn,
            ),
          ],
        ),
      );
    }

    // Page 1 — mot de passe
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: AppButton(
        label: 'Se connecter',
        variant: ButtonVariant.black,
        isEnabled: _canAdvance(),
        isLoading: _isSubmitting,
        onPressed: _canAdvance() ? _goNext : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Étape 0 — Email
// ─────────────────────────────────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  final TextEditingController ctrl;
  final _EmailStatus status;
  final VoidCallback onGoogleSignIn;
  final bool isGoogleLoading;
  final VoidCallback onRegister;

  const _EmailStep({
    required this.ctrl,
    required this.status,
    required this.onGoogleSignIn,
    required this.isGoogleLoading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Connexion',
            subtitle: 'Entrez votre adresse email',
          ),
          AppGap.h36,
          _ShadowField(
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: GoogleFonts.inter(
                fontSize: AppFontSize.body,
                color: context.colors.textPrimary,
              ),
              decoration: _fieldDecoration(
                context,
                hint: 'exemple@mail.com',
                icon: Icons.alternate_email_rounded,
              ),
            ),
          ),
          AppGap.h12,
          _LoginStatusRow(status: status, onRegister: onRegister),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Étape 1 — Mot de passe
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStep extends StatelessWidget {
  final TextEditingController ctrl;
  final String email;
  final VoidCallback onForgot;

  const _PasswordStep({
    required this.ctrl,
    required this.email,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Mot de passe',
            subtitle: 'Entrez votre mot de passe',
          ),
          AppGap.h12,

          // ── Récap email ────────────────────────────────────────────────
          if (email.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alternate_email_rounded,
                      size: 13, color: context.colors.textTertiary),
                  AppGap.w6,
                  Text(
                    email,
                    style: context.text.labelMedium?.copyWith(
                      fontSize: AppFontSize.sm,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          AppGap.h24,

          // ── Champ ──────────────────────────────────────────────────────
          _ShadowField(child: _PasswordField(ctrl: ctrl)),
          AppGap.h8,

          // ── Mot de passe oublié ─────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onForgot,
              child: Text(
                'Mot de passe oublié ?',
                style: context.text.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─── Indicateur de statut email (login) ──────────────────────────────────────

class _LoginStatusRow extends StatelessWidget {
  final _EmailStatus status;
  final VoidCallback onRegister;
  const _LoginStatusRow({required this.status, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    if (status == _EmailStatus.idle) return const SizedBox.shrink();

    final isChecking = status == _EmailStatus.checking;
    final isFound = status == _EmailStatus.found;

    if (status == _EmailStatus.notFound) {
      return Container(
        padding: AppInsets.h14v12,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha:0.06),
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: AppColors.error.withValues(alpha:0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.person_off_rounded, size: 16, color: AppColors.error),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aucun compte avec cet email',
                    style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error)),
                const SizedBox(height: 1),
                Text('Vérifiez l\'adresse ou créez un compte.',
                    style: context.text.labelMedium),
              ],
            ),
          ),
          AppGap.w8,
          GestureDetector(
            onTap: onRegister,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
              ),
              child: Text("S'inscrire",
                  style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ]),
      );
    }

    final color = isChecking
        ? context.colors.textTertiary
        : isFound
            ? AppColors.success
            : AppColors.error;
    final label = isChecking
        ? 'Vérification…'
        : 'Compte trouvé — passage automatique';

    return Row(children: [
      if (isChecking)
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        )
      else
        Icon(Icons.check_circle_rounded, size: 16, color: color),
      AppGap.w8,
      Text(label,
          style: context.text.bodySmall?.copyWith(
              color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─── Séparateur Google ────────────────────────────────────────────────────────

class _GoogleDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: context.colors.border)),
      Padding(
        padding: AppInsets.h12,
        child: Text(
          'ou continuer avec Google',
          style: context.text.labelMedium?.copyWith(
              color: context.colors.textTertiary),
        ),
      ),
      Expanded(child: Divider(color: context.colors.border)),
    ]);
  }
}

// ─── Shadow field wrapper ─────────────────────────────────────────────────────

class _ShadowField extends StatelessWidget {
  final Widget child;
  const _ShadowField({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Décoration champ sans bordure ───────────────────────────────────────────

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: AppFontSize.body,
      color: context.colors.textHint,
    ),
    prefixIcon: Icon(icon, size: 16, color: context.colors.textSecondary),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    counterText: '',
  );
}

// ─── Champ mot de passe avec toggle ──────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final TextEditingController ctrl;
  const _PasswordField({required this.ctrl});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      obscureText: _obscure,
      autofocus: true,
      style: GoogleFonts.inter(
        fontSize: AppFontSize.body,
        color: context.colors.textPrimary,
      ),
      decoration: _fieldDecoration(
        context,
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: context.colors.textSecondary,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

