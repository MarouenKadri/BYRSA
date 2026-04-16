import 'package:flutter/material.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/shared/user_common_widgets.dart';
import '../../widgets/shared/payment_common_widgets.dart';

class ClientPaymentMethodsPage extends StatefulWidget {
  const ClientPaymentMethodsPage({super.key});

  @override
  State<ClientPaymentMethodsPage> createState() => _ClientPaymentMethodsPageState();
}

class _ClientPaymentMethodsPageState extends State<ClientPaymentMethodsPage> {
  int _selectedTabIndex = 0;

  final List<_Card> _cards = [
    _Card(brand: 'Visa',       last4: '4242', expiry: '12/26', isDefault: true),
    _Card(brand: 'Mastercard', last4: '8888', expiry: '08/25', isDefault: false),
  ];

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(isDefault: i == index);
      }
    });
  }

  void _removeCard(int index) => setState(() => _cards.removeAt(index));

  void _showCardOptions(BuildContext context, int index) {
    final card = _cards[index];
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: '${card.brand} •••• ${card.last4}',
        children: [
          if (!card.isDefault)
            AppActionSheetItem(
              icon: Icons.star_outline_rounded,
              title: 'Définir par défaut',
              onTap: () { Navigator.pop(context); _setDefault(index); },
            ),
          if (!card.isDefault)
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
          AppActionSheetItem(
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer la carte',
            destructive: true,
            onTap: () {
              Navigator.pop(context);
              showAppBottomSheet(
                context: context,
                wrapWithSurface: false,
                child: PaymentDeleteConfirmSheet(
                  title: 'Supprimer la carte ?',
                  subtitle: '${card.brand} •••• ${card.last4} sera supprimée définitivement.',
                  onConfirm: () => _removeCard(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Finance', style: context.profilePageTitleStyle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (i) => setState(() => _selectedTabIndex = i),
            tabs: const [
              AppSegmentedTab(label: 'Moyens'),
              AppSegmentedTab(label: 'Activité'),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildMethodsContent(context),
                const _ClientActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        const PaymentSectionLabel('MES CARTES'),
        AppGap.h10,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              ..._cards.asMap().entries.expand((e) => [
                _CardRow(card: e.value, onTap: () => _showCardOptions(context, e.key)),
                if (e.key < _cards.length - 1)
                  Divider(height: 1, indent: 68, color: context.colors.divider),
              ]),
            ],
          ),
        ),
        AppGap.h10,
        PaymentAddButton(
          label: 'Ajouter une carte',
          onTap: () => _showAddCardSheet(context),
        ),
        AppGap.h16,
        PaymentInfoNote(
          icon: Icons.lock_outline_rounded,
          body: 'Chiffrement SSL · Inkern ne stocke jamais vos numéros de carte complets.',
        ),
      ],
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: const _AddCardSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Onglet Activité — crédit + historique fusionnés
// ═══════════════════════════════════════════════════════════════════════════════

class _ClientActivityTab extends StatefulWidget {
  const _ClientActivityTab();

  @override
  State<_ClientActivityTab> createState() => _ClientActivityTabState();
}

class _ClientActivityTabState extends State<_ClientActivityTab> {
  String _filter = 'Tout';
  final _filters = ['Tout', 'Paiements', 'Remboursements', 'En attente'];

  static const _months = ['janvier','février','mars','avril','mai','juin',
      'juillet','août','septembre','octobre','novembre','décembre'];

  final List<_Tx> _txs = [
    _Tx(type: _T.payment, title: 'Ménage appartement',    sub: 'Thomas R.',  amount: 55.00,
        date: DateTime.now().subtract(const Duration(hours: 2)),  pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Jardinage — Paris 11e', sub: 'Julie M.',   amount: 40.00,
        date: DateTime.now().subtract(const Duration(days: 1)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.refund,  title: 'Remboursement annulation', sub: 'Marc D.', amount: 35.00,
        date: DateTime.now().subtract(const Duration(days: 2)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Repassage 2h',          sub: 'Sarah L.',   amount: 50.00,
        date: DateTime.now().subtract(const Duration(days: 4)),   pending: false, card: 'Mastercard ···8888'),
    _Tx(type: _T.payment, title: 'Montage meuble',        sub: 'Antoine B.', amount: 80.00,
        date: DateTime.now().subtract(const Duration(days: 7)),   pending: false, card: 'Visa ···4242'),
    _Tx(type: _T.payment, title: 'Ménage bureau',         sub: 'Thomas R.',  amount: 65.00,
        date: DateTime.now().subtract(const Duration(days: 10)),  pending: true,  card: 'Visa ···4242'),
  ];

  List<_Tx> get _filtered => switch (_filter) {
    'Paiements'      => _txs.where((t) => t.type == _T.payment && !t.pending).toList(),
    'Remboursements' => _txs.where((t) => t.type == _T.refund).toList(),
    'En attente'     => _txs.where((t) => t.pending).toList(),
    _                => _txs,
  };

  double get _totalPaid => _txs
      .where((t) => t.type == _T.payment && !t.pending)
      .fold(0.0, (s, t) => s + t.amount);
  double get _totalRefunded => _txs
      .where((t) => t.type == _T.refund)
      .fold(0.0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final grouped = <String, List<_Tx>>{};
    for (final t in _filtered) {
      grouped.putIfAbsent(_dateLabel(t.date), () => []).add(t);
    }

    return CustomScrollView(
      slivers: [
        // ─── Résumé + filtres (sticky) ────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _ClientFiltersHeader(
            month: '${_months[now.month - 1]} ${now.year}',
            totalPaid: _totalPaid,
            totalRefunded: _totalRefunded,
            filters: _filters,
            selected: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
        ),

        // ─── Liste transactions ───────────────────────────────────────────────
        if (_filtered.isEmpty)
          SliverFillRemaining(child: _buildEmpty(context))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final key = grouped.keys.elementAt(i);
                  final list = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8, top: i == 0 ? 0 : 20),
                        child: Text(key,
                            style: ctx.text.labelSmall?.copyWith(
                                color: ctx.colors.textTertiary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ctx.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ctx.colors.border),
                        ),
                        child: Column(
                          children: List.generate(list.length, (j) => Column(children: [
                            _TxTile(tx: list[j], onTap: () => _showDetail(ctx, list[j])),
                            if (j < list.length - 1)
                              Divider(height: 1, indent: 68, color: ctx.colors.divider),
                          ])),
                        ),
                      ),
                    ],
                  );
                },
                childCount: grouped.length,
              ),
            ),
          ),
      ],
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
      ]),
    );
  }

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(99))),
          AppGap.h24,
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt, shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(isRefund ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 22, color: context.colors.textSecondary),
          ),
          AppGap.h14,
          Text('${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          AppGap.h4,
          Text(tx.title, style: context.text.bodyMedium?.copyWith(color: context.colors.textSecondary)),
          AppGap.h8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: context.colors.border),
            ),
            child: Text(tx.pending ? 'En attente (24h)' : isRefund ? 'Remboursé' : 'Payé',
                style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
          ),
          AppGap.h24,
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
            Expanded(child: AppButton(label: 'Reçu', variant: ButtonVariant.outline,
                icon: Icons.receipt_rounded, onPressed: () => Navigator.pop(context))),
            AppGap.w12,
            Expanded(child: AppButton(label: 'Signaler', variant: ButtonVariant.outline,
                icon: Icons.flag_rounded, onPressed: () => Navigator.pop(context))),
          ]),
          AppGap.h12,
          AppButton(label: 'Fermer', variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

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

  String _fullDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}'
      ' à ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}

