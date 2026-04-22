import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../../../core/design/app_primitives.dart';
import '../../../widgets/shared/payment_common_widgets.dart';
import '../../../widgets/shared/user_common_widgets.dart';

class ClientFinanceMethodsTab extends StatefulWidget {
  const ClientFinanceMethodsTab({super.key});

  @override
  State<ClientFinanceMethodsTab> createState() => _ClientFinanceMethodsTabState();
}

class _ClientFinanceMethodsTabState extends State<ClientFinanceMethodsTab> {
  final List<_Card> _cards = [
    _Card(brand: 'Visa', last4: '4242', expiry: '12/26', isDefault: true),
    _Card(
      brand: 'Mastercard',
      last4: '8888',
      expiry: '08/25',
      isDefault: false,
    ),
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
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppColors.whiteAlpha12,
            ),
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
                  subtitle:
                      '${card.brand} •••• ${card.last4} sera supprimée définitivement.',
                  onConfirm: () => _removeCard(index),
                ),
              );
            },
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
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
              ..._cards.asMap().entries.expand((entry) => [
                    _CardRow(
                      card: entry.value,
                      onTap: () => _showCardOptions(context, entry.key),
                    ),
                    if (entry.key < _cards.length - 1)
                      Divider(
                        height: 1,
                        indent: 68,
                        color: context.colors.divider,
                      ),
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
        const PaymentInfoNote(
          icon: Icons.lock_outline_rounded,
          body:
              'Chiffrement SSL · Inkern ne stocke jamais vos numéros de carte complets.',
        ),
      ],
    );
  }
}

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
        child: Row(
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
                Icons.credit_card_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${card.brand} •••• ${card.last4}',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      if (card.isDefault) ...[
                        AppGap.w8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Text(
                            'Défaut',
                            style: context.text.labelSmall?.copyWith(
                              fontSize: 10,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppGap.h2,
                  Text(
                    'Expire ${card.expiry}',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

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
            PaymentShadowField(
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: AppFontSize.body,
                  color: context.colors.textPrimary,
                ),
                decoration: AppInputDecorations.profileField(
                  context,
                  hintText: 'Numéro de carte',
                  prefixIcon: Icon(
                    Icons.credit_card_rounded,
                    size: 16,
                    color: context.colors.textHint,
                  ),
                ),
              ),
            ),
            AppGap.h16,
            Row(
              children: [
                Expanded(
                  child: PaymentShadowField(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: AppFontSize.body,
                        color: context.colors.textPrimary,
                      ),
                      decoration: AppInputDecorations.profileField(
                        context,
                        hintText: 'MM/AA',
                      ),
                    ),
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: PaymentShadowField(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: TextStyle(
                        fontSize: AppFontSize.body,
                        color: context.colors.textPrimary,
                      ),
                      decoration: AppInputDecorations.profileField(
                        context,
                        hintText: 'CVV',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h16,
            PaymentShadowField(
              child: TextFormField(
                style: TextStyle(
                  fontSize: AppFontSize.body,
                  color: context.colors.textPrimary,
                ),
                decoration: AppInputDecorations.profileField(
                  context,
                  hintText: 'Titulaire de la carte',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: context.colors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card {
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;

  const _Card({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });

  _Card copyWith({bool? isDefault}) {
    return _Card(
      brand: brand,
      last4: last4,
      expiry: expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
