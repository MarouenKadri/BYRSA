import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design/app_design_system.dart';

/// ─────────────────────────────────────────────────────────────
/// 💰 Step 5: Budget
/// ─────────────────────────────────────────────────────────────
class StepBudget extends StatefulWidget {
  final String budgetType;
  final double hourlyRate;
  final double estimatedHours;
  final double fixedBudget;
  final Function(String) onBudgetTypeChanged;
  final Function(double) onHourlyRateChanged;
  final Function(double) onEstimatedHoursChanged;
  final Function(double) onFixedBudgetChanged;
  final VoidCallback onCompleted;

  const StepBudget({
    super.key,
    required this.budgetType,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.fixedBudget,
    required this.onBudgetTypeChanged,
    required this.onHourlyRateChanged,
    required this.onEstimatedHoursChanged,
    required this.onFixedBudgetChanged,
    required this.onCompleted,
  });

  @override
  State<StepBudget> createState() => _StepBudgetState();
}

class _StepBudgetState extends State<StepBudget> {
  late TextEditingController _hourlyCtrl;

  @override
  void initState() {
    super.initState();
    _hourlyCtrl = TextEditingController(
      text: widget.hourlyRate > 0 ? widget.hourlyRate.round().toString() : '',
    );
  }

  @override
  void didUpdateWidget(StepBudget old) {
    super.didUpdateWidget(old);
    // Sync si le parent change la valeur (ex. tap sur un chip)
    final newVal = widget.hourlyRate.round().toString();
    if (_hourlyCtrl.text != newVal) {
      _hourlyCtrl.text = newVal;
      _hourlyCtrl.selection = TextSelection.collapsed(offset: newVal.length);
    }
  }

