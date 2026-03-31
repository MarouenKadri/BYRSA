import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import '../../widgets/custom_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoogleOnboardingFlow — 4-step onboarding for Google Sign-In users
// Steps: Date de naissance → Genre → Téléphone → Type de compte
// ─────────────────────────────────────────────────────────────────────────────

class GoogleOnboardingFlow extends StatefulWidget {
  const GoogleOnboardingFlow({super.key});

  @override
  State<GoogleOnboardingFlow> createState() => _GoogleOnboardingFlowState();
}

class _GoogleOnboardingFlowState extends State<GoogleOnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // ── Data collected ─────────────────────────────────────────────────────────
  DateTime? _birthDate;
  Gender? _gender;
  final _phoneCtrl = TextEditingController();
  UserType? _userType;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

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

  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _birthDate != null;
      case 1:
        return _gender != null;
      case 2:
        return _phoneCtrl.text.trim().length >= 9;
      case 3:
        return _userType != null;
      default:
        return false;
    }
  }

  Future<void> _submit() async {
    if (_userType == null) return;
    setState(() => _isSubmitting = true);
    final error = await context.read<AuthProvider>().completeGoogleSetup(
          userType: _userType!,
          birthDate: _birthDate,
          gender: _gender,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    // Pages with text input where keyboard bar should appear
    const textSteps = {2};
    final kbOnTextStep = kbOpen && textSteps.contains(_page);
    final showKbBar = kbOnTextStep && _canAdvance();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _goBack,
                  ),
                  const Spacer(),
                  Text(
                    '${_page + 1} / 4',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_page + 1) / 4,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),

            // ── Pages ───────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  // Page 0 — Date de naissance
                  _BirthdateStep(
                    onChanged: (dt) => setState(() => _birthDate = dt),
                  ),
                  // Page 1 — Genre
                  _GenderStep(
                    selected: _gender,
                    onSelected: (g) {
                      setState(() => _gender = g);
                      Future.delayed(const Duration(milliseconds: 280), () {
                        if (mounted && _page == 1) _advance();
                      });
                    },
                  ),
                  // Page 2 — Téléphone
                  _PhoneStep(controller: _phoneCtrl),
                  // Page 3 — Type de compte
                  _UserTypeStep(
                    selected: _userType,
                    onSelected: (ut) {
                      setState(() => _userType = ut);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted && _page == 3) _submit();
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom controls ─────────────────────────────────────────────
            if (showKbBar)
              _KbBar(enabled: _canAdvance(), onTap: _advance)
            else if (!kbOpen)
              _BottomBar(
                page: _page,
                canAdvance: _canAdvance(),
                isSubmitting: _isSubmitting,
                onNext: _page == 3 ? _submit : _advance,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Keyboard arrow bar ───────────────────────────────────────────────────────

class _KbBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _KbBar({required this.enabled, required this.onTap});

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
          Opacity(
            opacity: enabled ? 1.0 : 0.35,
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

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int page;
  final bool canAdvance;
  final bool isSubmitting;
  final VoidCallback onNext;

  const _BottomBar({
    required this.page,
    required this.canAdvance,
    required this.isSubmitting,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canAdvance && !isSubmitting ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.divider,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isLast ? 'Terminer' : 'Continuer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Date de naissance
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdateStep extends StatefulWidget {
  final ValueChanged<DateTime?> onChanged;
  const _BirthdateStep({required this.onChanged});

  @override
  State<_BirthdateStep> createState() => _BirthdateStepState();
}

class _BirthdateStepState extends State<_BirthdateStep> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll('/', '').replaceAll(' ', '');
    if (digits.length < 8) {
      _error = null;
      widget.onChanged(null);
      setState(() {});
      return;
    }
    try {
      final day = int.parse(digits.substring(0, 2));
      final month = int.parse(digits.substring(2, 4));
      final year = int.parse(digits.substring(4, 8));
      final dt = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - dt.year - ((now.month < dt.month || (now.month == dt.month && now.day < dt.day)) ? 1 : 0);
      if (dt.day != day || dt.month != month) {
        _error = 'Date invalide';
        widget.onChanged(null);
      } else if (age < 18) {
        _error = 'Vous devez avoir 18 ans minimum';
        widget.onChanged(null);
      } else if (year < 1900) {
        _error = 'Année invalide';
        widget.onChanged(null);
      } else {
        _error = null;
        widget.onChanged(dt);
      }
    } catch (_) {
      _error = 'Date invalide';
      widget.onChanged(null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre date\nde naissance',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nous vérifierons que vous avez bien 18 ans',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _ctrl,
            onChanged: _onChanged,
            inputFormatters: [_DateInputFormatter()],
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'JJ / MM / AAAA',
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                color: AppColors.textTertiary.withOpacity(0.5),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
    TextEditingValue old,
    TextEditingValue value,
  ) {
    final digits = value.text.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) buf.write(' / ');
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
// Step 1 — Genre
// ─────────────────────────────────────────────────────────────────────────────

class _GenderStep extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender> onSelected;

  const _GenderStep({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre genre',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cette information reste confidentielle',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          for (final g in Gender.values) ...[
            _SelectableCard(
              icon: g == Gender.homme
                  ? Icons.man_rounded
                  : g == Gender.femme
                      ? Icons.woman_rounded
                      : Icons.people_rounded,
              label: g.label,
              selected: selected == g,
              onTap: () => onSelected(g),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Téléphone
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre numéro\nde téléphone',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour être contacté par les clients',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'Téléphone',
            hint: '06 00 00 00 00',
            prefixIcon: Icons.phone_rounded,
            controller: controller,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre numéro ne sera jamais partagé publiquement',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Type de compte
// ─────────────────────────────────────────────────────────────────────────────

class _UserTypeStep extends StatelessWidget {
  final UserType? selected;
  final ValueChanged<UserType> onSelected;

  const _UserTypeStep({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vous êtes…',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez votre profil pour continuer',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          _SelectableCard(
            icon: Icons.search_rounded,
            label: 'Client',
            subtitle: 'Je cherche un prestataire',
            selected: selected == UserType.client,
            onTap: () => onSelected(UserType.client),
          ),
          const SizedBox(height: 12),
          _SelectableCard(
            icon: Icons.work_rounded,
            label: 'Prestataire',
            subtitle: 'Je propose mes services',
            selected: selected == UserType.freelancer,
            onTap: () => onSelected(UserType.freelancer),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.warning.withOpacity(0.8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vous pourrez changer de mode client/prestataire dans les paramètres',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.warning.withOpacity(0.9),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared — Selectable card
// ─────────────────────────────────────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
