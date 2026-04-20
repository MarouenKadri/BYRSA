import 'package:flutter/material.dart';

import '../app_design_system.dart';
import 'app_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppEmailField — hérite de AppBaseField.
// Keyboard email, autocorrect désactivé, icône mail intégrée.
// ─────────────────────────────────────────────────────────────────────────────

class AppEmailField extends AppBaseField {
  final String? hint;
  final TextInputAction? textInputAction;

  const AppEmailField({
    super.key,
    required super.label,
    super.controller,
    super.validator,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    this.hint,
    this.textInputAction,
  });

  @override
  State<AppEmailField> createState() => _AppEmailFieldState();
}

class _AppEmailFieldState extends AppBaseFieldState<AppEmailField> {
  @override
  Widget buildInput(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: fieldFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      style: context.text.titleMedium,
      decoration: AppInputDecorations.formField(
        context,
        hintText: widget.hint ?? 'exemple@mail.com',
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          color: context.colors.textSecondary,
          size: 22,
        ),
        fillColor: isFocused ? context.colors.surface : context.colors.surfaceAlt,
      ),
    );
  }
}
