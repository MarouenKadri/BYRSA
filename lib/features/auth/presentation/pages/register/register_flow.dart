import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/navigation/root_nav.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import '../../mixins/otp_timer_mixin.dart';
import '../../utils/auth_formatters.dart';
import '../../widgets/otp_input_row.dart';
import '../../widgets/photo_picker.dart';

enum _FieldCheckStatus { idle, checking, available, taken }

// ─────────────────────────────────────────────────────────────────────────────
// RegisterFlow — 9-step BlaBlaCar-style PageView registration
// Steps: Email → Nom → Date → Genre → Mot de passe → Téléphone → OTP → Rôle → Photo
// ─────────────────────────────────────────────────────────────────────────────

class RegisterFlow extends StatefulWidget {
  final String? initialEmail;

  const RegisterFlow({super.key, this.initialEmail});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  final _data = RegistrationData();
  final _pageController = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // ── Text controllers ──────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── Field availability checks ─────────────────────────────────────────────
  _FieldCheckStatus _emailStatus = _FieldCheckStatus.idle;
  _FieldCheckStatus _phoneStatus = _FieldCheckStatus.idle;
  Timer? _emailTimer;
  Timer? _phoneTimer;

  // ── OTP (inline page 6) ───────────────────────────────────────────────────
  final _otpCtrls = List.generate(4, (_) => TextEditingController());
  final _otpNodes = List.generate(4, (_) => FocusNode());
  bool _otpSending = false;
  String get _otpCode => _otpCtrls.map((c) => c.text).join();

  // ── Step state ────────────────────────────────────────────────────────────
  DateTime? _birthDate;
  Gender? _gender;
  UserType? _userType;
  File? _photo;

