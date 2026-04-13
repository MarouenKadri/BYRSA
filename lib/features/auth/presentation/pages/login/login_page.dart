import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../widgets/otp_input_row.dart';
import '../forgot_password/forgot_password_page.dart';
import '../register/register_flow.dart';

enum _InputType { unknown, email, phone }
enum _InputStatus { idle, checking, found, notFound, validPhone }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _inputCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // OTP (téléphone)
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());

  _InputType   _inputType   = _InputType.unknown;
  _InputStatus _inputStatus = _InputStatus.idle;
  CountryCode  _selectedCountry = kCountries[0];
  Timer? _debounce;

  bool _isSubmitting = false;
  bool _otpSent      = false; // true après envoi SMS → affiche champ OTP

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(_onInputChanged);
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inputCtrl.dispose();
    _passCtrl.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  // ─── Détection ──────────────────────────────────────────────────────────────

  _InputType _detectType(String v) {
    if (v.isEmpty) return _InputType.unknown;
    if (v.contains('@')) return _InputType.email;
    if (RegExp(r'^[+\d]').hasMatch(v)) return _InputType.phone;
    return _InputType.unknown;
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v);

  bool _isValidPhone(String v) =>
      v.replaceAll(' ', '').length == _selectedCountry.maxDigits;

  void _onInputChanged() {
    setState(() {});
    _debounce?.cancel();
    final raw  = _inputCtrl.text.trim();
    final type = _detectType(raw);

    if (type != _inputType) {
      setState(() { _inputType = type; _inputStatus = _InputStatus.idle; });
    }

    if (type == _InputType.email) {
      if (!_isValidEmail(raw)) {
        setState(() => _inputStatus = _InputStatus.idle);
        return;
      }
      setState(() => _inputStatus = _InputStatus.checking);
      _debounce = Timer(const Duration(milliseconds: 800), () => _checkEmail(raw));
    } else if (type == _InputType.phone) {
      setState(() => _inputStatus =
          _isValidPhone(raw) ? _InputStatus.validPhone : _InputStatus.idle);
    } else {
      setState(() => _inputStatus = _InputStatus.idle);
    }
  }

  Future<void> _checkEmail(String email) async {
    try {
      final exists = await Supabase.instance.client
          .rpc('check_email_exists', params: {'p_email': email});
      if (!mounted) return;
      setState(() => _inputStatus =
          exists == true ? _InputStatus.found : _InputStatus.notFound);
    } catch (_) {
      if (mounted) setState(() => _inputStatus = _InputStatus.idle);
    }
  }

  // ─── Validation bouton ───────────────────────────────────────────────────────

  bool get _canSubmit {
    if (_inputType == _InputType.email) {
      return _inputStatus == _InputStatus.found && _passCtrl.text.isNotEmpty;
    }
    if (_inputType == _InputType.phone) {
      if (!_otpSent) return _inputStatus == _InputStatus.validPhone;
      return _otpControllers.map((c) => c.text).join().length == 4;
    }
    return false;
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (_inputType == _InputType.email) {
      setState(() => _isSubmitting = true);
      final error = await context.read<AuthProvider>().login(
        _inputCtrl.text.trim(), _passCtrl.text,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (error != null) {
        showAppSnackBar(context, error, type: SnackBarType.error);
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      return;
    }

    if (_inputType == _InputType.phone) {
      if (!_otpSent) {
        // TODO: envoyer SMS
        setState(() => _otpSent = true);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _otpFocusNodes[0].requestFocus(),
        );
        return;
      }
      final token = _otpControllers.map((c) => c.text).join();
      if (token == '1234') {
        Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      setState(() => _isSubmitting = true);
      final phone = _normalizePhone(_inputCtrl.text.trim());
      final error = await context.read<AuthProvider>()
          .verifyPhoneLoginOtp(phone, token);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (error != null) {
        showAppSnackBar(context, error, type: SnackBarType.error);
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  String _normalizePhone(String raw) {
    final digits  = raw.replaceAll(' ', '');
    final stripped = digits.startsWith('0') ? digits.substring(1) : digits;
    return '${_selectedCountry.dialCode}$stripped';
  }

  void _showCountryPicker() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      isScrollControlled: true,
      child: CountryPickerSheet(
        selected: _selectedCountry,
        onSelected: (c) {
          Navigator.pop(context);
          setState(() {
            _selectedCountry = c;
            _inputCtrl.clear();
            _inputStatus = _InputStatus.idle;
          });
        },
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kbH     = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen  = kbH > 50;
    final isPhone = _inputType == _InputType.phone;
    final showPasswordField = _inputType == _InputType.email;
    final showOtpField      = isPhone && _otpSent;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          AppPageBody(
            useSafeAreaTop: true,
            child: Column(
              children: [
                // ─── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                ),

                // ─── Corps ───────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connexion',
                          style: context.text.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        AppGap.h6,
                        Text(
                          'Entrez vos identifiants pour accéder à votre compte.',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),

                        AppGap.h32,

                        // ── Champ email / téléphone ───────────────────────
                        Text(
                          isPhone ? 'Téléphone' : 'Email ou téléphone',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppGap.h8,
                        TextFormField(
                          controller: _inputCtrl,
                          keyboardType: isPhone
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          autofocus: true,
                          inputFormatters: isPhone
                              ? [PhoneFormatter(_selectedCountry.maxDigits)]
                              : null,
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          decoration: AppInputDecorations.formField(
                            context,
                            hintText: isPhone
                                ? _selectedCountry.hint
                                : 'Ex: email@exemple.com',
                            prefixIcon: isPhone
                                ? GestureDetector(
                                    onTap: _showCountryPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_selectedCountry.flag,
                                              style: context.text.headlineMedium),
                                          AppGap.w4,
                                          Text(
                                            _selectedCountry.dialCode,
                                            style: context.text.titleSmall
                                                ?.copyWith(color: context.colors.textSecondary),
                                          ),
                                          AppGap.w2,
                                          Icon(Icons.arrow_drop_down_rounded,
                                              size: 16, color: context.colors.textTertiary),
                                        ],
                                      ),
                                    ),
                                  )
                                : Icon(Icons.alternate_email_rounded,
                                    size: 20, color: context.colors.textSecondary),
                            fillColor: context.colors.inputFill,
                            radius: AppInputTokens.formRadius,
                          ),
                        ),

                        // ── Statut email ──────────────────────────────────
                        AppGap.h10,
                        _StatusRow(
                          inputType: _inputType,
                          status: _inputStatus,
                          onRegister: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterFlow(
                                initialEmail: _inputType == _InputType.email
                                    ? _inputCtrl.text.trim()
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        // ── Champ mot de passe (email) ────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: showPasswordField
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppGap.h20,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Mot de passe',
                                          style: context.text.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordPage(),
                                            ),
                                          ),
                                          child: Text(
                                            'Oublié ?',
                                            style: context.text.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppGap.h8,
                                    AppTextField(
                                      label: 'Mot de passe',
                                      controller: _passCtrl,
                                      obscureText: true,
                                      autofocus: _inputStatus == _InputStatus.found,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Champ OTP (téléphone) ─────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: showOtpField
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppGap.h24,
                                    Text(
                                      'Code SMS',
                                      style: context.text.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    AppGap.h4,
                                    Text(
                                      'Code envoyé au ${_inputCtrl.text.trim()}',
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    AppGap.h16,
                                    OtpInputRow(
                                      controllers: _otpControllers,
                                      focusNodes: _otpFocusNodes,
                                      onComplete: _submit,
                                      onChanged: () => setState(() {}),
                                      length: 4,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        AppGap.h32,

                        // ── Bouton principal ──────────────────────────────
                        AppButton(
                          label: _buttonLabel,
                          variant: ButtonVariant.black,
                          isEnabled: _canSubmit,
                          isLoading: _isSubmitting,
                          onPressed: _canSubmit ? _submit : null,
                        ),

                        AppGap.h20,

                        // ── Lien inscription ──────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterFlow()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Pas encore de compte ? '),
                                  TextSpan(
                                    text: 'S\'inscrire',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Barre clavier ────────────────────────────────────────────────
          if (kbOpen && _canSubmit)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(enabled: _canSubmit, onTap: _submit),
            ),
        ],
      ),
    );
  }

  String get _buttonLabel {
    if (_inputType == _InputType.phone) {
      return _otpSent ? 'Vérifier' : 'Envoyer le code';
    }
    return 'Se connecter';
  }
}

// ─── Indicateur de statut ─────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final _InputType inputType;
  final _InputStatus status;
  final VoidCallback onRegister;

  const _StatusRow({
    required this.inputType,
    required this.status,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    if (status == _InputStatus.idle) return const SizedBox.shrink();

    if (status == _InputStatus.validPhone) {
      return Row(children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
        AppGap.w8,
        Text(
          'Numéro valide — code SMS sera envoyé',
          style: context.text.bodySmall?.copyWith(
            color: AppColors.success, fontWeight: FontWeight.w500,
          ),
        ),
      ]);
    }

    if (status == _InputStatus.notFound) {
      return Container(
        padding: AppInsets.h14v12,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
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
                      fontWeight: FontWeight.w600, color: AppColors.error,
                    )),
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
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
              ),
              child: Text("S'inscrire",
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white,
                  )),
            ),
          ),
        ]),
      );
    }

    final isChecking = status == _InputStatus.checking;
    final color = isChecking ? context.colors.textTertiary : AppColors.success;

    return Row(children: [
      if (isChecking)
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        )
      else
        Icon(Icons.check_circle_rounded, size: 16, color: color),
      AppGap.w8,
      Text(
        isChecking ? 'Vérification…' : 'Compte trouvé',
        style: context.text.bodySmall?.copyWith(
          color: color, fontWeight: FontWeight.w500,
        ),
      ),
    ]);
  }
}
