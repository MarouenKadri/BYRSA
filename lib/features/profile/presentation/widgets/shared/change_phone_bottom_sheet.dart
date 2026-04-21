import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../profile/profile_provider.dart';
import 'user_common_widgets.dart';

/// Affiche le bottom sheet de changement de numéro de téléphone.
void showChangePhoneBottomSheet(BuildContext context, {String currentPhone = ''}) {
  showAppBottomSheet(
    context: context,
    isScrollControlled: true,
    wrapWithSurface: false,
    child: _ChangePhoneSheet(currentPhone: currentPhone),
  );
}

class _ChangePhoneSheet extends StatefulWidget {
  final String currentPhone;
  const _ChangePhoneSheet({this.currentPhone = ''});

  @override
  State<_ChangePhoneSheet> createState() => _ChangePhoneSheetState();
}

class _ChangePhoneSheetState extends State<_ChangePhoneSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: AppFormSheet(
          title: "Numéro de téléphone",
          footer: Column(
            children: [
              ProfileSheetPrimaryAction(
                onPressed: _submit,
                label: "Enregistrer",
              ),
              AppGap.h12,
              Center(
                child: ProfileSheetSecondaryAction(
                  label: "Annuler",
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShadowField(
                child: _ReadOnlyField(
                  label: "Numéro actuel",
                  value: widget.currentPhone.isNotEmpty
                      ? widget.currentPhone
                      : "+33 6 •• •• •• ••",
                ),
              ),
              AppGap.h16,
              _ShadowField(
                child: _PhoneField(
                  controller: _newCtrl,
                  label: "Nouveau numéro",
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Champ requis";
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 8 || digits.length > 15) {
                      return "Numéro de téléphone invalide";
                    }
                    if (v == widget.currentPhone) {
                      return "Doit être différent du numéro actuel";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;
    final updated = current.copyWith(phone: _newCtrl.text.trim());
    final err = await profileProvider.updateProfile(updated);
    if (!mounted) return;
    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
    } else {
      Navigator.pop(context);
      showAppSnackBar(context, 'Numéro de téléphone mis à jour', type: SnackBarType.success);
    }
  }
}

// ─── Wrapper ombre ambiante douce ─────────────────────────────────────────────

class _ShadowField extends StatelessWidget {
  final Widget child;
  const _ShadowField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Champ lecture seule ──────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textTertiary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        readOnly: true,
        prefixIcon: Icon(Icons.phone_outlined, size: 16, color: context.colors.textHint),
      ),
    );
  }
}

// ─── Champ téléphone ──────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _PhoneField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
      validator: validator,
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: label,
        prefixIcon: Icon(Icons.phone_outlined, size: 16, color: context.colors.textHint),
      ).copyWith(
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}

