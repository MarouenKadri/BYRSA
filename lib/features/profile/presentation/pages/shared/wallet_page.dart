import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar avec solde ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildBalanceHeader(context),
            ),
          ),

          // ─── Actions rapides ───
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),

          // ─── Transactions récentes ───
          SliverToBoxAdapter(
            child: _buildTransactionsSection(context),
          ),

          // ─── Moyens de paiement ───
          SliverToBoxAdapter(
            child: _buildPaymentMethods(context),
          ),

          // ─── Coordonnées bancaires ───
          SliverToBoxAdapter(
            child: _buildBankDetails(context),
          ),

          const SliverToBoxAdapter(
            child: AppGap.h32,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withGreen(200),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppInsets.a20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppGap.h20,
              Text(
                'Solde disponible',
                style: context.profileSecondaryLabelStyle.copyWith(
                  color: Colors.white70,
                  fontSize: AppFontSize.base,
                ),
              ),
              AppGap.h8,
              Text(
                '245,50 €',
                style: context.profilePageTitleStyle.copyWith(
                  fontSize: AppFontSize.d5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: AppInsets.a16,
      child: Row(
        children: [
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.arrow_upward_rounded,
              label: 'Retirer',
              color: AppColors.primary,
              onTap: () => _showWithdrawSheet(context),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.add_rounded,
              label: 'Ajouter',
              color: AppColors.info,
              onTap: () => _showAddFundsSheet(context),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: AppQuickActionCard(
              icon: Icons.send_rounded,
              label: 'Envoyer',
              color: Colors.orange,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context) {
    final transactions = [
      _Transaction(
        title: 'Mission : Ménage appartement',
        subtitle: 'De Marie L.',
        amount: '+55,00 €',
        date: 'Aujourd\'hui',
        type: TransactionType.income,
      ),
      _Transaction(
        title: 'Retrait vers compte bancaire',
        subtitle: 'IBAN •••• 1234',
        amount: '-100,00 €',
        date: 'Hier',
        type: TransactionType.withdrawal,
      ),
      _Transaction(
        title: 'Mission : Réparation plomberie',
        subtitle: 'De Pierre D.',
        amount: '+65,00 €',
        date: '25 Nov',
        type: TransactionType.income,
      ),
      _Transaction(
        title: 'Mission : Montage meuble',
        subtitle: 'De Sophie M.',
        amount: '+45,00 €',
        date: '22 Nov',
        type: TransactionType.income,
      ),
      _Transaction(
        title: 'Commission Inkern',
        subtitle: '10% sur mission',
        amount: '-6,50 €',
        date: '22 Nov',
        type: TransactionType.fee,
      ),
    ];

    return Padding(
      padding: AppInsets.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Transactions récentes',
            padding: EdgeInsets.zero,
            trailing: AppButton(
              label: 'Voir tout',
              variant: ButtonVariant.ghost,
              width: null,
              onPressed: () {},
            ),
          ),
          AppGap.h8,
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            border: Border.all(color: context.colors.border),
            child: Column(
              children: [
                for (int i = 0; i < transactions.length; i++) ...[
                  _TransactionTile(transaction: transactions[i]),
                  if (i < transactions.length - 1)
                    Divider(height: 1, indent: 72, color: context.colors.divider),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Padding(
      padding: AppInsets.a16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: 'Moyens de paiement', padding: EdgeInsets.zero),
          AppGap.h12,
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            border: Border.all(color: context.colors.border),
            child: Column(
              children: [
                _PaymentMethodTile(
                  icon: Icons.credit_card_rounded,
                  iconColor: AppColors.info,
                  title: 'Visa •••• 4242',
                  subtitle: 'Expire 12/26',
                  isDefault: true,
                ),
                Divider(height: 1, indent: 72, color: context.colors.divider),
                _PaymentMethodTile(
                  icon: Icons.credit_card_rounded,
                  iconColor: Colors.orange,
                  title: 'Mastercard •••• 8888',
                  subtitle: 'Expire 08/25',
                  isDefault: false,
                ),
                Divider(height: 1, indent: 72, color: context.colors.divider),
                _AddPaymentTile(
                  onTap: () => _showAddCardSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetails(BuildContext context) {
    return Padding(
      padding: AppInsets.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: 'Compte bancaire', padding: EdgeInsets.zero),
          AppGap.h12,
          AppSurfaceCard(
            padding: AppInsets.a16,
            border: Border.all(color: context.colors.border),
            child: Row(
              children: [
                AppSurfaceCard(
                  padding: AppInsets.a12,
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDesign.radius12),
                  child: Icon(Icons.account_balance_rounded, color: AppColors.success, size: 28),
                ),
                AppGap.w14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compte principal',
                        style: context.profilePrimaryLabelStyle.copyWith(
                          fontSize: AppFontSize.lg,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        'IBAN FR76 •••• •••• •••• 1234',
                        style: context.profileSecondaryLabelStyle.copyWith(
                          fontSize: AppFontSize.base,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AppFormSheet(
          title: 'Retirer des fonds',
          footer: AppButton(
            label: 'Retirer',
            onPressed: () => Navigator.pop(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solde disponible : 245,50 €',
                style: context.profileSecondaryLabelStyle,
              ),
              AppGap.h24,
              TextField(
                keyboardType: TextInputType.number,
                decoration: AppInputDecorations.formField(
                  context,
                  hintText: 'Ex: 100',
                ).copyWith(
                  labelText: 'Montant à retirer',
                  labelStyle: context.profileSheetFieldLabelStyle,
                  suffixText: '€',
                ),
                style: context.profileValueStyle.copyWith(
                  fontSize: AppFontSize.h2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppGap.h12,
              Row(
                children: [
                  AppPillChip(label: '50 €', onTap: () {}, padding: AppInsets.h12v8),
                  AppGap.w8,
                  AppPillChip(label: '100 €', onTap: () {}, padding: AppInsets.h12v8),
                  AppGap.w8,
                  AppPillChip(label: '200 €', onTap: () {}, padding: AppInsets.h12v8),
                  AppGap.w8,
                  AppPillChip(label: 'Tout', onTap: () {}, padding: AppInsets.h12v8),
                ],
              ),
              AppGap.h24,
              AppSurfaceCard(
                padding: AppInsets.a12,
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(AppDesign.radius10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                    AppGap.w10,
                    Expanded(
                      child: Text(
                        'Le virement sera effectué sous 2-3 jours ouvrés',
                        style: context.profileSecondaryLabelStyle.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFundsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AppFormSheet(
          title: 'Ajouter des fonds',
          footer: AppButton(
            label: 'Ajouter',
            onPressed: () => Navigator.pop(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: AppInputDecorations.formField(
                  context,
                  hintText: 'Ex: 50',
                ).copyWith(
                  labelText: 'Montant',
                  labelStyle: context.profileSheetFieldLabelStyle,
                  suffixText: '€',
                ),
                style: context.profileValueStyle.copyWith(
                  fontSize: AppFontSize.h2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppGap.h16,
              Text(
                'Carte de paiement',
                style: context.profilePrimaryLabelStyle.copyWith(fontSize: AppFontSize.base),
              ),
              AppGap.h8,
              AppSurfaceCard(
                padding: AppInsets.a12,
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppDesign.radius10),
                border: Border.all(color: AppColors.primary),
                child: Row(
                  children: [
                    Icon(Icons.credit_card_rounded, color: AppColors.info),
                    AppGap.w12,
                    Text(
                      'Visa •••• 4242',
                      style: context.profilePrimaryLabelStyle,
                    ),
                    const Spacer(),
                    Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AppFormSheet(
          title: 'Ajouter une carte',
          footer: AppButton(
            label: 'Ajouter la carte',
            onPressed: () => Navigator.pop(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: AppInputDecorations.formField(
                  context,
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card_rounded),
                ).copyWith(
                  labelText: 'Numéro de carte',
                  labelStyle: context.profileSheetFieldLabelStyle,
                ),
                keyboardType: TextInputType.number,
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: 'MM/AA',
                      ).copyWith(
                        labelText: 'Date d\'expiration',
                        labelStyle: context.profileSheetFieldLabelStyle,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: TextField(
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: '123',
                      ).copyWith(
                        labelText: 'CVV',
                        labelStyle: context.profileSheetFieldLabelStyle,
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TransactionType { income, withdrawal, fee }

class _Transaction {
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final TransactionType type;

  const _Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class _TransactionTile extends StatelessWidget {
  final _Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color bgColor;
    IconData icon;

    switch (transaction.type) {
      case TransactionType.income:
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.12);
        icon = Icons.arrow_downward_rounded;
        break;
      case TransactionType.withdrawal:
        iconColor = AppColors.info;
        bgColor = context.colors.surfaceAlt;
        icon = Icons.arrow_upward_rounded;
        break;
      case TransactionType.fee:
        iconColor = Colors.orange;
        bgColor = AppColors.warning.withValues(alpha:0.08);
        icon = Icons.percent_rounded;
        break;
    }

    return Padding(
      padding: AppInsets.h16v12,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  transaction.subtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: AppFontSize.md,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: context.text.titleSmall?.copyWith(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.w700,
                  color: transaction.type == TransactionType.income
                      ? AppColors.primary
                      : context.colors.textPrimary,
                ),
              ),
              Text(
                transaction.date,
                style: context.text.labelSmall?.copyWith(
                  fontSize: AppFontSize.sm,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDefault;

  const _PaymentMethodTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.h16v14,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDesign.radius10),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        fontSize: AppFontSize.body,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (isDefault) ...[
                      AppGap.w8,
                      AppTagPill(
                        label: 'Par défaut',
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        foregroundColor: AppColors.primary,
                        padding: AppInsets.h8v2,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: AppFontSize.md,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
        ],
      ),
    );
  }
}

class _AddPaymentTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPaymentTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppInsets.h16v14,
        child: Row(
          children: [
            AppSurfaceCard(
              padding: AppInsets.a10,
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppDesign.radius10),
              border: Border.all(color: context.colors.border, style: BorderStyle.solid),
              child: Icon(Icons.add_rounded, color: context.colors.textSecondary, size: 24),
            ),
            AppGap.w14,
            Text(
              'Ajouter une carte',
              style: context.text.titleSmall?.copyWith(
                fontSize: AppFontSize.body,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

