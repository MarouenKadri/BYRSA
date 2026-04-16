import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/shared/payment_common_widgets.dart';

/// ─────────────────────────────────────────────────────────────
/// Historique des paiements — Client  (minimaliste)
/// ─────────────────────────────────────────────────────────────
class ClientPaymentHistoryPage extends StatefulWidget {
  final bool embedded;
  const ClientPaymentHistoryPage({super.key, this.embedded = false});

  @override
  State<ClientPaymentHistoryPage> createState() =>
      _ClientPaymentHistoryPageState();
}

class _ClientPaymentHistoryPageState
    extends State<ClientPaymentHistoryPage> {
  String _filter = 'Tout';
  final _filters = ['Tout', 'Paiements', 'Remboursements', 'En attente'];

  final List<_Tx> _txs = [
    _Tx(type: _T.payment, title: 'Ménage appartement',       sub: 'Thomas R.',   amount: 55.00,
        date: DateTime.now().subtract(const Duration(hours: 2)),  pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Jardinage — Paris 11e',    sub: 'Julie M.',    amount: 40.00,
        date: DateTime.now().subtract(const Duration(days: 1)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.refund,  title: 'Remboursement annulation', sub: 'Marc D.',     amount: 35.00,
        date: DateTime.now().subtract(const Duration(days: 2)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Repassage 2h',             sub: 'Sarah L.',    amount: 50.00,
        date: DateTime.now().subtract(const Duration(days: 4)),   pending: false, card: 'Mastercard ···8888'),
    _Tx(type: _T.payment, title: 'Montage meuble',           sub: 'Antoine B.',  amount: 80.00,
        date: DateTime.now().subtract(const Duration(days: 7)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Ménage bureau',            sub: 'Thomas R.',   amount: 65.00,
        date: DateTime.now().subtract(const Duration(days: 10)),  pending: true,  card: 'Visa ···4242'),
    _Tx(type: _T.refund,  title: 'Remboursement litige',     sub: 'Inkern',      amount: 25.00,
        date: DateTime.now().subtract(const Duration(days: 14)),  pending: false, card: 'Mastercard ···8888'),
  ];

  // ─── Computed ────────────────────────────────────────────────
  List<_Tx> get _filtered {
    return switch (_filter) {
      'Paiements'     => _txs.where((t) => t.type == _T.payment && !t.pending).toList(),
      'Remboursements'=> _txs.where((t) => t.type == _T.refund).toList(),
      'En attente'    => _txs.where((t) => t.pending).toList(),
      _               => _txs,
    };
  }

  double get _totalPaid => _txs
      .where((t) => t.type == _T.payment && !t.pending)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalRefunded => _txs
      .where((t) => t.type == _T.refund && !t.pending)
      .fold(0.0, (s, t) => s + t.amount);

  static const _months = ['janvier','février','mars','avril','mai','juin',
      'juillet','août','septembre','octobre','novembre','décembre'];

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildHeader(context),
        Expanded(child: _filtered.isEmpty ? _buildEmpty(context) : _buildList(context)),
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
            onPressed: () {},
          ),
        ],
      ),
      body: body,
    );
  }

  // ─── Header : résumé + filtres ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte résumé mois (sobre, foncée) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_months[now.month - 1]} ${now.year}',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppGap.h6,
                        Text(
                          '${_totalPaid.toStringAsFixed(0)} €',
                          style: context.text.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        AppGap.h2,
                        Text(
                          'Dépensé ce mois',
                          style: context.text.bodySmall?.copyWith(
                              color: context.colors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatChip(
                        label: '− ${_totalPaid.toStringAsFixed(0)} €',
                        sub: 'payé',
                        color: context.colors.textPrimary,
                      ),
                      AppGap.h8,
                      _StatChip(
                        label: '+ ${_totalRefunded.toStringAsFixed(0)} €',
                        sub: 'remboursé',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
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
    final grouped = <String, List<_Tx>>{};
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
              child: Text(
                key,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                      Divider(height: 1, indent: 70, color: context.colors.divider),
                  ],
                )),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, _Tx tx) {
    final isRefund = tx.type == _T.refund;
    final icon = isRefund
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final amount = '${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €';

    String badge;
    Color? badgeColor;
    if (tx.pending) {
      badge = '24h restantes';
      badgeColor = AppColors.warning;
    } else if (isRefund) {
      badge = 'Remboursé';
      badgeColor = AppColors.primary;
    } else {
      badge = tx.card;
      badgeColor = context.colors.textTertiary;
    }

    return PaymentTxTile(
      icon: icon,
      title: tx.title,
      subtitle: tx.sub,
      amount: amount,
      isPositive: isRefund,
      badge: badge,
      badgeColor: badgeColor,
      onTap: () => _showDetail(context, tx),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded, size: 36,
              color: context.colors.textHint),
          AppGap.h12,
          Text('Aucune transaction',
              style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textTertiary)),
        ],
      ),
    );
  }

  // ─── Sheet détail ─────────────────────────────────────────────
  void _showDetail(BuildContext context, _Tx tx) {
    final isRefund = tx.type == _T.refund;
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AppGap.h24,
            // Montant
            Text(
              '${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isRefund ? AppColors.primary : context.colors.textPrimary,
              ),
            ),
            AppGap.h4,
            Text(
              tx.title,
              style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary),
            ),
            AppGap.h6,
            _StatusPill(pending: tx.pending, isRefund: isRefund),
            AppGap.h24,
            // Détails
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(children: [
                _DetailRow('Prestataire', tx.sub),
                Divider(height: 1, indent: 16, color: context.colors.divider),
                _DetailRow('Carte', tx.card),
                Divider(height: 1, indent: 16, color: context.colors.divider),
                _DetailRow('Date', _fullDate(tx.date)),
                Divider(height: 1, indent: 16, color: context.colors.divider),
                _DetailRow('Référence', '#${tx.date.millisecondsSinceEpoch.toString().substring(7)}'),
              ]),
            ),
            AppGap.h20,
            Row(children: [
              Expanded(
                child: AppButton(
                  label: 'Reçu',
                  variant: ButtonVariant.outline,
                  icon: Icons.receipt_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: AppButton(
                  label: 'Signaler',
                  variant: ButtonVariant.outline,
                  icon: Icons.flag_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ]),
            AppGap.h12,
            AppButton(
              label: 'Fermer',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────
  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return "Aujourd'hui";
    if (day == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(d).inDays < 7) {
      const j = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return j[d.weekday - 1];
    }
    const m = ['janv.','févr.','mars','avr.','mai','juin',
                'juil.','août','sept.','oct.','nov.','déc.'];
    return '${d.day} ${m[d.month - 1]}';
  }

  String _fullDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}'
      ' à ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}

// ─── Modèles locaux ───────────────────────────────────────────────────────────

enum _T { payment, refund }

class _Tx {
  final _T type;
  final String title, sub, card;
  final double amount;
  final DateTime date;
  final bool pending;
  const _Tx({required this.type, required this.title, required this.sub,
      required this.card, required this.amount, required this.date,
      required this.pending});
}

// ─── Widgets locaux ───────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, sub;
  final Color color;
  const _StatChip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700, color: color)),
        Text(sub,
            style: context.text.labelSmall?.copyWith(
                color: context.colors.textTertiary)),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool pending, isRefund;
  const _StatusPill({required this.pending, required this.isRefund});

  @override
  Widget build(BuildContext context) {
    final label = pending ? 'En attente (24h)' : isRefund ? 'Remboursé' : 'Payé';
    final color = pending
        ? AppColors.warning
        : isRefund
            ? AppColors.primary
            : context.colors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600, color: color)),
    );
  }
}

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
