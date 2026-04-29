import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/transaction.dart';
import '../../widgets/shared/payment_common_widgets.dart';
import '../../widgets/shared/user_common_widgets.dart';

class FreelancerFinanceActivityTab extends StatefulWidget {
  const FreelancerFinanceActivityTab({super.key});

  @override
  State<FreelancerFinanceActivityTab> createState() =>
      _FreelancerFinanceActivityTabState();
}

class _FreelancerFinanceActivityTabState
    extends State<FreelancerFinanceActivityTab> {
  String _filter = 'Tout';
  String _period = 'Ce mois';

  final _filters = ['Tout', 'Revenus', 'Retraits', 'Frais'];
  final _periods = ['Cette semaine', 'Ce mois', '3 mois', 'Cette année', 'Tout'];

  final List<Transaction> _txs = [
    Transaction(
      id: '1',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 85.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      missionTitle: 'Ménage appartement',
      clientName: 'Marie D.',
    ),
    Transaction(
      id: '2',
      type: TransactionType.held,
      status: TransactionStatus.awaitingRelease,
      amount: 100.00,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      missionTitle: 'Création logo',
      clientName: 'Julien M.',
    ),
    Transaction(
      id: '3',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 8.50,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Commission Inkern 10%',
    ),
    Transaction(
      id: '4',
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      amount: 150.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Vers IBAN ···1234',
    ),
    Transaction(
      id: '5',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 120.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      missionTitle: 'Jardinage',
      clientName: 'Pierre M.',
    ),
    Transaction(
      id: '6',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 12.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Commission Inkern 10%',
    ),
    Transaction(
      id: '7',
      type: TransactionType.bonus,
      status: TransactionStatus.completed,
      amount: 20.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Bonus parrainage',
    ),
    Transaction(
      id: '8',
      type: TransactionType.income,
      status: TransactionStatus.completed,
      amount: 65.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      missionTitle: 'Montage meuble',
      clientName: 'Sophie B.',
    ),
    Transaction(
      id: '9',
      type: TransactionType.fee,
      status: TransactionStatus.completed,
      amount: 6.50,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Commission Inkern 10%',
    ),
    Transaction(
      id: '10',
      type: TransactionType.withdrawal,
      status: TransactionStatus.completed,
      amount: 200.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Vers IBAN ···1234',
    ),
  ];

  List<Transaction> get _filtered => _txs.where((tx) {
        return switch (_filter) {
          'Revenus' =>
            tx.type == TransactionType.income ||
                tx.type == TransactionType.bonus ||
                tx.type == TransactionType.refund ||
                tx.type == TransactionType.held,
          'Retraits' => tx.type == TransactionType.withdrawal,
          'Frais' => tx.type == TransactionType.fee,
          _ => true,
        };
      }).toList();

  double get _totalRevenu => _txs
      .where(
        (tx) =>
            tx.type == TransactionType.income &&
            tx.status == TransactionStatus.completed,
      )
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get _totalEnAttente => _txs
      .where((tx) => tx.type == TransactionType.held)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get _totalRetrait => _txs
      .where(
        (tx) =>
            tx.type == TransactionType.withdrawal &&
            tx.status == TransactionStatus.completed,
      )
      .fold(0.0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Transaction>>{};
    for (final tx in _filtered) {
      grouped.putIfAbsent(_dateLabel(tx.date), () => []).add(tx);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              children: [
                const _BalanceCard(),
                AppGap.h12,
                _RetirerBtn(onTap: () => _showWithdrawSheet(context)),
                AppGap.h24,
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FiltersHeader(
            summary: _SummaryStrip(
              totalRevenu: _totalRevenu,
              totalEnAttente: _totalEnAttente,
              totalRetrait: _totalRetrait,
            ),
            period: _period,
            filters: _filters,
            selected: _filter,
            onFilterChanged: (value) => setState(() => _filter = value),
            onPeriodTap: _showPeriodPicker,
          ),
        ),
        if (_filtered.isEmpty)
          SliverFillRemaining(child: _buildEmpty(context))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final key = grouped.keys.elementAt(index);
                  final list = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 8,
                          top: index == 0 ? 0 : 20,
                        ),
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
                          children: List.generate(
                            list.length,
                            (itemIndex) => Column(
                              children: [
                                _TxTile(
                                  tx: list[itemIndex],
                                  onTap: () =>
                                      _showDetail(context, list[itemIndex]),
                                ),
                                if (itemIndex < list.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 68,
                                    color: context.colors.divider,
                                  ),
                              ],
                            ),
                          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 26,
              color: context.colors.textHint,
            ),
          ),
          AppGap.h14,
          Text(
            'Aucune transaction',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
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
      child: const _WithdrawSheet(),
    );
  }

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
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AppGap.h20,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Période',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AppGap.h12,
            ..._periods.map(
              (period) => Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() => _period = period);
                      Navigator.pop(context);
                    },
                    title: Text(
                      period,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: period == _period
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: period == _period
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
                    ),
                    trailing: period == _period
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: context.colors.textPrimary,
                          )
                        : null,
                  ),
                  if (period != _periods.last)
                    Divider(height: 1, color: context.colors.divider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Transaction tx) {
    final isPositive = tx.type.isPositive;
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
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AppGap.h24,
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                tx.type.icon,
                size: 22,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h14,
            Text(
              '${isPositive ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
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
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h8,
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
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: [
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
                  _DetailRow(
                    'Date',
                    '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                  ),
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow('Référence', '#${tx.id.padLeft(8, '0')}'),
                ],
              ),
            ),
            AppGap.h20,
            Row(
              children: [
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
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return "Aujourd'hui";
    if (day == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(date).inDays < 7) {
      const days = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];
      return days[date.weekday - 1];
    }
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ink, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
              ),
              AppGap.w10,
              const Text(
                'Solde disponible',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppGap.h14,
          const Text(
            '145,50 €',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          AppGap.h18,
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          AppGap.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lock_clock_rounded,
                    size: 14,
                    color: Colors.white38,
                  ),
                  AppGap.w6,
                  const Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text(
                '100,00 €',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
                    AppGap.w4,
                    const Text(
                      'Versement dans 18h',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RetirerBtn extends StatelessWidget {
  final VoidCallback onTap;

  const _RetirerBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_upward_rounded,
              size: 17,
              color: context.colors.textSecondary,
            ),
            AppGap.w8,
            Text(
              'Retirer des fonds',
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersHeader extends SliverPersistentHeaderDelegate {
  final Widget summary;
  final String period;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onPeriodTap;

  const _FiltersHeader({
    required this.summary,
    required this.period,
    required this.filters,
    required this.selected,
    required this.onFilterChanged,
    required this.onPeriodTap,
  });

  static const double _height = 172;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(_FiltersHeader oldDelegate) {
    return oldDelegate.period != period || oldDelegate.selected != selected;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: context.colors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                summary,
                AppGap.h10,
                GestureDetector(
                  onTap: onPeriodTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: context.colors.textTertiary,
                        ),
                        AppGap.w8,
                        Text(
                          period,
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 16,
                          color: context.colors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PaymentFilterPills(
            filters: filters,
            selected: selected,
            onChanged: onFilterChanged,
          ),
          Divider(height: 1, color: context.colors.divider),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Cell(
              'Revenus',
              '+${totalRevenu.toStringAsFixed(0)} €',
              context.colors.textPrimary,
              context,
            ),
            VerticalDivider(width: 1, color: context.colors.divider),
            _Cell(
              'En attente',
              '${totalEnAttente.toStringAsFixed(0)} €',
              context.colors.textSecondary,
              context,
            ),
            VerticalDivider(width: 1, color: context.colors.divider),
            _Cell(
              'Retraits',
              '−${totalRetrait.toStringAsFixed(0)} €',
              context.colors.textSecondary,
              context,
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final BuildContext ctx;

  const _Cell(this.label, this.value, this.valueColor, this.ctx);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ctx.text.labelSmall?.copyWith(
                color: ctx.colors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppGap.h4,
            Text(
              value,
              style: ctx.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;

  const _TxTile({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.type.isPositive;
    final isHeld = tx.type == TransactionType.held;
    final pipelineStage = _pipelineStage(tx);
    final heldBadgeLabel = switch (pipelineStage) {
      PaymentMissionPipelineStage.secured => 'Fonds securises',
      PaymentMissionPipelineStage.waiting24h => 'Sous 24h',
      PaymentMissionPipelineStage.dispute => 'Litige',
      _ => 'Sous 24h',
    };
    final heldBadgeColor = switch (pipelineStage) {
      PaymentMissionPipelineStage.secured => context.colors.primary,
      PaymentMissionPipelineStage.dispute => context.colors.error,
      _ => context.colors.textTertiary,
    };
    final pipelineCaption = switch (pipelineStage) {
      PaymentMissionPipelineStage.secured =>
        'Fonds securises pour la mission',
      PaymentMissionPipelineStage.waiting24h =>
        'Versement automatique sous 24h',
      PaymentMissionPipelineStage.paid => 'Versement recu pour la mission',
      PaymentMissionPipelineStage.dispute =>
        'Litige en cours, versement suspendu',
      _ => null,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Icon(
                    tx.type.icon,
                    size: 17,
                    color: context.colors.textSecondary,
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.missionTitle ?? tx.type.label,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((tx.clientName ?? tx.description) != null) ...[
                        AppGap.h2,
                        Text(
                          tx.clientName ?? tx.description!,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                AppGap.w12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isHeld
                            ? context.colors.textSecondary
                            : isPositive
                                ? context.colors.textPrimary
                                : context.colors.textSecondary,
                      ),
                    ),
                    if (isHeld) ...[
                      AppGap.h3,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Text(
                          heldBadgeLabel,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 10,
                            color: heldBadgeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ] else if (tx.status != TransactionStatus.completed) ...[
                      AppGap.h3,
                      Text(
                        tx.status.label,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (pipelineStage != null) ...[
              AppGap.h10,
              PaymentMissionPipelineInline(
                stage: pipelineStage,
                caption: pipelineCaption,
              ),
            ],
          ],
        ),
      ),
    );
  }

  PaymentMissionPipelineStage? _pipelineStage(Transaction tx) {
    if (tx.status == TransactionStatus.inDispute) {
      return PaymentMissionPipelineStage.dispute;
    }

    final isMissionTransaction =
        tx.missionTitle != null ||
        tx.type == TransactionType.held ||
        tx.type == TransactionType.released ||
        tx.type == TransactionType.income;
    if (!isMissionTransaction) return null;

    if (tx.type == TransactionType.held || tx.status == TransactionStatus.held) {
      if (tx.status == TransactionStatus.awaitingRelease ||
          tx.status == TransactionStatus.pending) {
        return PaymentMissionPipelineStage.waiting24h;
      }
      return PaymentMissionPipelineStage.secured;
    }

    if (tx.status == TransactionStatus.awaitingRelease ||
        tx.status == TransactionStatus.pending) {
      return PaymentMissionPipelineStage.waiting24h;
    }

    if (tx.type == TransactionType.income ||
        tx.type == TransactionType.released) {
      return PaymentMissionPipelineStage.paid;
    }

    return null;
  }
}

class _WithdrawSheet extends StatelessWidget {
  const _WithdrawSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppFormSheet(
        title: 'Retirer des fonds',
        footer: AppButton(
          label: 'Confirmer le retrait',
          variant: ButtonVariant.black,
          onPressed: () => Navigator.pop(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solde disponible : 145,50 €',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            AppGap.h20,
            TextField(
              keyboardType: TextInputType.number,
              decoration: AppInputDecorations.formField(
                context,
                hintText: 'Ex: 100',
              ).copyWith(labelText: 'Montant à retirer', suffixText: '€'),
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppGap.h12,
            Row(
              children: [
                for (final value in ['50 €', '100 €', '145 €']) ...[
                  AppPillChip(
                    label: value,
                    onTap: () {},
                    padding: AppInsets.h12v8,
                  ),
                  AppGap.w8,
                ],
              ],
            ),
            AppGap.h16,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IBAN SEPA',
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          'FR76 •••• 1234',
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