  @override
  void dispose() {
    _hourlyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppInsets.a20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quel est votre budget ?',
            style: context.text.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppGap.h8,
          Text(
            'Choisissez comment vous souhaitez payer',
            style: context.text.bodyMedium,
          ),

          AppGap.h28,

          BudgetTypeCard(
            icon: Icons.schedule_rounded,
            title: 'Paiement à l\'heure',
            subtitle: 'Payez selon le temps passé',
            isSelected: widget.budgetType == 'hourly',
            onTap: () => widget.onBudgetTypeChanged('hourly'),
          ),
          AppGap.h12,
          BudgetTypeCard(
            icon: Icons.payments_rounded,
            title: 'Budget fixe',
            subtitle: 'Définissez un montant total',
            isSelected: widget.budgetType == 'fixed',
            onTap: () => widget.onBudgetTypeChanged('fixed'),
          ),

          AppGap.h28,

          if (widget.budgetType == 'hourly') _buildHourlyBudget(),
          if (widget.budgetType == 'fixed') _buildFixedBudget(),
        ],
      ),
    );
  }

  double get _total => widget.budgetType == 'hourly'
      ? widget.hourlyRate * widget.estimatedHours
      : widget.fixedBudget;

  Widget _buildCommissionPreview(double total) {
    if (total <= 0) return const SizedBox.shrink();
    final presta = total * 0.9;
    final cigale = total * 0.1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppGap.h24,
        Text(
          'DÉTAIL DU PAIEMENT',
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        AppGap.h12,
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: context.colors.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppInsets.a8,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      AppGap.w10,
                      Text(
                        'Prestataire',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${presta.round()} €',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: AppInsets.v10,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: context.colors.divider)),
                    Padding(
                      padding: AppInsets.h10,
                      child: Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: context.colors.textHint,
                      ),
                    ),
                    Expanded(child: Divider(color: context.colors.divider)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppInsets.a8,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          size: 16,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      AppGap.w10,
                      Text(
                        'Commission Inkern (10%)',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${cigale.round()} €',
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppGap.h12,
              Container(
                padding: AppInsets.h12v8,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: AppColors.info),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        'Ce montant sera bloqué jusqu\'à validation de la mission',
                        style: context.text.labelMedium?.copyWith(
                          color: AppColors.secondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyBudget() {
    const quickRates = [15, 20, 25, 30, 40, 50, 65, 80];
    final currentRate = widget.hourlyRate.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Text(
          'TARIF HORAIRE',
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        AppGap.h12,

        // ── Champ de saisie ────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône gauche
              Container(
                margin: AppInsets.a10,
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // TextField
              Expanded(
                child: TextField(
                  controller: _hourlyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: context.text.displaySmall?.copyWith(
                    fontSize: AppFontSize.h1Lg,
                  ),
                  decoration: AppInputDecorations.formField(
                    context,
                    hintText: '0',
                    hintStyle: context.text.displaySmall?.copyWith(
                      fontSize: AppFontSize.h1Lg,
                      color: context.colors.border,
                    ),
                    contentPadding: AppInsets.v14,
                    noBorder: true,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    if (val != null) widget.onHourlyRateChanged(val);
                  },
                ),
              ),
              // Suffix €/h
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: AppInsets.h12v8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  '€ / h',
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppGap.h14,

        // ── Chips tarifs courants ──────────────────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickRates.map((rate) {
            final selected = currentRate == rate;
            return GestureDetector(
              onTap: () {
                widget.onHourlyRateChanged(rate.toDouble());
                Future.delayed(
                  const Duration(milliseconds: 300),
                  widget.onCompleted,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : context.colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : context.colors.divider,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '$rate €/h',
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        AppGap.h24,

        // ── Durée estimée ──────────────────────────────────────────────────
        Text(
          'DURÉE ESTIMÉE',
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        AppGap.h12,
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: context.colors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CounterButton(
                icon: Icons.remove,
                onTap: () {
                  if (widget.estimatedHours > 1)
                    widget.onEstimatedHoursChanged(widget.estimatedHours - 0.5);
                },
              ),
              Container(
                margin: AppInsets.h24,
                child: Text(
                  '${widget.estimatedHours.toStringAsFixed(widget.estimatedHours.truncateToDouble() == widget.estimatedHours ? 0 : 1)} h',
                  style: context.text.displaySmall,
                ),
              ),
              CounterButton(
                icon: Icons.add,
                onTap: () {
                  if (widget.estimatedHours < 12)
                    widget.onEstimatedHoursChanged(widget.estimatedHours + 0.5);
                },
              ),
            ],
          ),
        ),

        AppGap.h20,

        // ── Total estimé ───────────────────────────────────────────────────
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget estimé',
                style: context.text.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(widget.hourlyRate * widget.estimatedHours).round()} €',
                style: context.text.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        _buildCommissionPreview(widget.hourlyRate * widget.estimatedHours),
      ],
    );
  }

  Widget _buildFixedBudget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTANT TOTAL',
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        AppGap.h12,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: context.colors.divider),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) =>
                widget.onFixedBudgetChanged(double.tryParse(value) ?? 0),
            style: context.text.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: AppInputDecorations.formField(
              context,
              hintText: '0',
              hintStyle: context.text.bodyMedium?.copyWith(
                color: context.colors.border,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '€',
                  style: context.text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              contentPadding: AppInsets.a16,
              noBorder: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
        AppGap.h16,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [50, 100, 150, 200, 300].map((amount) {
            return GestureDetector(
              onTap: () {
                widget.onFixedBudgetChanged(amount.toDouble());
                Future.delayed(
                  const Duration(milliseconds: 300),
                  widget.onCompleted,
                );
              },
              child: Container(
                padding: AppInsets.h16v10,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(
                  '$amount€',
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        _buildCommissionPreview(widget.fixedBudget),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 💳 Widget carte type de budget
/// ─────────────────────────────────────────────────────────────
class BudgetTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const BudgetTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppInsets.a16,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppInsets.a10,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : context.colors.textSecondary,
              ),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// ➕➖ Widget bouton compteur
/// ─────────────────────────────────────────────────────────────
class CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CounterButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppInsets.a12,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.badge),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
