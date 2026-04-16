import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

/// Portefeuille Freelancer — solde, actions, transactions uniquement.
/// Les moyens de paiement (IBAN) sont gérés dans l'onglet "Moyens".
class WalletPage extends StatelessWidget {
  final bool embedded;
  const WalletPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        _BalanceCard(),
        AppGap.h16,
        _QuickActions(embedded: embedded),
        AppGap.h28,
        _PendingSection(),
        AppGap.h24,
        _RecentSection(),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Portefeuille', style: context.profilePageTitleStyle),
      ),
      body: body,
    );
  }
}

// ─── Carte solde (dark premium) ───────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111111), Color(0xFF242424)],
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
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Colors.white70),
            ),
            AppGap.w10,
            const Text('Solde disponible',
                style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500)),
          ]),
          AppGap.h14,
          const Text('145,50 €',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
          AppGap.h18,
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          AppGap.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.lock_clock_rounded, size: 14, color: Colors.white38),
                AppGap.w6,
                const Text('En attente',
                    style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500)),
              ]),
              const Text('100,00 €',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          AppGap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.schedule_rounded, size: 12, color: Colors.white38),
                  AppGap.w4,
                  const Text('Versement dans 18h',
                      style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Actions rapides ──────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final bool embedded;
  const _QuickActions({required this.embedded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionBtn(
          icon: Icons.arrow_upward_rounded,
          label: 'Retirer',
          onTap: () => _showWithdrawSheet(context),
        )),
        AppGap.w12,
        Expanded(child: _ActionBtn(
          icon: Icons.history_rounded,
          label: 'Historique',
          onTap: () {},
        )),
      ],
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _WithdrawSheet(),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: context.colors.textSecondary),
          AppGap.h6,
          Text(label, style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Paiements en attente ─────────────────────────────────────────────────────

class _PendingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _Pending('Création logo',       'Julien M.', '100,00 €', 14),
      _Pending('Réparation plomberie','Pierre D.',  '65,00 €',   6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('EN ATTENTE'),
        AppGap.h10,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: List.generate(items.length, (i) => Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Icon(Icons.lock_clock_rounded, size: 18, color: context.colors.textSecondary),
                  ),
                  AppGap.w12,
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].mission,
                          style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                      AppGap.h2,
                      Text('De ${items[i].client} · versement dans ${items[i].hoursLeft}h',
                          style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('+${items[i].amount}',
                        style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                    AppGap.h2,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Text('Sous ${items[i].hoursLeft}h',
                          style: context.text.labelSmall?.copyWith(
                              fontSize: 10, color: context.colors.textTertiary, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                ]),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 68, color: context.colors.divider),
            ])),
          ),
        ),
      ],
    );
  }
}

// ─── Transactions récentes ────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _Tx(Icons.arrow_downward_rounded, 'Ménage appartement', 'Marie D.',     '+55,00 €', "Aujourd'hui", true),
      _Tx(Icons.receipt_long_rounded,   'Commission Inkern',  '10%',          '−5,50 €',  "Aujourd'hui", false),
      _Tx(Icons.arrow_upward_rounded,   'Retrait IBAN',       '···1234',      '−100,00 €','Hier',         false),
      _Tx(Icons.arrow_downward_rounded, 'Jardinage',          'Pierre M.',    '+120,00 €','Mer',          true),
      _Tx(Icons.receipt_long_rounded,   'Commission Inkern',  '10%',          '−12,00 €', 'Mer',         false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('RÉCENT'),
        AppGap.h10,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: List.generate(items.length, (i) => Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Icon(items[i].icon, size: 17, color: context.colors.textSecondary),
                  ),
                  AppGap.w12,
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].title,
                          style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      AppGap.h2,
                      Text(items[i].sub,
                          style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(items[i].amount,
                        style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: items[i].isPos
                                ? context.colors.textPrimary
                                : context.colors.textSecondary)),
                    AppGap.h2,
                    Text(items[i].date,
                        style: context.text.labelSmall?.copyWith(color: context.colors.textTertiary)),
                  ]),
                ]),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 68, color: context.colors.divider),
            ])),
          ),
        ),
      ],
    );
  }
}

// ─── Sheet retrait ────────────────────────────────────────────────────────────

class _WithdrawSheet extends StatelessWidget {
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
            Text('Solde disponible : 145,50 €',
                style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
            AppGap.h20,
            TextField(
              keyboardType: TextInputType.number,
              decoration: AppInputDecorations.formField(context, hintText: 'Ex: 100').copyWith(
                labelText: 'Montant à retirer',
                suffixText: '€',
              ),
              style: context.text.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppGap.h12,
            Row(children: [
              for (final v in ['50 €', '100 €', '145 €']) ...[
                AppPillChip(label: v, onTap: () {}, padding: AppInsets.h12v8),
                AppGap.w8,
              ],
            ]),
            AppGap.h16,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(children: [
                Icon(Icons.account_balance_rounded, size: 18, color: context.colors.textSecondary),
                AppGap.w12,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('IBAN SEPA', style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                  Text('FR76 •••• 1234', style: context.text.labelSmall?.copyWith(
                      color: context.colors.textTertiary)),
                ])),
                Icon(Icons.check_rounded, size: 16, color: context.colors.textSecondary),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: context.text.labelSmall?.copyWith(
          color: context.colors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7));
}

class _Pending {
  final String mission, client, amount;
  final int hoursLeft;
  const _Pending(this.mission, this.client, this.amount, this.hoursLeft);
}

class _Tx {
  final IconData icon;
  final String title, sub, amount, date;
  final bool isPos;
  const _Tx(this.icon, this.title, this.sub, this.amount, this.date, this.isPos);
}
