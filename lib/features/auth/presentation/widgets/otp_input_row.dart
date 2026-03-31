import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';

// Widget OTP partagé — 4 cases numériques avec navigation focus automatique.
// [onComplete] est appelé dès que les 4 chiffres sont saisis.
// [onChanged] est appelé à chaque frappe (utile pour setState parent).
class OtpInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onComplete;
  final VoidCallback? onChanged;

  const OtpInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onComplete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) => _buildCell(context, i)),
    );
  }

  Widget _buildCell(BuildContext context, int i) {
    final filled = controllers[i].text.isNotEmpty;
    return SizedBox(
      width: 68,
      height: 76,
      child: TextField(
        controller: controllers[i],
        focusNode: focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: context.text.displayMedium?.copyWith(
          color: context.colors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: filled ? const Color(0xFFF5F6F7) : context.colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radius16),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radius16),
            borderSide: BorderSide(
              color: filled ? context.colors.textPrimary : context.colors.border,
              width: filled ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radius16),
            borderSide: BorderSide(color: context.colors.textPrimary, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 3) focusNodes[i + 1].requestFocus();
          if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
          onChanged?.call();
          final code = controllers.map((c) => c.text).join();
          if (code.length == 4) onComplete();
        },
      ),
    );
  }
}
