import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/navigation/root_nav.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/photo_picker.dart';

enum _FieldCheckStatus { idle, checking, available, taken }

// ─────────────────────────────────────────────────────────────────────────────
// RegisterFlow — 9-step BlaBlaCar-style PageView registration
// Steps: Email → Nom → Date → Genre → Mot de passe → Téléphone → OTP → Rôle → Photo
// ─────────────────────────────────────────────────────────────────────────────

class RegisterFlow extends StatefulWidget {
  const RegisterFlow({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                // ── Progress bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _ProgressBar(current: _page, total: _totalSteps),
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
              child: _KeyboardBar(enabled: _canAdvance(), onTap: _goNext),
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Créer mon compte',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isSubmitting ? null : () { _data.photo = null; _submit(); },
              child: Text(
                'Passer cette étape',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
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
              : _ArrowButton(enabled: _canAdvance(), onPressed: _goNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI
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
        width: 60,
        height: 60,
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
                width: 52,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
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
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(subtitle,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
    ],
  );
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.verifiedBg : AppColors.chipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
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
          _pageHeader('Votre email', 'Pour vous connecter à votre compte'),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'Adresse email',
            hint: 'exemple@mail.com',
            prefixIcon: Icons.email_outlined,
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
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
          _pageHeader('Comment vous appelez-vous ?',
              'Votre nom sera affiché sur votre profil'),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'Prénom',
            hint: 'Jean',
            prefixIcon: Icons.person_outline_rounded,
            controller: firstCtrl,
          ),
          const SizedBox(height: 20),
          CustomTextField(
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
          _pageHeader('Date de naissance', 'Vous devez avoir au moins 18 ans'),
          const SizedBox(height: 40),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 3,
            ),
            inputFormatters: [_DateInputFormatter()],
            decoration: InputDecoration(
              hintText: 'JJ / MM / AAAA',
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
                letterSpacing: 3,
              ),
              errorText: _error,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
          _pageHeader('Votre genre', 'Cette information reste privée'),
          const SizedBox(height: 36),
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
          _pageHeader('Créez un mot de passe',
              'Au moins 8 caractères pour sécuriser votre compte'),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: ctrl,
            obscureText: true,
          ),
          const SizedBox(height: 16),
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
                    color: i < _strength ? _color : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(_label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _color)),
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
              'Votre numéro de téléphone', 'Pour être contacté par les clients'),
          const SizedBox(height: 36),
          _PhoneField(ctrl: ctrl),
          const SizedBox(height: 12),
          _FieldStatusRow(status: status, takenMessage: 'Ce numéro est déjà utilisé'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre numéro ne sera jamais partagé publiquement',
                    style: TextStyle(fontSize: 13, color: AppColors.primary.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFocused ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.ctrl,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [_FrenchPhoneFormatter()],
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '06 12 34 56 78',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              margin: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇫🇷', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('+33',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isFocused ? AppColors.primary : AppColors.textSecondary)),
                ],
              ),
            ),
            filled: true,
            fillColor: isFocused ? Colors.white : AppColors.chipBg,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
        ? AppColors.textTertiary
        : isAvailable
            ? const Color(0xFF00C896)
            : const Color(0xFFE53935);
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
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
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

class _OtpPageState extends State<_OtpPage> {
  int _timer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_timer > 0) { _timer--; } else { _canResend = true; }
      });
      return _timer > 0;
    });
  }

  void _onResend() {
    setState(() { _timer = 60; _canResend = false; });
    for (final c in widget.controllers) c.clear();
    _startTimer();
    widget.onResend();
  }

  String _masked(String phone) {
    final d = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (d.length < 4) return phone;
    return '+33 ••• ••• ${d.substring(d.length - 2)}';
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.sms_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 24),
          const Text('Code de vérification',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            widget.isSending
                ? 'Envoi en cours…'
                : 'Code envoyé par SMS au\n${_masked(widget.phone)}',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 44),

          // ── 4 large OTP boxes ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final isLast = i == 3;
              return Row(
                children: [
                  _buildBox(i),
                  if (!isLast) const SizedBox(width: 16),
                ],
              );
            }),
          ),

          const SizedBox(height: 36),

          // ── Resend ──
          Center(
            child: _canResend
                ? GestureDetector(
                    onTap: _onResend,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Renvoyer le code',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
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
                          color: AppColors.chipBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            '${_timer}s',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Renvoyer le code dans ${_timer}s',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int i) {
    final filled = widget.controllers[i].text.isNotEmpty;
    return SizedBox(
      width: 64,
      height: 72,
      child: TextField(
        controller: widget.controllers[i],
        focusNode: widget.focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: filled ? AppColors.primary : AppColors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: filled ? AppColors.verifiedBg : AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: filled ? AppColors.primary : AppColors.border,
              width: filled ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 3) widget.focusNodes[i + 1].requestFocus();
          if (v.isEmpty && i > 0) widget.focusNodes[i - 1].requestFocus();
          final code = widget.controllers.map((c) => c.text).join();
          if (code.length == 4) widget.onComplete();
        },
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
          _pageHeader('Qui êtes-vous ?', 'Choisissez votre type de compte'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous pouvez basculer entre les deux rôles à tout moment',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          _pageHeader('Votre photo de profil',
              'Les profils avec photo reçoivent 5× plus de missions'),
          const SizedBox(height: 40),

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: photo != null
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.border,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: PhotoPicker(
                photo: photo,
                size: 160,
                isCircle: true,
                onPhotoChanged: onPhotoChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  photo != null
                      ? Icons.check_circle_rounded
                      : Icons.touch_app_rounded,
                  size: 15,
                  color: photo != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  photo != null
                      ? 'Appuyez pour modifier'
                      : 'Appuyez pour ajouter une photo',
                  style: TextStyle(
                    fontSize: 13,
                    color: photo != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: photo != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conseils',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _tip(Icons.face_rounded, 'Visage bien visible et centré'),
                const SizedBox(height: 8),
                _tip(Icons.wb_sunny_outlined, 'Bonne luminosité'),
                const SizedBox(height: 8),
                _tip(Icons.verified_rounded, 'Photo récente et professionnelle'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