  static const _totalSteps = 9;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailCtrl.text = widget.initialEmail!;
    }
    _emailCtrl.addListener(_onEmailChanged);
    for (final c in [_firstCtrl, _lastCtrl, _passCtrl]) {
      c.addListener(_rebuild);
    }
    _phoneCtrl.addListener(_onPhoneChanged);
    for (final c in _otpCtrls) {
      c.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  // ── Email check ───────────────────────────────────────────────────────────
  void _onEmailChanged() {
    setState(() {});
    _emailTimer?.cancel();
    final email = _emailCtrl.text.trim();
    final valid = email.contains('@') && email.lastIndexOf('.') > email.indexOf('@') + 1;
    if (!valid) {
      setState(() => _emailStatus = _FieldCheckStatus.idle);
      return;
    }
    setState(() => _emailStatus = _FieldCheckStatus.checking);
    _emailTimer = Timer(const Duration(milliseconds: 800), () => _checkEmail(email));
  }

  Future<void> _checkEmail(String email) async {
    try {
      final exists = await Supabase.instance.client
          .rpc('check_email_exists', params: {'p_email': email});
      if (!mounted) return;
      setState(() => _emailStatus =
          exists == true ? _FieldCheckStatus.taken : _FieldCheckStatus.available);
    } catch (_) {
      if (mounted) setState(() => _emailStatus = _FieldCheckStatus.idle);
    }
  }

  // ── Phone check ───────────────────────────────────────────────────────────
  void _onPhoneChanged() {
    setState(() {});
    _phoneTimer?.cancel();
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10) {
      setState(() => _phoneStatus = _FieldCheckStatus.idle);
      return;
    }
    setState(() => _phoneStatus = _FieldCheckStatus.checking);
    _phoneTimer = Timer(const Duration(milliseconds: 800), () => _checkPhone(digits));
  }

  Future<void> _checkPhone(String digits) async {
    try {
      final exists = await Supabase.instance.client
          .rpc('check_phone_exists', params: {'p_phone': digits});
      if (!mounted) return;
      setState(() => _phoneStatus =
          exists == true ? _FieldCheckStatus.taken : _FieldCheckStatus.available);
    } catch (_) {
      if (mounted) setState(() => _phoneStatus = _FieldCheckStatus.idle);
    }
  }

  @override
  void dispose() {
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    _pageController.dispose();
    for (final c in [_emailCtrl, _firstCtrl, _lastCtrl, _passCtrl, _phoneCtrl]) {
      c.dispose();
    }
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpNodes) f.dispose();
    super.dispose();
  }

  // ── Arrow enable logic ────────────────────────────────────────────────────
  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _emailStatus == _FieldCheckStatus.available;
      case 1:
        return _firstCtrl.text.trim().isNotEmpty &&
            _lastCtrl.text.trim().isNotEmpty;
      case 2:
        return _birthDate != null;
      case 3:
        return _gender != null;
      case 4:
        return _passCtrl.text.length >= 8;
      case 5:
        return _phoneStatus == _FieldCheckStatus.available;
      case 6:
        return _otpCode.length == 4;
      case 7:
        return _userType != null;
      case 8:
        return true;
      default:
        return false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  Future<void> _goNext() async {
    switch (_page) {
      case 0:
        _data.email = _emailCtrl.text.trim();
        _advance();
      case 1:
        _data.firstName = _firstCtrl.text.trim();
        _data.lastName = _lastCtrl.text.trim();
        _advance();
      case 2:
        _data.birthDate = _birthDate;
        _advance();
      case 3:
        _data.gender = _gender;
        _advance();
      case 4:
        _data.password = _passCtrl.text;
        _advance();
      case 5:
        _data.phone = _phoneCtrl.text.replaceAll(' ', '');
        _sendOtp();
        _advance();
      case 6:
        // Simulated OTP verification
        setState(() => _isSubmitting = true);
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _advance();
      case 7:
        _data.userType = _userType;
        if (_userType == UserType.freelancer) {
          _advance();
        } else {
          await _submit();
        }
      case 8:
        _data.photo = _photo;
        await _submit();
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

  void _sendOtp() {
    setState(() => _otpSending = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _otpSending = false);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final error = await context.read<AuthProvider>().register(_data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootNav()),
        (_) => false,
      );
    } else {
      showAppSnackBar(context, error, type: SnackBarType.error);
    }
  }

  // ── Auto-advance: Gender ──────────────────────────────────────────────────
  void _onGenderSelected(Gender g) {
    setState(() => _gender = g);
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted && _page == 3) { _data.gender = g; _advance(); }
    });
  }

  // ── Auto-advance: UserType ────────────────────────────────────────────────
  void _onUserTypeSelected(UserType t) {
    setState(() => _userType = t);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _page != 7) return;
      _data.userType = t;
      if (t == UserType.freelancer) {
        _advance();
      } else {
        _submit();
      }
    });
  }

  // ── OTP auto-verify when 6 digits entered ─────────────────────────────────
  void _onOtpComplete() {
    Future.microtask(_goNext);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    const textSteps = {0, 1, 2, 4, 5};
    final kbOnTextStep = kbOpen && textSteps.contains(_page);
    final showKbBar = kbOnTextStep && _canAdvance();

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
                  stepLabel: const [
                    'Adresse e-mail',
                    'Prénom & Nom',
                    'Date de naissance',
                    'Genre',
                    'Mot de passe',
                    'Téléphone',
                    'Vérification',
                    'Votre rôle',
                    'Photo de profil',
                  ][_page],
                ),
                // ── PageView ──
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _EmailPage(ctrl: _emailCtrl, status: _emailStatus),
                      _NamePage(firstCtrl: _firstCtrl, lastCtrl: _lastCtrl),
                      _BirthdatePage(
                        onChanged: (d) => setState(() => _birthDate = d),
                      ),
                      _GenderPage(selected: _gender, onSelected: _onGenderSelected),
                      _PasswordPage(ctrl: _passCtrl),
                      _PhonePage(ctrl: _phoneCtrl, status: _phoneStatus),
                      _OtpPage(
                        phone: _phoneCtrl.text,
                        controllers: _otpCtrls,
                        focusNodes: _otpNodes,
                        isSending: _otpSending,
                        onResend: _sendOtp,
                        onComplete: _onOtpComplete,
                      ),
                      _UserTypePage(
                          selected: _userType, onSelected: _onUserTypeSelected),
                      _PhotoPage(
                        photo: _photo,
                        onPhotoChanged: (f) => setState(() => _photo = f),
                      ),
                    ],
                  ),
                ),
                // ── Bottom controls (hidden when keyboard is open on text steps) ──
                if (!kbOnTextStep) _buildBottom(),
              ],
            ),
          ),
          // ── Keyboard arrow bar ──
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
    // Page 8 — Photo: full-width submit
    if (_page == 8) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Créer mon compte',
              variant: ButtonVariant.black,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _goNext,
            ),
            AppGap.h10,
            AppButton(
              label: 'Passer cette étape',
              variant: ButtonVariant.ghost,
              onPressed: _isSubmitting ? null : () { _data.photo = null; _submit(); },
            ),
          ],
        ),
      );
    }

    // All other pages: circular arrow button
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          const Spacer(),
          _isSubmitting
              ? const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
              : AppArrowActionButton(
                  enabled: _canAdvance(),
                  onPressed: _goNext,
                ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppInsets.a20,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.textPrimary.withValues(alpha: 0.06)
              : context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDesign.radius16),
          border: Border.all(
            color: isSelected ? context.colors.textPrimary : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.textPrimary.withValues(alpha: 0.08)
                    : context.colors.background,
                borderRadius: BorderRadius.circular(AppDesign.radius14),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                  size: 26),
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppGap.h3,
                    Text(subtitle!, style: context.text.bodySmall),
                  ],
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.colors.textPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? context.colors.textPrimary
                      : context.colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _pageHeader(BuildContext context, String title, String subtitle) {
  return AppPageHeaderBlock(title: title, subtitle: subtitle);
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0 — Email
// ─────────────────────────────────────────────────────────────────────────────

class _EmailPage extends StatelessWidget {
  final TextEditingController ctrl;
  final _FieldCheckStatus status;
  const _EmailPage({required this.ctrl, required this.status});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Votre email', 'Pour vous connecter à votre compte'),
          AppGap.h36,
          AppTextField(
            label: 'Adresse email',
            hint: 'exemple@mail.com',
            prefixIcon: Icons.email_outlined,
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
          ),
          AppGap.h12,
          _FieldStatusRow(status: status, takenMessage: 'Cet email est déjà utilisé'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Nom & Prénom
// ─────────────────────────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  const _NamePage({required this.firstCtrl, required this.lastCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Comment vous appelez-vous ?',
              'Votre nom sera affiché sur votre profil'),
          AppGap.h36,
          AppTextField(
            label: 'Prénom',
            hint: 'Jean',
            prefixIcon: Icons.person_outline_rounded,
            controller: firstCtrl,
          ),
          AppGap.h20,
          AppTextField(
            label: 'Nom',
            hint: 'Dupont',
            prefixIcon: Icons.badge_outlined,
            controller: lastCtrl,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Date de naissance (texte JJ/MM/AAAA)
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdatePage extends StatefulWidget {
  final ValueChanged<DateTime?> onChanged;
  const _BirthdatePage({required this.onChanged});

  @override
  State<_BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<_BirthdatePage> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = _ctrl.text;
    if (text.length < 10) {
      if (_error != null) setState(() => _error = null);
      widget.onChanged(null);
      return;
    }
    final parts = text.split('/');
    if (parts.length != 3) return;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null ||
        day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
      setState(() => _error = 'Date invalide');
      widget.onChanged(null);
      return;
    }
    try {
      final date = DateTime(year, month, day);
      if (date.month != month || date.day != day) {
        setState(() => _error = 'Date invalide');
        widget.onChanged(null);
        return;
      }
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) age--;
      if (age < 18) {
        setState(() => _error = 'Vous devez avoir au moins 18 ans');
        widget.onChanged(null);
        return;
      }
      setState(() => _error = null);
      widget.onChanged(date);
    } catch (_) {
      setState(() => _error = 'Date invalide');
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Date de naissance', 'Vous devez avoir au moins 18 ans'),
          AppGap.h40,
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            style: context.text.displaySmall?.copyWith(
              fontSize: AppFontSize.h1Lg,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
            inputFormatters: [_DateInputFormatter()],
            decoration: InputDecoration(
              hintText: 'JJ / MM / AAAA',
              hintStyle: context.text.displaySmall?.copyWith(
                fontSize: AppFontSize.h1Lg,
                fontWeight: FontWeight.w400,
                color: context.colors.textTertiary,
                letterSpacing: 3,
              ),
              errorText: _error,
              filled: true,
              fillColor: context.colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius16),
                borderSide: BorderSide(color: context.colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius16),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius16),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius16),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 3 — Genre (auto-advance)
// ─────────────────────────────────────────────────────────────────────────────

class _GenderPage extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender> onSelected;
  const _GenderPage({required this.selected, required this.onSelected});

  IconData _icon(Gender g) {
    switch (g) {
      case Gender.homme: return Icons.person_rounded;
      case Gender.femme: return Icons.face_3_rounded;
      case Gender.autre: return Icons.people_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Votre genre', 'Cette information reste privée'),
          AppGap.h36,
          ...Gender.values.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SelectableCard(
                icon: _icon(g),
                label: g.label,
                isSelected: selected == g,
                onTap: () => onSelected(g),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 4 — Mot de passe (champ unique, toggle intégré)
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordPage extends StatelessWidget {
  final TextEditingController ctrl;
  const _PasswordPage({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Créez un mot de passe',
              'Au moins 8 caractères pour sécuriser votre compte'),
          AppGap.h36,
          AppTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: ctrl,
            obscureText: true,
          ),
          AppGap.h16,
          // Strength indicator
          _StrengthBar(password: ctrl.text),
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final String password;
  const _StrengthBar({required this.password});

  int get _strength {
    if (password.length < 4) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  Color get _color {
    switch (_strength) {
      case 1: return AppColors.error;
      case 2: return AppColors.warning;
      case 3: return Colors.orange;
      default: return AppColors.primary;
    }
  }

  String get _label {
    switch (_strength) {
      case 0: return '';
      case 1: return 'Faible';
      case 2: return 'Moyen';
      case 3: return 'Fort';
      default: return 'Très fort';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _strength ? _color : context.colors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.micro),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_label.isNotEmpty) ...[
          AppGap.h6,
          Text(_label,
              style: context.text.labelMedium?.copyWith(color: _color)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 5 — Numéro de téléphone
// ─────────────────────────────────────────────────────────────────────────────

class _PhonePage extends StatelessWidget {
  final TextEditingController ctrl;
  final _FieldCheckStatus status;
  const _PhonePage({required this.ctrl, required this.status});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
              context, 'Votre numéro de téléphone', 'Pour être contacté par les clients'),
          AppGap.h36,
          _PhoneField(ctrl: ctrl),
          AppGap.h12,
          _FieldStatusRow(status: status, takenMessage: 'Ce numéro est déjà utilisé'),
        ],
      ),
    );
  }
}

class _PhoneField extends StatefulWidget {
  final TextEditingController ctrl;
  const _PhoneField({required this.ctrl});

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Téléphone',
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isFocused ? AppColors.primary : context.colors.textPrimary,
          ),
        ),
        AppGap.h8,
        TextFormField(
          controller: widget.ctrl,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [_FrenchPhoneFormatter()],
          style: context.text.titleMedium,
          decoration: InputDecoration(
            hintText: '06 12 34 56 78',
            hintStyle: context.text.bodyLarge?.copyWith(color: context.colors.textHint),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              margin: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇫🇷', style: context.text.headlineMedium),
                  AppGap.w6,
                  Text('+33',
                      style: context.text.titleSmall?.copyWith(
                          color: isFocused ? AppColors.primary : context.colors.textSecondary)),
                ],
              ),
            ),
            filled: true,
            fillColor: isFocused ? context.colors.surface : context.colors.surfaceAlt,
            contentPadding: AppInsets.a16,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius12),
              borderSide: BorderSide(color: context.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius12),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formateur téléphone français : XX XX XX XX XX (10 chiffres, groupes de 2)
// ─────────────────────────────────────────────────────────────────────────────

class _FrenchPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue value) {
    final digits = value.text.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % 2 == 0) buf.write(' ');
      buf.write(capped[i]);
    }
    final result = buf.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget indicateur de statut (idle / checking / available / taken)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldStatusRow extends StatelessWidget {
  final _FieldCheckStatus status;
  final String takenMessage;
  const _FieldStatusRow({required this.status, required this.takenMessage});

  @override
  Widget build(BuildContext context) {
    if (status == _FieldCheckStatus.idle) return const SizedBox.shrink();
    final isChecking = status == _FieldCheckStatus.checking;
    final isAvailable = status == _FieldCheckStatus.available;
    final color = isChecking
        ? context.colors.textTertiary
        : isAvailable
            ? AppColors.teal
            : AppColors.error;
    final icon = isChecking
        ? null
        : isAvailable
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;
    final label = isChecking
        ? 'Vérification…'
        : isAvailable
            ? 'Disponible'
            : takenMessage;

    return Row(
      children: [
        if (isChecking)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Icon(icon, size: 16, color: color),
        AppGap.w6,
        Text(label, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 6 — OTP 4 chiffres (inline, controllers gérés par le parent)
// ─────────────────────────────────────────────────────────────────────────────

class _OtpPage extends StatefulWidget {
  final String phone;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isSending;
  final VoidCallback onResend;
  final VoidCallback onComplete;

  const _OtpPage({
    required this.phone,
    required this.controllers,
    required this.focusNodes,
    required this.isSending,
    required this.onResend,
    required this.onComplete,
  });

  @override
  State<_OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<_OtpPage>
    with OtpTimerMixin<_OtpPage> {

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void _onResend() {
    for (final c in widget.controllers) c.clear();
    startResendTimer();
    widget.onResend();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppDesign.radius16),
            ),
            child: const Icon(Icons.sms_rounded, color: AppColors.primary, size: 28),
          ),
          AppGap.h24,
          Text('Code de vérification',
              style: context.text.displayMedium),
          AppGap.h8,
          Text(
            widget.isSending
                ? 'Envoi en cours…'
                : 'Code envoyé par SMS au\n${maskPhone(widget.phone)}',
            style: context.text.bodyLarge?.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 44),

          OtpInputRow(
            controllers: widget.controllers,
            focusNodes: widget.focusNodes,
            onComplete: widget.onComplete,
          ),

          AppGap.h36,

          // ── Resend ──
          Center(
            child: canResend
                ? GestureDetector(
                    onTap: _onResend,
                    child: Container(
                      padding: AppInsets.h20v12,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDesign.radius12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                          AppGap.w8,
                          Text('Renvoyer le code',
                              style: context.text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Center(
                          child: Text(
                            '${resendTimer}s',
                            style: context.text.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      AppGap.w10,
                      Text('Renvoyer le code dans ${resendTimer}s',
                          style: context.text.bodyMedium),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 7 — Choisir rôle (auto-advance)
// ─────────────────────────────────────────────────────────────────────────────

class _UserTypePage extends StatelessWidget {
  final UserType? selected;
  final ValueChanged<UserType> onSelected;
  const _UserTypePage({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Qui êtes-vous ?', 'Choisissez votre type de compte'),
          AppGap.h36,
          ...UserType.values.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SelectableCard(
                icon: t == UserType.client
                    ? Icons.search_rounded
                    : Icons.handyman_outlined,
                label: t.label,
                subtitle: t.description,
                isSelected: selected == t,
                onTap: () => onSelected(t),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 8 — Photo de profil (freelancer uniquement)
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPage extends StatelessWidget {
  final File? photo;
  final ValueChanged<File?> onPhotoChanged;
  const _PhotoPage({required this.photo, required this.onPhotoChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context, 'Votre photo de profil',
              'Les profils avec photo reçoivent 5× plus de missions'),
          AppGap.h40,

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: photo != null
                      ? AppColors.primary.withValues(alpha:0.4)
                      : context.colors.border,
                  width: 2,
                ),
              ),
              padding: AppInsets.a8,
              child: PhotoPicker(
                photo: photo,
                size: 160,
                isCircle: true,
                onPhotoChanged: onPhotoChanged,
              ),
            ),
          ),
          AppGap.h12,
          Center(
            child: Text(
              photo != null ? 'Appuyez pour modifier' : 'Appuyez pour ajouter une photo',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
