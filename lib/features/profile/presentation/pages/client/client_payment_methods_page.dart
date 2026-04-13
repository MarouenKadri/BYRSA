import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/shared/user_common_widgets.dart';

class ClientPaymentMethodsPage extends StatefulWidget {
  const ClientPaymentMethodsPage({super.key});

  @override
  State<ClientPaymentMethodsPage> createState() => _ClientPaymentMethodsPageState();
}

class _ClientPaymentMethodsPageState extends State<ClientPaymentMethodsPage> {
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
              _showDeleteConfirm(
                context,
                title: 'Supprimer la carte ?',
                subtitle: '${card.brand} •••• ${card.last4} sera supprimée définitivement.',
                onConfirm: () => _removeCard(index),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [

          // ─── Cartes ────────────────────────────────────────────────────────
          ..._cards.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CreditCard(
              card: e.value,
              onTap: () => _showCardOptions(context, e.key),
            ),
          )),

          // ─── Ajouter ───────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => _showAddCardSheet(context),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.border,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: context.colors.primary),
                  AppGap.w8,
                  Text(
                    'Ajouter une carte',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AppGap.h28,

          // ─── Sécurité ──────────────────────────────────────────────────────
          Container(
            padding: AppInsets.a16,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: context.colors.textTertiary),
                AppGap.w12,
                Expanded(
                  child: Text(
                    'Vos informations bancaires sont chiffrées via SSL. Inkern ne stocke jamais vos numéros de carte complets.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, {required String title, required String subtitle, required VoidCallback onConfirm}) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: _DeleteConfirmSheet(title: title, subtitle: subtitle, onConfirm: onConfirm),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _AddCardSheet(),
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

// ─── Sheet row ────────────────────────────────────────────────────────────────

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetRow({
    required this.icon, required this.label, required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color     = isDestructive ? const Color(0xFFE57373) : AppColors.snow;
    final iconColor = isDestructive ? const Color(0xFFE57373) : const Color(0xFFD5DADE);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(icon, size: 21, color: iconColor),
            AppGap.w14,
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color))),
          ],
        ),
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
            _ShadowField(child: TextFormField(
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
              decoration: AppInputDecorations.profileField(context,
                hintText: 'Numéro de carte',
                prefixIcon: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFFB0BAC4)),
              ),
            )),
            AppGap.h16,
            Row(children: [
              Expanded(child: _ShadowField(child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
                decoration: AppInputDecorations.profileField(context, hintText: 'MM/AA'),
              ))),
              AppGap.w12,
              Expanded(child: _ShadowField(child: TextFormField(
                keyboardType: TextInputType.number,
                obscureText: true,
                style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
                decoration: AppInputDecorations.profileField(context, hintText: 'CVV'),
              ))),
            ]),
            AppGap.h16,
            _ShadowField(child: TextFormField(
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

// ─── Confirmation suppression ─────────────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onConfirm;

  const _DeleteConfirmSheet({required this.title, required this.subtitle, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      title: title,
      footer: Column(
        children: [
          AppButton(
            label: 'Supprimer',
            variant: ButtonVariant.destructive,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
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
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
            ),
          ),
          AppGap.h16,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadowField extends StatelessWidget {
  final Widget child;
  const _ShadowField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
