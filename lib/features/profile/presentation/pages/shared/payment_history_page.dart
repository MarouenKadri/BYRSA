import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/transaction.dart';
import '../../widgets/shared/payment_common_widgets.dart';

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
      .where((t) => t.type == TransactionType.income && t.status == TransactionStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalEnAttente => _txs
      .where((t) => t.type == TransactionType.held)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalRetrait => _txs
      .where((t) => t.type == TransactionType.withdrawal && t.status == TransactionStatus.completed)
      .fold(0.0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _filtered.isEmpty ? _buildEmpty(context) : _buildList(context),
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
            icon: Icon(Icons.download_rounded, color: context.colors.textPrimary, size: 20),
            onPressed: _showExport,
          ),
        ],
      ),
      body: body,
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: context.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Résumé compact ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: _SummaryStrip(
              totalRevenu: _totalRevenu,
              totalEnAttente: _totalEnAttente,
              totalRetrait: _totalRetrait,
            ),
          ),
          // ── Période + export ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showPeriodPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded, size: 14,
                            color: context.colors.textTertiary),
                        AppGap.w8,
                        Text(_period,
                            style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.colors.textSecondary)),
                        const Spacer(),
                        Icon(Icons.expand_more_rounded, size: 16,
                            color: context.colors.textTertiary),
                      ]),
                    ),
                  ),
                ),
                if (!widget.embedded) ...[
                  AppGap.w10,
                  GestureDetector(
                    onTap: _showExport,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Icon(Icons.download_rounded, size: 16,
                          color: context.colors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Filtres ──
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PaymentFilterPills(
              filters: _filters,
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
        ],
      ),
    );
  }

  // ─── Liste groupée ────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    final grouped = <String, List<Transaction>>{};
    for (final t in _filtered) {
      grouped.putIfAbsent(_dateLabel(t.date), () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final key = grouped.keys.elementAt(i);
        final list = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8, top: i == 0 ? 0 : 20),
              child: Text(
                key,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: List.generate(list.length, (j) => Column(
                  children: [
                    _TxTile(
                      tx: list[j],
                      onTap: () => _showDetail(context, list[j]),
                    ),
                    if (j < list.length - 1)
                      Divider(height: 1, indent: 64, endIndent: 0, color: context.colors.divider),
                  ],
                )),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: context.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.border),
          ),
          child: Icon(Icons.receipt_long_rounded, size: 26, color: context.colors.textHint),
        ),
        AppGap.h14,
        Text('Aucune transaction',
            style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
        AppGap.h4,
        Text('Rien à afficher pour cette période',
            style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
      ]),
    );
  }

  // ─── Sheet détail ─────────────────────────────────────────────────────────

  void _showDetail(BuildContext context, Transaction tx) {
    final isPos = tx.type.isPositive;
    final isHeld = tx.type == TransactionType.held;
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
            // ── Handle ──
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AppGap.h24,
            // ── Icône ──
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(tx.type.icon, size: 22, color: context.colors.textSecondary),
            ),
            AppGap.h14,
            // ── Montant ──
            Text(
              '${isPos ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isHeld
                    ? context.colors.textSecondary
                    : context.colors.textPrimary,
              ),
            ),
            AppGap.h4,
            Text(
              tx.missionTitle ?? tx.type.label,
              style: context.text.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
            AppGap.h8,
            // ── Statut badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: context.colors.border),
              ),
              child: Text(
                tx.status.label,
                style: context.text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            AppGap.h24,
            // ── Détails ──
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
            AppButton(
                label: 'Fermer',
                variant: ButtonVariant.ghost,
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  // ─── Période picker ───────────────────────────────────────────────────────

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
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            AppGap.h12,
            ..._periods.map((p) {
              final sel = p == _period;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onTap: () { setState(() => _period = p); Navigator.pop(context); },
                    title: Text(p, style: context.text.bodyMedium?.copyWith(
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? context.colors.textPrimary : context.colors.textSecondary)),
                    trailing: sel
                        ? Icon(Icons.check_rounded, size: 18, color: context.colors.textPrimary)
                        : null,
                  ),
                  if (p != _periods.last)
                    Divider(height: 1, color: context.colors.divider),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Export ───────────────────────────────────────────────────────────────

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
              child: Text('Exporter l\'historique',
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            AppGap.h4,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Période : $_period',
                  style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
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
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Icon(opt.$1, size: 17, color: context.colors.textSecondary),
                ),
                title: Text(opt.$2, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(opt.$3, style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.colors.textHint),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return "Aujourd'hui";
    if (day == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(d).inDays < 7) {
      const j = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
      return j[d.weekday - 1];
    }
    const m = ['janv.','févr.','mars','avr.','mai','juin','juil.','août','sept.','oct.','nov.','déc.'];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// ─── Strip résumé (bande horizontale) ────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final double totalRevenu;
  final double totalEnAttente;
  final double totalRetrait;

  const _SummaryStrip({
    required this.totalRevenu,
    required this.totalEnAttente,
    required this.totalRetrait,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(label: 'Revenus', value: '+${totalRevenu.toStringAsFixed(0)} €',
                valueColor: context.colors.textPrimary),
            VerticalDivider(width: 1, color: context.colors.divider),
            _StatCell(label: 'En attente', value: '${totalEnAttente.toStringAsFixed(0)} €',
                valueColor: context.colors.textSecondary),
            VerticalDivider(width: 1, color: context.colors.divider),
            _StatCell(label: 'Retraits', value: '−${totalRetrait.toStringAsFixed(0)} €',
                valueColor: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCell({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary, fontWeight: FontWeight.w500)),
            AppGap.h5,
            Text(value,
                style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: valueColor)),
          ],
        ),
      ),
    );
  }
}

// ─── Tile transaction (redesign minimaliste) ──────────────────────────────────

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;

  const _TxTile({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPos = tx.type.isPositive;
    final isHeld = tx.type == TransactionType.held;
    final amountStr = '${isPos ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €';
    final title = tx.missionTitle ?? tx.type.label;
    final subtitle = tx.clientName ?? tx.description ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // ─── Icône ───
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(tx.type.icon, size: 17, color: context.colors.textSecondary),
            ),
            AppGap.w12,
            // ─── Texte ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle.isNotEmpty) ...[
                    AppGap.h2,
                    Text(subtitle,
                        style: context.text.bodySmall?.copyWith(
                            color: context.colors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            AppGap.w12,
            // ─── Montant + statut ───
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountStr,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isHeld
                        ? context.colors.textSecondary
                        : isPos
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                  ),
                ),
                if (isHeld) ...[
                  AppGap.h3,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Text('Sous 24h',
                        style: context.text.labelSmall?.copyWith(
                            fontSize: 10,
                            color: context.colors.textTertiary,
                            fontWeight: FontWeight.w500)),
                  ),
                ] else if (tx.status != TransactionStatus.completed) ...[
                  AppGap.h3,
                  Text(tx.status.label,
                      style: context.text.labelSmall?.copyWith(
                          color: context.colors.textTertiary,
                          fontWeight: FontWeight.w400)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ligne de détail ─────────────────────────────────────────────────────────

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
              style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
          Flexible(
            child: Text(value,
                style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