// ─── Header sticky client (résumé mois + filtres) ─────────────────────────────

class _ClientFiltersHeader extends SliverPersistentHeaderDelegate {
  final String month;
  final double totalPaid, totalRefunded;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onFilterChanged;

  const _ClientFiltersHeader({
    required this.month,
    required this.totalPaid,
    required this.totalRefunded,
    required this.filters,
    required this.selected,
    required this.onFilterChanged,
  });

  static const double _h = 182;

  @override double get minExtent => _h;
  @override double get maxExtent => _h;
  @override bool shouldRebuild(_ClientFiltersHeader old) =>
      old.selected != selected || old.totalPaid != totalPaid;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colors.background,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(height: 1, color: context.colors.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(month, style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary, fontWeight: FontWeight.w500)),
                AppGap.h4,
                Text('${totalPaid.toStringAsFixed(0)} €',
                    style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                Text('Dépensé ce mois', style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('− ${totalPaid.toStringAsFixed(0)} €',
                    style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                Text('payé', style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary)),
                AppGap.h6,
                Text('+ ${totalRefunded.toStringAsFixed(0)} €',
                    style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
                Text('remboursé', style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary)),
              ]),
            ]),
          ),
        ),
        PaymentFilterPills(filters: filters, selected: selected, onChanged: onFilterChanged),
        Divider(height: 1, color: context.colors.divider),
      ]),
    );
  }
}

