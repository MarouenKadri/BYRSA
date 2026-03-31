import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../data/models/registration_data.dart';
import '../../widgets/primary_button.dart';
import 'verification_method_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final RegistrationData data;
  final VerificationMethod method;
  final Widget? nextPage;
  final VoidCallback? onVerified;

  const OtpVerificationPage({
    super.key,
    required this.data,
    required this.method,
    this.nextPage,
    this.onVerified,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
        }
      });
      return _resendTimer > 0;
    });
  }

  bool get _isSms => widget.method == VerificationMethod.sms;

  String get _maskedDestination {
    if (_isSms) {
      final phone = widget.data.phone ?? '';
      if (phone.length < 4) return phone;
      return '+33 ${phone.substring(0, 2)} •• •• •• ${phone.substring(phone.length - 2)}';
    } else {
      final email = widget.data.email ?? '';
      if (!email.contains('@')) return email;
      final parts = email.split('@');
      final name = parts[0];
      final domain = parts[1];
      if (name.length <= 2) return email;
      return '${name.substring(0, 2)}${'•' * (name.length - 2)}@$domain';
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrez le code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code envoyé ${_isSms ? 'par SMS au' : 'par email à'}\n$_maskedDestination',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) => _buildOtpField(i)),
              ),
              const SizedBox(height: 32),

              Center(
                child: _canResend
                    ? TextButton.icon(
                        onPressed: _handleResend,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Renvoyer dans ${_resendTimer}s',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              const Spacer(),

              PrimaryButton(
                label: 'Vérifier',
                isLoading: _isLoading,
                isEnabled: _otpCode.length == 4,
                onPressed: _otpCode.length == 4 ? _handleVerify : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    final filled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 68,
      height: 76,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: filled ? AppColors.primary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
          setState(() {});
          if (_otpCode.length == 4) _handleVerify();
        },
      ),
    );
  }

  void _handleResend() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
      for (var c in _controllers) c.clear();
    });
    _startResendTimer();
    _focusNodes[0].requestFocus();

  }

  Future<void> _handleVerify() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (widget.onVerified != null) {
      Navigator.pop(context); // pop OTP page → back to VerificationMethodPage
      widget.onVerified!();   // callback pops VerificationMethodPage + advances flow
    } else {
      final destination = widget.nextPage ?? _SuccessPage(data: widget.data);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    }
  }
}

class _SuccessPage extends StatelessWidget {
  final RegistrationData data;

  const _SuccessPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.verifiedBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 70,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Bienvenue ${data.firstName} !',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              const Text(
                'Votre compte a été créé avec succès.\nVous pouvez maintenant utiliser Inkern.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              PrimaryButton(
                label: 'Commencer',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
