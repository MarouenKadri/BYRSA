import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import 'client_payment_methods_page.dart';
import 'client_payment_history_page.dart';

/// ─────────────────────────────────────────────────────────────
/// 💳 Inkern - Mon Portefeuille (Client)
/// ─────────────────────────────────────────────────────────────
class ClientWalletPage extends StatelessWidget {
  final bool embedded;

  const ClientWalletPage({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        AppHeroSliverBar(
          gradientColors: const [AppColors.blueAction, AppColors.blueDark],
          expandedHeight: 220,
          leadingBack: embedded ? const SizedBox.shrink() : null,
          actions: embedded
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.history_rounded, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientPaymentHistoryPage(),
                      ),
                    ),
                  ),
                ],
          body: _WalletBalanceBody(),
        ),
        SliverToBoxAdapter(child: _buildQuickActions(context)),
        SliverToBoxAdapter(child: _buildPendingPayments(context)),
        SliverToBoxAdapter(child: _buildRecentPayments(context)),
        const SliverToBoxAdapter(child: AppGap.h32),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    if (embedded) {
      return Padding(
        padding: AppInsets.a16,
        child: Row(
          children: [
            Expanded(
              child: AppQuickActionCard(
                icon: Icons.add_rounded,
                label: 'Ajouter',
                color: AppColors.blueAction,
                onTap: () => _showAddFundsSheet(context),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: AppInsets.a16,
      child: Row(
        children: [
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.add_rounded,
              label: 'Ajouter',
              color: AppColors.blueAction,
              onTap: () => _showAddFundsSheet(context),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.credit_card_rounded,
              label: 'Cartes',
              color: Colors.purple,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClientPaymentMethodsPage())),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.receipt_long_rounded,
              label: 'Historique',
              color: Colors.teal,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClientPaymentHistoryPage())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPayments(BuildContext context) {
    final pending = [
      _PendingPayment(title: 'Création logo',      amount: '100,00 €', hoursLeft: 14),
      _PendingPayment(title: 'Réparation plomberie', amount: '65,00 €', hoursLeft: 6),
    ];

    return Padding(
      padding: AppInsets.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_clock_rounded, size: 18, color: Colors.orange),
              AppGap.w8,
              Text(
                'Paiements en cours',
                style: context.text.titleMedium?.copyWith(
                  fontSize: AppFontSize.xl,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          AppGap.h4,
          Text(
            'Les fonds sont sécurisés et seront versés au prestataire après confirmation.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),
          AppGap.h10,
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: List.generate(pending.length, (i) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_clock_rounded, color: Colors.orange, size: 22),
                        ),
                        AppGap.w14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pending[i].title,
                                style: context.text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              AppGap.h2,
                              Text(
                                '${pending[i].amount} sécurisés · confirmation dans ${pending[i].hoursLeft}h',
                                style: context.text.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < pending.length - 1)
                    Divider(height: 1, indent: 72, color: Colors.orange.withValues(alpha: 0.15)),
                ],
              )),
            ),
          ),
          AppGap.h20,
        ],
      ),
    );
  }

  Widget _buildRecentPayments(BuildContext context) {
    final payments = [
      _Payment(title: 'Ménage appartement', subtitle: 'Thomas R.', amount: '-55,00 €', date: "Aujourd'hui"),
      _Payment(title: 'Jardinage',          subtitle: 'Julie M.',   amount: '-40,00 €', date: 'Hier'),
      _Payment(title: 'Repassage',          subtitle: 'Marc D.',    amount: '-35,00 €', date: '25 Nov'),
      _Payment(title: 'Bricolage',          subtitle: 'Antoine B.', amount: '-80,00 €', date: '20 Nov'),
    ];

    return Padding(
      padding: AppInsets.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paiements récents',
                  style: context.text.titleMedium?.copyWith(
                    fontSize: AppFontSize.xl,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              AppButton(
                label: 'Voir tout',
                variant: ButtonVariant.ghost,
                onPressed: embedded
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientPaymentHistoryPage(),
                          ),
                        ),
              ),
            ],
          ),
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppDesign.radius16),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: List.generate(payments.length, (i) => Column(
                children: [
                  AppTransactionTile(
                    icon: Icons.arrow_upward_rounded,
                    iconColor: AppColors.info,
                    iconBackground: AppColors.primaryLight,
                    title: payments[i].title,
                    subtitle: payments[i].subtitle,
                    amount: payments[i].amount,
                    date: payments[i].date,
                  ),
                  if (i < payments.length - 1)
                    Divider(height: 1, indent: 72, color: context.colors.divider),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFundsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _AddFundsSheet(),
    );
  }
}

// ─── Balance hero body ────────────────────────────────────────────────────────

class _WalletBalanceBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.a20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppGap.h20,
          Text(
            'Crédit disponible',
            style: context.text.bodyMedium?.copyWith(
              fontSize: AppFontSize.base,
              color: Colors.white70,
            ),
          ),
          AppGap.h8,
          Text(
            '50,00 €',
            style: context.text.displayLarge?.copyWith(
              fontSize: AppFontSize.d5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feuille ajout de fonds ──────────────────────────────────────────────────

class _AddFundsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDesign.radius24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBottomSheetHandle(),
          AppGap.h8,
          Text(
            'Ajouter des fonds',
            style: context.text.titleLarge?.copyWith(
              fontSize: AppFontSize.h3,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h24,
          TextField(
            keyboardType: TextInputType.number,
            decoration: AppInputDecorations.formField(
              context,
              hintText: 'Ex: 50',
              suffixIcon: Padding(
                padding: AppInsets.h16v16,
                child: Text(
                  '€',
                  style: context.text.titleMedium?.copyWith(
                    fontSize: AppFontSize.h3,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            style: context.text.displaySmall?.copyWith(
              fontSize: AppFontSize.h2,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h12,
          Row(
            children: [
              _buildAmountChip(context, '20 €'),
              AppGap.w8,
              _buildAmountChip(context, '50 €'),
              AppGap.w8,
              _buildAmountChip(context, '100 €'),
              AppGap.w8,
              _buildAmountChip(context, '200 €'),
            ],
          ),
          AppGap.h16,
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(AppDesign.radius10),
              border: Border.all(color: AppColors.blueAction),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: AppColors.blueAction),
                AppGap.w12,
                Text(
                  'Visa •••• 4242',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.check_circle_rounded, color: AppColors.blueAction),
              ],
            ),
          ),
          AppGap.h24,
          AppButton(
            label: 'Ajouter',
            variant: ButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildAmountChip(BuildContext context, String amount) {
    return AppPillChip(
      label: amount,
      selected: false,
      onTap: () {},
      padding: AppInsets.h12v8,
    );
  }
}

// ─── Modèles locaux ───────────────────────────────────────────────────────────

class _Payment {
  final String title, subtitle, amount, date;
  const _Payment({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
  });
}

class _PendingPayment {
  final String title, amount;
  final int hoursLeft;
  const _PendingPayment({
    required this.title,
    required this.amount,
    required this.hoursLeft,
  });
}