// ─── Tile transaction client ──────────────────────────────────────────────────

class _TxTile extends StatelessWidget {
  final _Tx tx;
  final VoidCallback onTap;
  const _TxTile({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRefund = tx.type == _T.refund;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              isRefund ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 17, color: context.colors.textSecondary),
          ),
          AppGap.w12,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.title,
                style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            AppGap.h2,
            Text(tx.sub, style: context.text.bodySmall?.copyWith(
                color: context.colors.textTertiary)),
          ])),
          AppGap.w12,
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
                style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tx.pending
                        ? context.colors.textSecondary
                        : context.colors.textPrimary)),
            AppGap.h2,
            if (tx.pending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.colors.border),
                ),
                child: Text('24h', style: context.text.labelSmall?.copyWith(
                    fontSize: 10, color: context.colors.textTertiary, fontWeight: FontWeight.w500)),
              )
            else
              Text(tx.card, style: context.text.labelSmall?.copyWith(
                  color: context.colors.textTertiary)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Ligne carte compacte ─────────────────────────────────────────────────────

class _CardRow extends StatelessWidget {
  final _Card card;
  final VoidCallback onTap;
  const _CardRow({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(Icons.credit_card_rounded, size: 18, color: context.colors.textSecondary),
          ),
          AppGap.w12,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${card.brand} •••• ${card.last4}',
                  style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
              if (card.isDefault) ...[
                AppGap.w8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text('Défaut', style: context.text.labelSmall?.copyWith(
                      fontSize: 10, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            AppGap.h2,
            Text('Expire ${card.expiry}',
                style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
          ])),
          Icon(Icons.more_horiz_rounded, size: 18, color: context.colors.textSecondary),
        ]),
      ),
    );
  }
}

// ─── Sheet ajouter une carte ──────────────────────────────────────────────────

class _AddCardSheet extends StatelessWidget {
  const _AddCardSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppFormSheet(
        title: 'Ajouter une carte',
        footer: Column(children: [
          ProfileSheetPrimaryAction(
            label: 'Ajouter la carte',
            onPressed: () => Navigator.pop(context),
          ),
          AppGap.h12,
          Center(child: ProfileSheetSecondaryAction(
            label: 'Annuler', onTap: () => Navigator.pop(context))),
        ]),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          PaymentShadowField(child: TextFormField(
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
            decoration: AppInputDecorations.profileField(context,
              hintText: 'Numéro de carte',
              prefixIcon: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFFB0BAC4))),
          )),
          AppGap.h16,
          Row(children: [
            Expanded(child: PaymentShadowField(child: TextFormField(
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context, hintText: 'MM/AA'),
            ))),
            AppGap.w12,
            Expanded(child: PaymentShadowField(child: TextFormField(
              keyboardType: TextInputType.number,
              obscureText: true,
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context, hintText: 'CVV'),
            ))),
          ]),
          AppGap.h16,
          PaymentShadowField(child: TextFormField(
            style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
            decoration: AppInputDecorations.profileField(context,
              hintText: 'Titulaire de la carte',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFB0BAC4))),
          )),
        ]),
      ),
    );
  }
}

// ─── Modèles ──────────────────────────────────────────────────────────────────

enum _T { payment, refund }

class _Tx {
  final _T type;
  final String title, sub, card;
  final double amount;
  final DateTime date;
  final bool pending;
  const _Tx({required this.type, required this.title, required this.sub,
      required this.card, required this.amount, required this.date, required this.pending});
}

class _Card {
  final String brand, last4, expiry;
  final bool isDefault;
  const _Card({required this.brand, required this.last4, required this.expiry, required this.isDefault});
  _Card copyWith({bool? isDefault}) =>
      _Card(brand: brand, last4: last4, expiry: expiry, isDefault: isDefault ?? this.isDefault);
}

// ─── Ligne détail sheet ───────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
        Flexible(child: Text(value,
            style: context.text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600, color: context.colors.textPrimary),
            textAlign: TextAlign.right)),
      ]),
    );
  }
}
