import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_radius.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppInputDecorations & AppTextField
// ─────────────────────────────────────────────────────────────────────────────

class AppInputDecorations {
  const AppInputDecorations._();

  static InputDecoration formField(
    BuildContext context, {
    String? hintText,
    TextStyle? hintStyle,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? suffixIcon,
    Color? fillColor,
    EdgeInsetsGeometry contentPadding = AppInsets.a16,
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(AppRadius.card),
    ),
    Color? focusedColor,
    bool noBorder = false,
  }) {
    final divider = context.colors.border;
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ??
          context.text.bodyMedium?.copyWith(
            color: context.colors.textHint,
            fontSize: AppFontSize.body,
          ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? context.colors.surfaceAlt,
      counterText: '',
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: noBorder ? BorderSide.none : BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: noBorder ? BorderSide.none : BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: focusedColor ?? AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  static InputDecoration searchField(
    BuildContext context, {
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(AppRadius.button),
    ),
  }) {
    final divider = context.colors.divider;
    return InputDecoration(
      hintText: hintText,
      hintStyle: context.appBarSearchHintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? context.colors.surface,
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextField — champ de saisie centralisé avec label + focus + password
// ─────────────────────────────────────────────────────────────────────────────

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  bool get _isFocused => _focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.text.bodyMedium?.copyWith(
            fontSize: AppFontSize.base,
            fontWeight: FontWeight.w600,
            color: _isFocused ? AppColors.primary : context.colors.textPrimary,
          ),
        ),
        AppGap.h8,
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: context.text.titleSmall?.copyWith(
            fontSize: AppFontSize.lg,
            color: context.colors.textPrimary,
          ),
          decoration: AppInputDecorations.formField(
            context,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.primary
                        : context.colors.textSecondary,
                    size: 22,
                  )
                : null,
            suffixIcon: widget.suffixIcon ??
                (widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: context.colors.textSecondary,
                          size: 22,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      )
                    : null),
            fillColor:
                _isFocused ? context.colors.surface : context.colors.surfaceAlt,
          ),
        ),
      ],
    );
  }
}
