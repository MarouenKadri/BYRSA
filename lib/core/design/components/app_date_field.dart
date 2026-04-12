import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_design_system.dart';
import '../app_primitives.dart';
import 'app_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DateInputFormatter — centralisé ici, était dupliqué dans register_flow
// et google_onboarding_flow. Format : JJ/MM/AAAA
// ─────────────────────────────────────────────────────────────────────────────

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
// AppDateField — hérite de AppBaseField.
// Gère le formatage JJ/MM/AAAA et affiche le message d'erreur.
// ─────────────────────────────────────────────────────────────────────────────

class AppDateField extends AppBaseField {
  /// Message d'erreur affiché sous le champ (ex: "Vous devez avoir 18 ans").
  final String? errorText;

  const AppDateField({
    super.key,
    required super.label,
    super.controller,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    this.errorText,
  });

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends AppBaseFieldState<AppDateField> {
  @override
  Widget buildInput(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: fieldFocusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [DateInputFormatter()],
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      style: context.text.displaySmall?.copyWith(
        fontSize: AppFontSize.h1Lg,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
      ),
      decoration: AppInputDecorations.formField(
        context,
        hintText: 'JJ / MM / AAAA',
        hintStyle: context.text.displaySmall?.copyWith(
          fontSize: AppFontSize.h1Lg,
          fontWeight: FontWeight.w400,
          color: context.colors.textTertiary,
          letterSpacing: 3,
        ),
        errorText: widget.errorText,
        fillColor: context.colors.background,
      ),
    );
  }
}
