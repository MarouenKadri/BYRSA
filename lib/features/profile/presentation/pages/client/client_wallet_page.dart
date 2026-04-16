import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import 'client_payment_history_page.dart';

/// Portefeuille Client — crédit disponible, paiements en cours, historique récent.
/// Les cartes bancaires sont gérées dans l'onglet "Moyens".
class ClientWalletPage extends StatelessWidget {
  final bool embedded;
  const ClientWalletPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        _CreditCard(),
        AppGap.h16,
        _AddFundsBtn(),
        AppGap.h28,
        _PendingSection(),
        AppGap.h24,
        _RecentSection(embedded: embedded),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Portefeuille', style: context.profilePageTitleStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: context.colors.textPrimary, size: 20),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ClientPaymentHistoryPage())),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ─── Carte crédit disponible (dark) ──────────────────────────────────────────

class _CreditCard extends StatelessWidget {
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
              child: const Icon(Icons.wallet_rounded, size: 16, color: Colors.white70),
            ),
            AppGap.w10,
            const Text('Crédit disponible',
                style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500)),
          ]),
          AppGap.h14,
          const Text('50,00 €',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
          AppGap.h18,
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          AppGap.h14,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.credit_card_rounded, size: 12, color: Colors.white38),
                  AppGap.w6,
                  const Text('Visa •••• 4242',
                      style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
                ]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  AppGap.w5,
                  const Text('Actif',
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

// ─── Bouton ajouter des fonds ─────────────────────────────────────────────────

class _AddFundsBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddFundsSheet(context),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_rounded, size: 18, color: context.colors.textSecondary),
          AppGap.w8,
          Text('Ajouter des fonds', style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
        ]),
      ),
    );
  }

  void _showAddFundsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _AddFundsSheet(),
    );
  }
}

// ─── Paiements en cours ───────────────────────────────────────────────────────

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
        _SectionTitle('PAIEMENTS EN COURS'),
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
                      Text('Sécurisé · libéré dans ${items[i].hoursLeft}h',
                          style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(items[i].amount,
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

// ─── Paiements récents ────────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  final bool embedded;
  const _RecentSection({required this.embedded});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Tx('Ménage appartement', 'Thomas R.', '−55,00 €', "Aujourd'hui"),
      _Tx('Jardinage',          'Julie M.',  '−40,00 €', 'Hier'),
      _Tx('Repassage',          'Marc D.',   '−35,00 €', '25 Nov'),
      _Tx('Bricolage',          'Antoine B.','−80,00 €', '20 Nov'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _SectionTitle('RÉCENT')),
          GestureDetector(
            onTap: embedded ? null : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ClientPaymentHistoryPage())),
            child: Text('Voir tout',
                style: context.text.bodySmall?.copyWith(
                    color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
          ),
        ]),
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
                    child: Icon(Icons.arrow_upward_rounded, size: 17, color: context.colors.textSecondary),
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
                      Text(items[i].subtitle,
                          style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(items[i].amount,
                        style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
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

// ─── Sheet ajouter des fonds ──────────────────────────────────────────────────

class _AddFundsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppFormSheet(
        title: 'Ajouter des fonds',
        footer: AppButton(
          label: 'Ajouter',
          variant: ButtonVariant.black,
          onPressed: () => Navigator.pop(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: AppInputDecorations.formField(context, hintText: 'Ex: 50').copyWith(
                labelText: 'Montant',
                suffixText: '€',
              ),
              style: context.text.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppGap.h12,
            Row(children: [
              for (final v in ['20 €', '50 €', '100 €', '200 €']) ...[
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
                Icon(Icons.credit_card_rounded, size: 18, color: context.colors.textSecondary),
                AppGap.w12,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Visa •••• 4242', style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                  Text('Expire 12/26', style: context.text.labelSmall?.copyWith(
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
  final String title, subtitle, amount, date;
  const _Tx(this.title, this.subtitle, this.amount, this.date);
}
