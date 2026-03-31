import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
// AppPageAppBar, AppBackButtonLeading centralisés via app_primitives
import '../../../data/models/transaction.dart';

/// Page Historique des paiements
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  // Filtre sélectionné
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Revenus', 'Retraits', 'Frais'];

  // Période sélectionnée
  String _selectedPeriod = 'Ce mois';
  final List<String> _periods = ['Cette semaine', 'Ce mois', '3 derniers mois', 'Cette année', 'Tout'];

  // Données simulées
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 85.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      missionTitle: 'Ménage appartement',
      clientName: 'Marie Dupont',
    ),
    Transaction(
      id: '2',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 8.50,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Commission Inkern (10%)',
    ),
    Transaction(
      id: '3',
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      amount: 150.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'Virement bancaire',
      description: 'Vers IBAN •••• 1234',
    ),
    Transaction(
      id: '4',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 120.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      missionTitle: 'Jardinage',
      clientName: 'Pierre Martin',
    ),
    Transaction(
      id: '5',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 12.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Commission Inkern (10%)',
    ),
    Transaction(
      id: '6',
      type: TransactionType.bonus,
      status: TransactionStatus.completed,
      amount: 20.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Bonus parrainage',
    ),
    Transaction(
      id: '7',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 65.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      missionTitle: 'Bricolage - Montage meuble',
      clientName: 'Sophie Bernard',
    ),
    Transaction(
      id: '8',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 6.50,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Commission Inkern (10%)',
    ),
    Transaction(
      id: '9',
      type: TransactionType.withdrawal,
      status: TransactionStatus.completed,
      amount: 200.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      paymentMethod: 'Virement bancaire',
      description: 'Vers IBAN •••• 1234',
    ),
    Transaction(
      id: '10',
      type: TransactionType.refund,
      status: TransactionStatus.completed,
      amount: 25.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Remboursement mission annulée',
    ),
    Transaction(
      id: '11',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 95.00,
      date: DateTime.now().subtract(const Duration(days: 12)),
      missionTitle: 'Repassage',
      clientName: 'Lucie Moreau',
    ),
    Transaction(
      id: '12',
      type: TransactionType.withdrawal,
      status: TransactionStatus.failed,
      amount: 100.00,
      date: DateTime.now().subtract(const Duration(days: 15)),
      paymentMethod: 'Virement bancaire',
      description: 'IBAN invalide',
    ),
  ];

  List<Transaction> get _filteredTransactions {
    return _transactions.where((t) {
      if (_selectedFilter == 'Revenus') {
        return t.type == TransactionType.income || 
               t.type == TransactionType.bonus || 
               t.type == TransactionType.refund;
      } else if (_selectedFilter == 'Retraits') {
        return t.type == TransactionType.withdrawal;
      } else if (_selectedFilter == 'Frais') {
        return t.type == TransactionType.fee;
      }
      return true;
    }).toList();
  }

  double get _totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalWithdrawals {
    return _transactions
        .where((t) => t.type == TransactionType.withdrawal && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalFees {
    return _transactions
        .where((t) => t.type == TransactionType.fee && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Historique des paiements',
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: context.colors.textPrimary),
            onPressed: () => _showExportSheet(),
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Résumé + Filtres
          AppSection(
            color: context.colors.surface,
            child: Column(
              children: [
                // Résumé financier
                _buildSummarySection(),

                AppGap.h16,

                // Filtre période
                _buildPeriodFilter(),

                AppGap.h12,

                // Filtres par type
                _buildTypeFilters(),

                AppGap.h16,
              ],
            ),
          ),

          // Liste des transactions
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              label: 'Revenus',
              amount: _totalIncome,
              icon: Icons.arrow_downward_rounded,
              color: AppColors.success,
              isPositive: true,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: _buildSummaryCard(
              label: 'Retraits',
              amount: _totalWithdrawals,
              icon: Icons.arrow_upward_rounded,
              color: AppColors.info,
              isPositive: false,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: _buildSummaryCard(
              label: 'Frais',
              amount: _totalFees,
              icon: Icons.receipt_long_rounded,
              color: Colors.red,
              isPositive: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return AppSurfaceCard(
      padding: AppInsets.a12,
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppRadius.button),
      border: Border.all(color: color.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              AppGap.w4,
              Text(
                label,
                style: context.text.labelMedium,
              ),
            ],
          ),
          AppGap.h6,
          Text(
            '${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} €',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Padding(
      padding: AppInsets.h16,
      child: GestureDetector(
        onTap: () => _showPeriodPicker(),
        child: AppSurfaceCard(
          padding: AppInsets.h16v12,
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 20, color: context.colors.textSecondary),
              AppGap.w10,
              Text(
                _selectedPeriod,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.h16,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => AppGap.w8,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AppSurfaceCard(
              padding: AppInsets.h16,
              color: isSelected ? AppColors.primary : context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
              child: Center(
                child: Text(
                  filter,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyStateBlock(
      icon: Icons.receipt_long_rounded,
      title: 'Aucune transaction',
      message: 'Les transactions apparaîtront ici',
    );
  }

  Widget _buildTransactionsList() {
    // Grouper par date
    final grouped = <String, List<Transaction>>{};
    for (final transaction in _filteredTransactions) {
      final dateKey = _getDateKey(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return ListView.builder(
      padding: AppInsets.a16,
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final transactions = grouped[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 8),
              child: Text(
                dateKey,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Transactions du jour
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              border: Border.all(color: context.colors.border),
              child: Column(
                children: List.generate(transactions.length, (i) {
                  return Column(
                    children: [
                      _buildTransactionItem(transactions[i]),
                      if (i < transactions.length - 1)
                        Divider(height: 1, indent: 70, color: context.colors.divider),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return InkWell(
      onTap: () => _showTransactionDetails(transaction),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: AppInsets.a16,
        child: Row(
          children: [
            // Icône
            AppSurfaceCard(
              padding: AppInsets.a10,
              color: transaction.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: Icon(
                transaction.type.icon,
                color: transaction.type.color,
                size: 22,
              ),
            ),
            AppGap.w14,

            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.missionTitle ?? transaction.type.label,
                          style: context.text.titleSmall?.copyWith(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.status != TransactionStatus.completed)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: AppTagPill(
                            label: transaction.status.label,
                            backgroundColor: transaction.status.color.withValues(alpha: 0.1),
                            foregroundColor: transaction.status.color,
                            padding: AppInsets.h8v2,
                            fontSize: AppFontSize.xs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  AppGap.h4,
                  Text(
                    transaction.clientName ?? transaction.description ?? transaction.type.label,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            AppGap.w12,

            // Montant
            Text(
              '${transaction.type.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: transaction.type.isPositive ? AppColors.success : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Aujourd\'hui';
    } else if (transactionDate == yesterday) {
      return 'Hier';
    } else if (now.difference(date).inDays < 7) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 
                    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return months[month - 1];
  }

  void _showPeriodPicker() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Padding(
          padding: AppInsets.a20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              AppGap.h20,
              Text(
                'Sélectionner une période',
                style: context.text.headlineSmall?.copyWith(),
              ),
              AppGap.h20,
              ...List.generate(_periods.length, (index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period;
                return ListTile(
                  onTap: () {
                    setState(() => _selectedPeriod = period);
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.calendar_today_rounded,
                    color: isSelected ? AppColors.primary : context.colors.textTertiary,
                  ),
                  title: Text(
                    period,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : context.colors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                );
              }),
              AppGap.h12,
              // Période personnalisée
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _showCustomDateRangePicker();
                },
                leading: Icon(Icons.date_range_rounded, color: context.colors.textTertiary),
                title: const Text('Période personnalisée'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = '${picked.start.day}/${picked.start.month} - ${picked.end.day}/${picked.end.month}';
      });
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Padding(
          padding: AppInsets.a20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              AppGap.h24,

              // Icône et montant
              Container(
                padding: AppInsets.a16,
                decoration: BoxDecoration(
                  color: transaction.type.color.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 32,
                ),
              ),
              AppGap.h16,
              Text(
                '${transaction.type.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
                style: context.text.displaySmall?.copyWith(
                  color: transaction.type.isPositive ? AppColors.success : context.colors.textPrimary,
                ),
              ),
              AppGap.h8,
              Container(
                padding: AppInsets.h12v6,
                decoration: BoxDecoration(
                  color: transaction.status.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                ),
                child: Text(
                  transaction.status.label,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: transaction.status.color,
                  ),
                ),
              ),

              AppGap.h24,

              // Détails
              Container(
                padding: AppInsets.a16,
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Type', transaction.type.label),
                    if (transaction.missionTitle != null) ...[
                      Divider(height: 20, color: context.colors.divider),
                      _buildDetailRow('Mission', transaction.missionTitle!),
                    ],
                    if (transaction.clientName != null) ...[
                      Divider(height: 20, color: context.colors.divider),
                      _buildDetailRow('Client', transaction.clientName!),
                    ],
                    if (transaction.description != null) ...[
                      Divider(height: 20, color: context.colors.divider),
                      _buildDetailRow('Description', transaction.description!),
                    ],
                    if (transaction.paymentMethod != null) ...[
                      Divider(height: 20, color: context.colors.divider),
                      _buildDetailRow('Méthode', transaction.paymentMethod!),
                    ],
                    Divider(height: 20, color: context.colors.divider),
                    _buildDetailRow(
                      'Date',
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} à ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
                    ),
                    Divider(height: 20, color: context.colors.divider),
                    _buildDetailRow('Référence', '#${transaction.id.padLeft(8, '0')}'),
                  ],
                ),
              ),

              AppGap.h20,

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reçu',
                      variant: ButtonVariant.outline,
                      icon: Icons.receipt_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                        // Télécharger reçu
                      },
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: AppButton(
                      label: 'Signaler',
                      variant: ButtonVariant.outline,
                      icon: Icons.flag_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                        // Signaler un problème
                      },
                    ),
                  ),
                ],
              ),

              AppGap.h12,

              AppButton(
                label: 'Fermer',
                variant: ButtonVariant.ghost,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.text.bodyMedium,
        ),
        Flexible(
          child: Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showExportSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) {
        final bottomPad = MediaQuery.of(context).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              AppGap.h16,


              // PDF option
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PDF', style: context.text.titleSmall),
                            AppGap.h2,
                            Text('Document formaté pour impression', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              // CSV option
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.table_chart_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Excel (CSV)', style: context.text.titleSmall),
                            AppGap.h2,
                            Text('Tableur pour analyse', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: context.colors.divider, indent: 16, endIndent: 16),

              // Email option
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: AppInsets.h20v12,
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: context.colors.surfaceAlt, shape: BoxShape.circle),
                        child: const Icon(Icons.email_rounded, size: 20, color: AppColors.primary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Envoyer par email', style: context.text.titleSmall),
                            AppGap.h2,
                            Text('Recevoir par email', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fermer
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 16 + bottomPad),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Fermer',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: AppInsets.a16,
          child: Row(
            children: [
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
            ],
          ),
        ),
      ),
    );
  }

}
