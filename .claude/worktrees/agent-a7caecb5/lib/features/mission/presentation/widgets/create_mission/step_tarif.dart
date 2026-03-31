import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/design_tokens.dart';
import '../../../data/models/create_mission_models.dart';

/// ─────────────────────────────────────────────────────────────
/// 💰 Step 7 — Tarif
/// ─────────────────────────────────────────────────────────────
class StepTarif extends StatefulWidget {
  final String budgetType;
  final double hourlyRate;
  final double estimatedHours;
  final double fixedBudget;
  final Function(double) onHourlyRateChanged;
  final Function(double) onEstimatedHoursChanged;
  final Function(double) onFixedBudgetChanged;

  const StepTarif({
    super.key,
    required this.budgetType,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.fixedBudget,
    required this.onHourlyRateChanged,
    required this.onEstimatedHoursChanged,
    required this.onFixedBudgetChanged,
  });

  @override
  State<StepTarif> createState() => _StepTarifState();
}

class _StepTarifState extends State<StepTarif> {
  late TextEditingController _rateCtrl;
  late TextEditingController _fixedCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController(
      text: widget.hourlyRate > 0 ? widget.hourlyRate.round().toString() : '',
    );
    _fixedCtrl = TextEditingController(
      text: widget.fixedBudget > 0 ? widget.fixedBudget.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _fixedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.budgetType == CreateBudgetType.fixed
        ? _buildFixed()
        : _buildHourly();
  }

  // ── Tarif horaire ─────────────────────────────────────────
  Widget _buildHourly() {
    const quickRates = [15, 20, 25, 30, 40, 50, 65, 80];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quel tarif horaire ?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous pouvez saisir ou choisir un montant',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          // Saisie
          _AmountInput(
            controller: _rateCtrl,
            suffix: '€ / h',
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) widget.onHourlyRateChanged(val);
            },
          ),

          const SizedBox(height: 20),

          // Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickRates.map((rate) {
              final selected = widget.hourlyRate.round() == rate;
              return _RateChip(
                label: '$rate €/h',
                selected: selected,
                onTap: () {
                  widget.onHourlyRateChanged(rate.toDouble());
                  _rateCtrl.text = rate.toString();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 36),

          // Durée
          Text(
            'DURÉE ESTIMÉE',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterBtn(
                icon: Icons.remove,
                onTap: () {
                  if (widget.estimatedHours > 1) {
                    widget.onEstimatedHoursChanged(widget.estimatedHours - 0.5);
                  }
                },
              ),
              const SizedBox(width: 28),
              Text(
                '${widget.estimatedHours.toStringAsFixed(widget.estimatedHours == widget.estimatedHours.truncateToDouble() ? 0 : 1)} h',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 28),
              _CounterBtn(
                icon: Icons.add,
                onTap: () {
                  if (widget.estimatedHours < 12) {
                    widget.onEstimatedHoursChanged(widget.estimatedHours + 0.5);
                  }
                },
              ),
            ],
          ),

          // Total
          if (widget.hourlyRate > 0) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total estimé',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textSecondary)),
                  Text(
                    '${(widget.hourlyRate * widget.estimatedHours).round()} €',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Budget fixe ───────────────────────────────────────────
  Widget _buildFixed() {
    const quickAmounts = [50, 100, 150, 200, 300, 500];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quel est votre budget ?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous pouvez saisir ou choisir un montant',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          _AmountInput(
            controller: _fixedCtrl,
            suffix: '€',
            onChanged: (v) {
              widget.onFixedBudgetChanged(double.tryParse(v) ?? 0);
            },
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAmounts.map((amount) {
              final selected = widget.fixedBudget.round() == amount;
              return _RateChip(
                label: '$amount €',
                selected: selected,
                onTap: () {
                  widget.onFixedBudgetChanged(amount.toDouble());
                  _fixedCtrl.text = amount.toString();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  final Function(String) onChanged;

  const _AmountInput({
    required this.controller,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(
            color: AppColors.border,
            fontSize: 32,
            fontWeight: FontWeight.w800),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(20, 18, 0, 18),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            suffix,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _RateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}
