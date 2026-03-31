import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

/// ─────────────────────────────────────────────────────────────
/// 🧾 Inkern - Historique des paiements (Client)
/// ─────────────────────────────────────────────────────────────
class ClientPaymentHistoryPage extends StatefulWidget {
  const ClientPaymentHistoryPage({super.key});

  @override
  State<ClientPaymentHistoryPage> createState() => _ClientPaymentHistoryPageState();
}

class _ClientPaymentHistoryPageState extends State<ClientPaymentHistoryPage> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Paiements', 'Remboursements'];

  final List<_ClientTx> _transactions = [
    _ClientTx(type: _TxType.payment, title: 'Ménage appartement', subtitle: 'Thomas R.', amount: 55.00,
        date: DateTime.now().subtract(const Duration(hours: 2)), status: _TxStatus.completed, card: 'Visa •••• 4242'),
    _ClientTx(type: _TxType.payment, title: 'Jardinage - Paris 11e', subtitle: 'Julie M.', amount: 40.00,
        date: DateTime.now().subtract(const Duration(days: 1)), status: _TxStatus.completed, card: 'Visa •••• 4242'),
    _ClientTx(type: _TxType.refund, title: 'Remboursement mission annulée', subtitle: 'Marc D.', amount: 35.00,
        date: DateTime.now().subtract(const Duration(days: 2)), status: _TxStatus.completed, card: 'Visa •••• 4242'),
    _ClientTx(type: _TxType.payment, title: 'Repassage 2h', subtitle: 'Sarah L.', amount: 50.00,
        date: DateTime.now().subtract(const Duration(days: 4)), status: _TxStatus.completed, card: 'Mastercard •••• 8888'),
    _ClientTx(type: _TxType.payment, title: 'Bricolage - Montage meuble', subtitle: 'Antoine B.', amount: 80.00,
        date: DateTime.now().subtract(const Duration(days: 7)), status: _TxStatus.completed, card: 'Visa •••• 4242'),
    _ClientTx(type: _TxType.payment, title: 'Ménage bureau', subtitle: 'Thomas R.', amount: 65.00,
        date: DateTime.now().subtract(const Duration(days: 10)), status: _TxStatus.pending, card: 'Visa •••• 4242'),
    _ClientTx(type: _TxType.refund, title: 'Remboursement litige', subtitle: 'Inkern', amount: 25.00,
        date: DateTime.now().subtract(const Duration(days: 14)), status: _TxStatus.completed, card: 'Mastercard •••• 8888'),
  ];

  List<_ClientTx> get _filtered {
    if (_selectedFilter == 'Paiements') return _transactions.where((t) => t.type == _TxType.payment).toList();
    if (_selectedFilter == 'Remboursements') return _transactions.where((t) => t.type == _TxType.refund).toList();
    return _transactions;
  }

  double get _totalPaid => _transactions
      .where((t) => t.type == _TxType.payment && t.status == _TxStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalRefunded => _transactions
      .where((t) => t.type == _TxType.refund && t.status == _TxStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  int get _missionsPaidThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == _TxType.payment && t.status == _TxStatus.completed
            && t.date.year == now.year && t.date.month == now.month)
        .length;
  }

  double get _totalPaidThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == _TxType.payment && t.status == _TxStatus.completed
            && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (s, t) => s + t.amount);
  }

  static const _monthNames = ['janvier','février','mars','avril','mai','juin',
      'juillet','août','septembre','octobre','novembre','décembre'];

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
        title: const Text('Historique des paiements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textPrimary),
            onPressed: () {},
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildMonthlyCard(),
                _buildSummary(),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Aucune transaction', style: TextStyle(fontSize: 16, color: AppColors.textTertiary)))
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCard() {
    final now = DateTime.now();
    final monthLabel = '${_monthNames[now.month - 1]} ${now.year}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Résumé du mois', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
          const SizedBox(height: 4),
          Text(monthLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          Text('${_totalPaidThisMonth.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text('Total dépensé', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text('$_missionsPaidThisMonth', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('mission${_missionsPaidThisMonth > 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
              Text('payée${_missionsPaidThisMonth > 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(child: _SummaryCard(
            label: 'Total payé',
            amount: _totalPaid,
            icon: Icons.arrow_upward_rounded,
            color: AppColors.info,
            isPositive: false,
          )),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(
            label: 'Remboursements',
            amount: _totalRefunded,
            icon: Icons.arrow_downward_rounded,
            color: AppColors.success,
            isPositive: true,
          )),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(f, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final grouped = <String, List<_ClientTx>>{};
    for (final t in _filtered) {
      grouped.putIfAbsent(_dateKey(t.date), () => []).add(t);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final key = grouped.keys.elementAt(index);
        final txs = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 8),
              child: Text(key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: List.generate(txs.length, (i) => Column(children: [
                  _TxTile(tx: txs[i]),
                  if (i < txs.length - 1) Divider(height: 1, indent: 70, color: AppColors.divider),
                ])),
              ),
            ),
          ],
        );
      },
    );
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return "Aujourd'hui";
    if (d == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(date).inDays < 7) {
      const days = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
      return days[date.weekday - 1];
    }
    const months = ['janv.','févr.','mars','avr.','mai','juin','juil.','août','sept.','oct.','nov.','déc.'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

enum _TxType { payment, refund }
enum _TxStatus { completed, pending }

class _ClientTx {
  final _TxType type;
  final _TxStatus status;
  final String title, subtitle, card;
  final double amount;
  final DateTime date;
  const _ClientTx({required this.type, required this.status, required this.title,
      required this.subtitle, required this.card, required this.amount, required this.date});
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isPositive;
  const _SummaryCard({required this.label, required this.amount, required this.icon,
      required this.color, required this.isPositive});

  @override
  Widget build(BuildContext context) {
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
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 6),
          Text('${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} €',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final _ClientTx tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isRefund = tx.type == _TxType.refund;
    final isPending = tx.status == _TxStatus.pending;
    final color = isRefund ? AppColors.success : AppColors.info;
    final icon = isRefund ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(tx.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (isPending)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('En attente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Payé', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                ]),
                const SizedBox(height: 3),
                Text(tx.subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.credit_card_rounded, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(tx.card, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${isRefund ? '+' : '-'}${tx.amount.toStringAsFixed(2)} €',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: isRefund ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
