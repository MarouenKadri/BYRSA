import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20),
                        color: AppColors.textPrimary,
                        onPressed: _goBack,
                      ),
                      const Spacer(),
                      Text(
                        '${_page + 1} / $_totalSteps',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Barre de progression ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _ProgressBar(current: _page, total: _totalSteps),
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
                                builder: (_) => const RegisterFlow())),
                      ),
                      _PasswordStep(
                        ctrl: _passCtrl,
                        email: _emailCtrl.text.trim(),
                        onForgot: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage())),
                        onBack: _goBack,
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
              child: _KeyboardBar(
                  enabled: _canAdvance(), onTap: _goNext),
            ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    // Page 0 — email : arrow + Google
    if (_page == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Spacer(),
              _ArrowButton(enabled: _canAdvance(), onPressed: _goNext),
            ]),
            const SizedBox(height: 20),
            _GoogleDivider(),
            const SizedBox(height: 14),
            GoogleSignInButton(
              isLoading: _isGoogleLoading,
              onPressed: _handleGoogleSignIn,
            ),
          ],
        ),
      );
    }

    // Page 1 — mot de passe : arrow (login)
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          const Spacer(),
          _isSubmitting
              ? const SizedBox(
                  width: 60, height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.primary),
                  ),
                )
              : _ArrowButton(enabled: _canAdvance(), onPressed: _goNext),
        ],
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
          _pageHeader('Connexion', 'Entrez votre adresse email'),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'Adresse email',
            hint: 'exemple@mail.com',
            prefixIcon: Icons.alternate_email_rounded,
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
          const SizedBox(height: 12),
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
  final VoidCallback onBack;

  const _PasswordStep({
    required this.ctrl,
    required this.email,
    required this.onForgot,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader('Mot de passe', 'Entrez votre mot de passe'),
          const SizedBox(height: 28),

          // ── Champ ──────────────────────────────────────────────────────
          CustomTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: ctrl,
            obscureText: true,
            autofocus: true,
          ),
          const SizedBox(height: 8),

          // ── Mot de passe oublié ─────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onForgot,
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  fontSize: 13,
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
// Shared UI — copie exacte du style register_flow
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _ArrowButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.primary : AppColors.divider,
        ),
        child: const Icon(Icons.arrow_forward_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }
}

class _KeyboardBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _KeyboardBar({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: enabled ? onTap : null,
              child: Container(
                width: 52, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _pageHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(subtitle,
          style: TextStyle(
              fontSize: 15, color: AppColors.textSecondary)),
    ],
  );
}

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.person_off_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aucun compte avec cet email',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error)),
                const SizedBox(height: 1),
                const Text('Vérifiez l\'adresse ou créez un compte.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRegister,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("S'inscrire",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ]),
      );
    }

    final color = isChecking
        ? AppColors.textTertiary
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
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─── Séparateur Google ────────────────────────────────────────────────────────

class _GoogleDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'ou continuer avec Google',
          style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500),
        ),
      ),
      const Expanded(child: Divider(color: AppColors.border)),
    ]);
  }
}
