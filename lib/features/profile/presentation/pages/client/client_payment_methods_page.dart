import 'package:flutter/material.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import 'client_payment_history_page.dart';
import 'client_wallet_page.dart';
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
    _Card(brand: 'Visa', last4: '4242', expiry: '12/26', isDefault: true,
        gradient: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
    _Card(brand: 'Mastercard', last4: '8888', expiry: '08/25', isDefault: false,
        gradient: [Color(0xFF2D1B69), Color(0xFF11998E)]),
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
              onTap: () {
                Navigator.pop(context);
                _setDefault(index);
              },
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
                const ClientPaymentHistoryPage(embedded: true),
                const ClientWalletPage(embedded: true),
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

        // ─── Cartes ────────────────────────────────────────────────────────
        const PaymentSectionLabel('MES CARTES'),
        AppGap.h12,
        ..._cards.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _CreditCard(
            card: e.value,
            onTap: () => _showCardOptions(context, e.key),
          ),
        )),

        // ─── Ajouter ───────────────────────────────────────────────────────
        PaymentAddButton(
          label: 'Ajouter une carte',
          onTap: () => _showAddCardSheet(context),
        ),

        AppGap.h28,

        // ─── Paiement sécurisé info ────────────────────────────────────────
        PaymentInfoNote(
          icon: Icons.shield_rounded,
          title: 'Paiement sécurisé',
          body: 'Les fonds sont débités à la réservation et conservés de façon sécurisée jusqu\'à confirmation du service. Vous disposez de 24h après livraison pour signaler un problème.',
        ),

        AppGap.h12,

        // ─── Sécurité SSL ──────────────────────────────────────────────────
        PaymentInfoNote(
          icon: Icons.lock_outline_rounded,
          body: 'Vos informations bancaires sont chiffrées via SSL. Inkern ne stocke jamais vos numéros de carte complets.',
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

// ─── Carte bancaire visuelle ──────────────────────────────────────────────────

class _CreditCard extends StatelessWidget {
  final _Card card;
  final VoidCallback onTap;

  const _CreditCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: card.gradient.first.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cercles décoratifs
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne supérieure : réseau + badge défaut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      if (card.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Par défaut',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Numéro masqué
                  Text(
                    '•••• •••• •••• ${card.last4}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2.5,
                    ),
                  ),
                  AppGap.h14,
                  // Expiration + menu
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRE',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            card.expiry,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 18),
                      ),
                    ],
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

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Card {
  final String brand, last4, expiry;
  final bool isDefault;
  final List<Color> gradient;

  const _Card({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
    required this.gradient,
  });

  _Card copyWith({bool? isDefault}) => _Card(
    brand: brand, last4: last4, expiry: expiry,
    isDefault: isDefault ?? this.isDefault,
    gradient: gradient,
  );
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
        footer: Column(
          children: [
            ProfileSheetPrimaryAction(
              label: 'Ajouter la carte',
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
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context,
                hintText: 'Numéro de carte',
                prefixIcon: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFFB0BAC4)),
              ),
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
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFB0BAC4)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
