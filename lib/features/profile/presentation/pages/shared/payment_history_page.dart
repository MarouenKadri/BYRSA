import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/transaction.dart';
import '../../widgets/shared/payment_common_widgets.dart';

/// ─────────────────────────────────────────────────────────────
/// Historique des paiements — Freelancer  (minimaliste)
/// ─────────────────────────────────────────────────────────────
class PaymentHistoryPage extends StatefulWidget {
  final bool embedded;
  const PaymentHistoryPage({super.key, this.embedded = false});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String _filter = 'Tout';
  String _period = 'Ce mois';

  final _filters = ['Tout', 'Revenus', 'Retraits', 'Frais'];
  final _periods = ['Cette semaine', 'Ce mois', '3 mois', 'Cette année', 'Tout'];

  final List<Transaction> _txs = [
    Transaction(id: '1', type: TransactionType.income,
        status: TransactionStatus.completed, amount: 85.00,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        missionTitle: 'Ménage appartement', clientName: 'Marie D.'),
    Transaction(id: '2', type: TransactionType.held,
        status: TransactionStatus.awaitingRelease, amount: 100.00,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        missionTitle: 'Création logo', clientName: 'Julien M.'),
    Transaction(id: '3', type: TransactionType.fee,
        status: TransactionStatus.completed, amount: 8.50,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Commission Inkern 10%'),
    Transaction(id: '4', type: TransactionType.withdrawal,
        status: TransactionStatus.pending, amount: 150.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Vers IBAN ···1234'),
    Transaction(id: '5', type: TransactionType.income,
        status: TransactionStatus.completed, amount: 120.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        missionTitle: 'Jardinage', clientName: 'Pierre M.'),
    Transaction(id: '6', type: TransactionType.fee,
        status: TransactionStatus.completed, amount: 12.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Commission Inkern 10%'),
    Transaction(id: '7', type: TransactionType.bonus,
        status: TransactionStatus.completed, amount: 20.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Bonus parrainage'),
    Transaction(id: '8', type: TransactionType.income,
        status: TransactionStatus.completed, amount: 65.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        missionTitle: 'Montage meuble', clientName: 'Sophie B.'),
    Transaction(id: '9', type: TransactionType.fee,
        status: TransactionStatus.completed, amount: 6.50,
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Commission Inkern 10%'),
    Transaction(id: '10', type: TransactionType.withdrawal,
        status: TransactionStatus.completed, amount: 200.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Vers IBAN ···1234'),
    Transaction(id: '11', type: TransactionType.refund,
        status: TransactionStatus.completed, amount: 25.00,
        date: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Remboursement mission annulée'),
  ];

  // ─── Computed ────────────────────────────────────────────────
  List<Transaction> get _filtered => _txs.where((t) {
    return switch (_filter) {
      'Revenus'  => t.type == TransactionType.income
                 || t.type == TransactionType.bonus
                 || t.type == TransactionType.refund
                 || t.type == TransactionType.held,
      'Retraits' => t.type == TransactionType.withdrawal,
      'Frais'    => t.type == TransactionType.fee,
      _          => true,
    };
  }).toList();

  double get _totalRevenu => _txs
      .where((t) => t.type == TransactionType.income
                 && t.status == TransactionStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalEnAttente => _txs
      .where((t) => t.type == TransactionType.held)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalRetrait => _txs
      .where((t) => t.type == TransactionType.withdrawal
                 && t.status == TransactionStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _filtered.isEmpty
              ? _buildEmpty(context)
              : _buildList(context),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Historique', style: context.profilePageTitleStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded,
                color: context.colors.textPrimary, size: 20),
            onPressed: _showExport,
          ),
        ],
      ),
      body: body,
    );
  }

  // ─── Header ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Résumé 3 tuiles ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(children: [
              Expanded(child: _SummaryTile(
                  label: 'Revenus', amount: _totalRevenu, positive: true)),
              AppGap.w10,
              Expanded(child: _SummaryTile(
                  label: 'En attente', amount: _totalEnAttente,
                  positive: true, highlight: true)),
              AppGap.w10,
              Expanded(child: _SummaryTile(
                  label: 'Retraits', amount: _totalRetrait, positive: false)),
            ]),
          ),
          // ── Sélecteur période ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: _showPeriodPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 15,
                      color: context.colors.textTertiary),
                  AppGap.w8,
                  Text(_period,
                      style: context.text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Icon(Icons.expand_more_rounded, size: 18,
                      color: context.colors.textTertiary),
                ]),
              ),
            ),
          ),
          // ── Filtres ──
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PaymentFilterPills(
              filters: _filters,
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Liste groupée par date ───────────────────────────────────
  Widget _buildList(BuildContext context) {
    final grouped = <String, List<Transaction>>{};
    for (final t in _filtered) {
      grouped.putIfAbsent(_dateLabel(t.date), () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final key = grouped.keys.elementAt(i);
        final list = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: i == 0 ? 0 : 16),
              child: Text(key,
                  style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: List.generate(list.length, (j) => Column(
                  children: [
                    _buildTile(context, list[j]),
                    if (j < list.length - 1)
                      Divider(height: 1, indent: 70,
                          color: context.colors.divider),
                  ],
                )),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, Transaction tx) {
    final isHeld = tx.type == TransactionType.held;
    final isPos  = tx.type.isPositive;

    final icon   = tx.type.icon;
    final title  = tx.missionTitle ?? tx.type.label;
    final sub    = tx.clientName ?? tx.description ?? '';
    final amount = '${isPos ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €';

    String? badge;
    Color?  badgeColor;
    if (isHeld) {
      badge = 'Versement sous 24h';
      badgeColor = AppColors.warning;
    } else if (tx.status != TransactionStatus.completed) {
      badge = tx.status.label;
      badgeColor = context.colors.textTertiary;
    }

    return PaymentTxTile(
      icon: icon,
      title: title,
      subtitle: sub,
      amount: amount,
      isPositive: isPos && !isHeld,
      badge: badge,
      badgeColor: badgeColor,
      onTap: () => _showDetail(context, tx),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long_rounded, size: 36,
            color: context.colors.textHint),
        AppGap.h12,
        Text('Aucune transaction',
            style: context.text.bodyMedium?.copyWith(
                color: context.colors.textTertiary)),
      ]),
    );
  }

  // ─── Sheet détail ─────────────────────────────────────────────
  void _showDetail(BuildContext context, Transaction tx) {
    final isPos = tx.type.isPositive;
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(99))),
            AppGap.h24,
            Text(
              '${isPos ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isPos ? AppColors.primary : context.colors.textPrimary),
            ),
            AppGap.h4,
            Text(tx.missionTitle ?? tx.type.label,
                style: context.text.bodyMedium?.copyWith(
                    color: context.colors.textSecondary)),
            AppGap.h6,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tx.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: tx.status.color.withValues(alpha: 0.3)),
              ),
              child: Text(tx.status.label,
                  style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tx.status.color)),
            ),
            AppGap.h24,
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(children: [
                _DetailRow('Type', tx.type.label),
                if (tx.clientName != null) ...[
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow('Client', tx.clientName!),
                ],
                if (tx.description != null) ...[
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow('Détail', tx.description!),
                ],
                Divider(height: 1, indent: 16, color: context.colors.divider),
                _DetailRow('Date',
                    '${tx.date.day.toString().padLeft(2,'0')}/${tx.date.month.toString().padLeft(2,'0')}/${tx.date.year}'),
                Divider(height: 1, indent: 16, color: context.colors.divider),
                _DetailRow('Référence', '#${tx.id.padLeft(8, '0')}'),
              ]),
            ),
            AppGap.h20,
            Row(children: [
              Expanded(child: AppButton(
                  label: 'Reçu', variant: ButtonVariant.outline,
                  icon: Icons.receipt_rounded,
                  onPressed: () => Navigator.pop(context))),
              AppGap.w12,
              Expanded(child: AppButton(
                  label: 'Signaler', variant: ButtonVariant.outline,
                  icon: Icons.flag_rounded,
                  onPressed: () => Navigator.pop(context))),
            ]),
            AppGap.h12,
            AppButton(label: 'Fermer', variant: ButtonVariant.ghost,
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  // ─── Période picker ───────────────────────────────────────────
  void _showPeriodPicker() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: context.colors.border,
                    borderRadius: BorderRadius.circular(99))),
            AppGap.h20,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Période',
                  style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
            ),
            AppGap.h16,
            ..._periods.map((p) {
              final sel = p == _period;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () { setState(() => _period = p); Navigator.pop(context); },
                title: Text(p, style: context.text.bodyMedium?.copyWith(
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? context.colors.textPrimary
                               : context.colors.textSecondary)),
                trailing: sel
                    ? Icon(Icons.check_rounded, size: 18,
                        color: context.colors.textPrimary)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Export ───────────────────────────────────────────────────
  void _showExport() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: context.colors.border,
                    borderRadius: BorderRadius.circular(99))),
            AppGap.h20,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Exporter',
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            AppGap.h16,
            for (final opt in [
              (Icons.picture_as_pdf_rounded, 'PDF', 'Document formaté'),
              (Icons.table_chart_rounded, 'Excel (CSV)', 'Tableur pour analyse'),
              (Icons.email_rounded, 'Email', 'Recevoir par email'),
            ]) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(opt.$1, size: 18,
                      color: context.colors.textSecondary),
                ),
                title: Text(opt.$2,
                    style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600)),
                subtitle: Text(opt.$3,
                    style: context.text.bodySmall?.copyWith(
                        color: context.colors.textTertiary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: context.colors.textHint),
                onTap: () => Navigator.pop(context),
              ),
              if (opt.$2 != 'Email')
                Divider(height: 1, color: context.colors.divider),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────
  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(d.year, d.month, d.day);
    if (day == today) return "Aujourd'hui";
    if (day == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(d).inDays < 7) {
      const j = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
      return j[d.weekday - 1];
    }
    const m = ['janv.','févr.','mars','avr.','mai','juin',
                'juil.','août','sept.','oct.','nov.','déc.'];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// ─── Tuile résumé ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final bool positive;
  final bool highlight;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.positive,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final amtColor = highlight
        ? AppColors.warning
        : positive
            ? AppColors.primary
            : context.colors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: context.text.labelSmall?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w500)),
          AppGap.h6,
          Text(
            '${positive ? '+' : '−'}${amount.toStringAsFixed(0)} €',
            style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700, color: amtColor),
          ),
        ],
      ),
    );
  }
}

// ─── Ligne détail ─────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: context.text.bodySmall?.copyWith(
                  color: context.colors.textTertiary)),
          Flexible(
            child: Text(value,
                style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
