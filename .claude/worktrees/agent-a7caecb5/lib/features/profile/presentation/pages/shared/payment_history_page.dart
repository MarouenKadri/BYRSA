import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historique des paiements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textPrimary),
            onPressed: () => _showExportSheet(),
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Résumé + Filtres
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Résumé financier
                _buildSummarySection(),

                const SizedBox(height: 16),

                // Filtre période
                _buildPeriodFilter(),

                const SizedBox(height: 12),

                // Filtres par type
                _buildTypeFilters(),

                const SizedBox(height: 16),
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
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              label: 'Retraits',
              amount: _totalWithdrawals,
              icon: Icons.arrow_upward_rounded,
              color: AppColors.info,
              isPositive: false,
            ),
          ),
          const SizedBox(width: 12),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showPeriodPicker(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(
                _selectedPeriod,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les transactions apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Transactions du jour
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(transactions.length, (i) {
                  return Column(
                    children: [
                      _buildTransactionItem(transactions[i]),
                      if (i < transactions.length - 1)
                        Divider(height: 1, indent: 70, color: AppColors.divider),
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: transaction.type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.type.icon,
                color: transaction.type.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.status != TransactionStatus.completed)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: transaction.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            transaction.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: transaction.status.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.clientName ?? transaction.description ?? transaction.type.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Montant
            Text(
              '${transaction.type.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: transaction.type.isPositive ? AppColors.success : AppColors.textPrimary,
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sélectionner une période',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
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
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                  title: Text(
                    period,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                );
              }),
              const SizedBox(height: 12),
              // Période personnalisée
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _showCustomDateRangePicker();
                },
                leading: Icon(Icons.date_range_rounded, color: AppColors.textTertiary),
                title: const Text('Période personnalisée'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
              ),
            ],
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icône et montant
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: transaction.type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${transaction.type.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: transaction.type.isPositive ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: transaction.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.status.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: transaction.status.color,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Détails
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Type', transaction.type.label),
                    if (transaction.missionTitle != null) ...[
                      Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow('Mission', transaction.missionTitle!),
                    ],
                    if (transaction.clientName != null) ...[
                      Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow('Client', transaction.clientName!),
                    ],
                    if (transaction.description != null) ...[
                      Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow('Description', transaction.description!),
                    ],
                    if (transaction.paymentMethod != null) ...[
                      Divider(height: 20, color: AppColors.divider),
                      _buildDetailRow('Méthode', transaction.paymentMethod!),
                    ],
                    Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow(
                      'Date',
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} à ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
                    ),
                    Divider(height: 20, color: AppColors.divider),
                    _buildDetailRow('Référence', '#${transaction.id.padLeft(8, '0')}'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Télécharger reçu
                      },
                      icon: const Icon(Icons.receipt_rounded, size: 18),
                      label: const Text('Reçu'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Signaler un problème
                      },
                      icon: const Icon(Icons.flag_rounded, size: 18),
                      label: const Text('Signaler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
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
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Exporter l\'historique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez le format d\'export',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              _buildExportOption(
                icon: Icons.picture_as_pdf_rounded,
                title: 'PDF',
                subtitle: 'Document formaté pour impression',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                icon: Icons.table_chart_rounded,
                title: 'Excel (CSV)',
                subtitle: 'Tableur pour analyse',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                icon: Icons.email_rounded,
                title: 'Envoyer par email',
                subtitle: 'Recevoir par email',
                color: AppColors.info,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
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
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

}