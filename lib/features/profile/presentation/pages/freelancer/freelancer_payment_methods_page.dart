import 'package:flutter/material.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../shared/payment_history_page.dart';
import '../shared/wallet_page.dart';
import '../../widgets/shared/user_common_widgets.dart';
import '../../widgets/shared/payment_common_widgets.dart';

class FreelancerPaymentMethodsPage extends StatefulWidget {
  const FreelancerPaymentMethodsPage({super.key});

  @override
  State<FreelancerPaymentMethodsPage> createState() =>
      _FreelancerPaymentMethodsPageState();
}

class _FreelancerPaymentMethodsPageState
    extends State<FreelancerPaymentMethodsPage> {
  int _selectedTabIndex = 0;

  void _showIbanOptions(BuildContext context) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: 'Compte de virement SEPA',
        children: [
          AppActionSheetItem(
            icon: Icons.edit_outlined,
            title: 'Modifier l\'IBAN SEPA',
            onTap: () {
              Navigator.pop(context);
              _showEditIbanSheet(context);
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
          AppActionSheetItem(
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer le compte',
            destructive: true,
            onTap: () {
              Navigator.pop(context);
              showAppBottomSheet(
                context: context,
                wrapWithSurface: false,
                child: PaymentDeleteConfirmSheet(
                  title: 'Supprimer le compte ?',
                  subtitle: 'Le compte SEPA FR76 •••• 1234 sera supprimé définitivement.',
                  onConfirm: () {},
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
        titleWidget: Text('Moyens de paiement', style: context.profilePageTitleStyle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            tabs: const [
              AppSegmentedTab(label: 'Moyens'),
              AppSegmentedTab(label: 'Historique'),
              AppSegmentedTab(label: 'Portefeuille'),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildMethodsContent(context),
                const PaymentHistoryPage(embedded: true),
                const WalletPage(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [

        // ─── Dashboard solde ───────────────────────────────────────────────
        _BalanceDashboard(),
        AppGap.h20,

        // ─── Nouveau paiement en attente ───────────────────────────────────
        _PendingPaymentBanner(),
        AppGap.h24,

        // ─── Compte de virement SEPA ──────────────────────────────────────
        const PaymentSectionLabel('COMPTE DE VIREMENT SEPA'),
        AppGap.h12,
        _SepaPayoutAccountCard(onTap: () => _showIbanOptions(context)),
        AppGap.h10,
        PaymentAddButton(
          label: 'Ajouter un IBAN SEPA',
          onTap: () => _showAddIbanSheet(context),
        ),

        AppGap.h28,

        // ─── Info versement automatique ────────────────────────────────────
        PaymentInfoNote(
          icon: Icons.autorenew_rounded,
          body: 'Le versement est automatique 24h après chaque livraison validée. Aucune action requise de votre part.',
        ),

        AppGap.h12,

        // ─── Pourquoi SEPA ────────────────────────────────────────────────
        PaymentInfoNote(
          icon: Icons.account_balance_rounded,
          title: 'IBAN SEPA pour les payouts marketplace',
          body: 'En France et en Europe, le virement SEPA est généralement moins coûteux en frais, plus fiable pour les payouts, et mieux adapté aux montants élevés. Compatible avec les flux Stripe, PayPal et MangoPay.',
        ),

        AppGap.h12,

        // ─── Info fiscale ──────────────────────────────────────────────────
        PaymentInfoNote(
          icon: Icons.info_outline_rounded,
          body: 'Les virements peuvent être soumis à déclaration fiscale. Conservez vos relevés pour votre déclaration de revenus.',
        ),
      ],
    );
  }

  void _showAddIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: const _IbanSheet(isEdit: false),
    );
  }

  void _showEditIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: const _IbanSheet(isEdit: true),
    );
  }
}

// ─── Dashboard solde ──────────────────────────────────────────────────────────

class _BalanceDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withGreen(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Solde disponible',
              style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
          AppGap.h4,
          Text('145,50 €',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          AppGap.h16,
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          AppGap.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.lock_clock_rounded, size: 15, color: Colors.white70),
                AppGap.w6,
                const Text('En attente',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
              ]),
              const Text('100,00 €',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          AppGap.h6,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: Colors.white54),
              AppGap.w4,
              const Text('Versement prévu dans 18h',
                  style: TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bannière paiement en attente (sobre) ─────────────────────────────────────

class _PendingPaymentBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.lock_clock_rounded, color: AppColors.warning, size: 18),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement sécurisé — Création logo',
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                AppGap.h2,
                Text(
                  'Versement automatique dans 18h',
                  style: context.text.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AppGap.w8,
          Text(
            '100,00 €',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bloc compte SEPA (minimal) ───────────────────────────────────────────────

class _SepaPayoutAccountCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SepaPayoutAccountCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                ),
                AppGap.w10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IBAN SEPA',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Text(
                        'France + Europe',
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Actif',
                    style: context.text.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h14,
            Text(
              'FR76 •••• •••• •••• 1234',
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                letterSpacing: 1.4,
              ),
            ),
            AppGap.h12,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Titulaire: Jean Dupont',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                AppGap.w8,
                Text(
                  'BIC: BNPAFRPP',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AppGap.h8,
            Text(
              'Utilisé pour les payouts marketplace (Stripe, PayPal, MangoPay).',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            AppGap.h8,
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet IBAN ───────────────────────────────────────────────────────────────

class _IbanSheet extends StatelessWidget {
  final bool isEdit;
  const _IbanSheet({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppFormSheet(
        title: isEdit ? 'Modifier l\'IBAN SEPA' : 'Ajouter un IBAN SEPA',
        footer: Column(
          children: [
            ProfileSheetPrimaryAction(
              label: isEdit ? 'Enregistrer' : 'Ajouter l\'IBAN',
              onPressed: () => Navigator.pop(context),
            ),
            AppGap.h12,
            Center(
              child: ProfileSheetSecondaryAction(
                label: 'Annuler',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentShadowField(child: TextFormField(
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context,
                hintText: 'IBAN (FR76...)',
                prefixIcon: const Icon(Icons.account_balance_rounded, size: 16, color: Color(0xFFB0BAC4)),
              ),
            )),
            AppGap.h16,
            PaymentShadowField(child: TextFormField(
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context, hintText: 'BIC / SWIFT (optionnel)'),
            )),
            AppGap.h16,
            PaymentShadowField(child: TextFormField(
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context,
                hintText: 'Titulaire du compte',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFB0BAC4)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
