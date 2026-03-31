import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

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
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Historique des paiements', style: context.profilePageTitleStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: context.colors.textPrimary),
            onPressed: () {},
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: context.colors.surface,
            child: Column(
              children: [
                _buildMonthlyCard(),
                _buildSummary(),
                AppGap.h12,
                _buildFilters(),
                AppGap.h16,
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Aucune transaction', style: context.text.titleMedium?.copyWith(color: context.colors.textTertiary)))
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
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha:0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Résumé du mois', style: context.text.bodySmall?.copyWith(color: Colors.white.withValues(alpha:0.85))),
          AppGap.h4,
          Text(monthLabel, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
          AppGap.h12,
          Text('${_totalPaidThisMonth.toStringAsFixed(2)} €',
              style: context.text.displayMedium?.copyWith(color: Colors.white)),
          AppGap.h2,
          Text('Total dépensé', style: context.text.labelMedium?.copyWith(color: Colors.white.withValues(alpha:0.8))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: AppInsets.h12v8,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(AppRadius.button)),
            child: Column(children: [
              Text('$_missionsPaidThisMonth', style: context.text.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.white)),
              Text('mission${_missionsPaidThisMonth > 1 ? 's' : ''}', style: context.text.labelMedium?.copyWith(color: Colors.white.withValues(alpha:0.85))),
              Text('payée${_missionsPaidThisMonth > 1 ? 's' : ''}', style: context.text.labelMedium?.copyWith(color: Colors.white.withValues(alpha:0.85))),
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
          AppGap.w12,
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
        padding: AppInsets.h16,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => AppGap.w8,
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: AppInsets.h16,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
              ),
              alignment: Alignment.center,
              child: Text(f, style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : null)),
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
      padding: AppInsets.a16,
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final key = grouped.keys.elementAt(index);
        final txs = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 8),
              child: Text(key, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: List.generate(txs.length, (i) => Column(children: [
                  _TxTile(tx: txs[i]),
                  if (i < txs.length - 1) Divider(height: 1, indent: 70, color: context.colors.divider),
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
      padding: AppInsets.a12,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            AppGap.w4,
            Text(label, style: context.text.labelMedium),
          ]),
          AppGap.h6,
          Text('${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} €',
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
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
      padding: AppInsets.a16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppInsets.a10,
            decoration: BoxDecoration(color: color.withValues(alpha:0.1), borderRadius: BorderRadius.circular(AppRadius.button)),
            child: Icon(icon, color: color, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(tx.title,
                      style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (isPending)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text('En attente', style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text('Payé', style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                ]),
                AppGap.h3,
                Text(tx.subtitle, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                AppGap.h2,
                Row(children: [
                  Icon(Icons.credit_card_rounded, size: 12, color: context.colors.textTertiary),
                  AppGap.w4,
                  Text(tx.card, style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary)),
                ]),
              ],
            ),
          ),
          AppGap.w12,
          Text('${isRefund ? '+' : '-'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isRefund ? AppColors.success : null)),
        ],
      ),
    );
  }
}
