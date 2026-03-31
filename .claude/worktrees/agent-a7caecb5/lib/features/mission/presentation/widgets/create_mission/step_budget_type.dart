import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../data/models/create_mission_models.dart';

/// ─────────────────────────────────────────────────────────────
/// 💳 Step 6 — Type de budget uniquement
/// ─────────────────────────────────────────────────────────────
class StepBudgetType extends StatelessWidget {
  final String budgetType;
  final Function(String) onBudgetTypeChanged;
  final VoidCallback onCompleted;

  const StepBudgetType({
    super.key,
    required this.budgetType,
    required this.onBudgetTypeChanged,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment souhaitez-vous payer ?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Touchez un mode pour continuer',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          _BudgetTypeCard(
            icon: Icons.schedule_rounded,
            title: 'Paiement à l\'heure',
            subtitle: 'Payez selon le temps passé',
            isSelected: budgetType == CreateBudgetType.hourly,
            onTap: () {
              onBudgetTypeChanged(CreateBudgetType.hourly);
              Future.delayed(const Duration(milliseconds: 250), onCompleted);
            },
          ),
          const SizedBox(height: 14),

          _BudgetTypeCard(
            icon: Icons.payments_rounded,
            title: 'Budget fixe',
            subtitle: 'Définissez un montant total',
            isSelected: budgetType == CreateBudgetType.fixed,
            onTap: () {
              onBudgetTypeChanged(CreateBudgetType.fixed);
              Future.delayed(const Duration(milliseconds: 250), onCompleted);
            },
          ),
        ],
      ),
    );
  }
}

class _BudgetTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetTypeCard({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22)
            else
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
