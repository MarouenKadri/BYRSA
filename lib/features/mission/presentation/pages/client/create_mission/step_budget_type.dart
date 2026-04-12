import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'create_mission_models.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment souhaitez-vous payer ?',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w600,
              height: 1.16,
              color: AppColors.inkDark,
              letterSpacing: -0.6,
            ),
          ),
          AppGap.h10,
          Text(
            'Choisissez la formule qui correspond le mieux à votre mission.',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFFACB3BA),
            ),
          ),
          const SizedBox(height: 30),
          _BudgetTypeCard(
            icon: Icons.schedule_outlined,
            title: 'Paiement a l\'heure',
            subtitle: 'Payez selon le temps passe',
            isSelected: budgetType == CreateBudgetType.hourly,
            onTap: () {
              onBudgetTypeChanged(CreateBudgetType.hourly);
              Future.delayed(const Duration(milliseconds: 250), onCompleted);
            },
          ),
          AppGap.h14,
          _BudgetTypeCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget fixe',
            subtitle: 'Definissez un montant total',
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F1720) : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(16, 20, 24, 0.04),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.gray700,
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkDark,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF98A0A8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isSelected
                  ? const Color(0xFF0F1720)
                  : const Color(0xFFB5BCC4),
            ),
          ],
        ),
      ),
    );
  }
}
