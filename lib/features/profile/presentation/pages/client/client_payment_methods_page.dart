import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

/// ─────────────────────────────────────────────────────────────
/// 💳 Inkern - Moyens de paiement (Client)
/// ─────────────────────────────────────────────────────────────
class ClientPaymentMethodsPage extends StatefulWidget {
  const ClientPaymentMethodsPage({super.key});

  @override
  State<ClientPaymentMethodsPage> createState() => _ClientPaymentMethodsPageState();
}

class _ClientPaymentMethodsPageState extends State<ClientPaymentMethodsPage> {
  final List<_Card> _cards = [
    _Card(brand: 'Visa', last4: '4242', expiry: '12/26', isDefault: true, color: AppColors.blueAction),
    _Card(brand: 'Mastercard', last4: '8888', expiry: '08/25', isDefault: false, color: AppColors.mastercardOrange),
  ];

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _Card(
          brand: _cards[i].brand,
          last4: _cards[i].last4,
          expiry: _cards[i].expiry,
          isDefault: i == index,
          color: _cards[i].color,
        );
      }
    });
  }

  void _removeCard(int index) {
    setState(() => _cards.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Moyens de paiement', style: context.profilePageTitleStyle),
        actions: [
          AppButton(
            label: 'Ajouter',
            variant: ButtonVariant.ghost,
            width: null,
            onPressed: () => _showAddCardSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: AppInsets.a16,
        children: [
          // ─── Cartes enregistrées ───
          ..._cards.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CardTile(
              card: entry.value,
              onSetDefault: () => _setDefault(entry.key),
              onRemove: () => _confirmRemove(context, entry.key),
            ),
          )),

          // ─── Ajouter une carte ───
          GestureDetector(
            onTap: () => _showAddCardSheet(context),
            child: AppSurfaceCard(
              padding: AppInsets.a16,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.border),
              child: Row(
                children: [
                  AppSurfaceCard(
                    padding: AppInsets.a10,
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: Icon(Icons.add_rounded, color: context.colors.textSecondary, size: 24),
                  ),
                  AppGap.w14,
                  Text('Ajouter une carte',
                      style: context.profilePrimaryLabelStyle.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),

          AppGap.h24,

          // ─── Info sécurité ───
          AppSurfaceCard(
            padding: AppInsets.a16,
            color: AppColors.blueBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.blueBorder),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.blueAction, size: 22),
                AppGap.w12,
                Expanded(
                  child: Text(
                    'Vos informations bancaires sont chiffrées et sécurisées. Inkern ne stocke jamais vos numéros de carte complets.',
                    style: context.profileSecondaryLabelStyle.copyWith(
                      color: AppColors.blueDark,
                      height: 1.5,
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

  void _confirmRemove(BuildContext context, int index) {
    showAppDialog(
      context: context,
      title: const Text('Supprimer la carte ?'),
      content: Text('La carte ${_cards[index].brand} •••• ${_cards[index].last4} sera supprimée.'),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () => _removeCard(index),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AppSheetSurface(
          padding: AppInsets.a20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSheetHeader(title: 'Ajouter une carte'),
              AppGap.h20,
              _buildInput(label: 'Numéro de carte', hint: '1234 5678 9012 3456',
                  icon: Icons.credit_card_rounded, keyboard: TextInputType.number),
              AppGap.h12,
              Row(children: [
                Expanded(child: _buildInput(label: 'Expiration', hint: 'MM/AA', keyboard: TextInputType.number)),
                AppGap.w12,
                Expanded(child: _buildInput(label: 'CVV', hint: '123',
                    keyboard: TextInputType.number, obscure: true)),
              ]),
              AppGap.h12,
              _buildInput(label: 'Nom du titulaire', hint: 'Jean Dupont'),
              AppGap.h24,
              AppButton(
                label: 'Ajouter la carte',
                variant: ButtonVariant.primary,
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: AppInputDecorations.formField(
        context,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ).copyWith(
        labelText: label,
        labelStyle: context.profileSheetFieldLabelStyle,
      ),
    );
  }
}

class _Card {
  final String brand, last4, expiry;
  final bool isDefault;
  final Color color;
  const _Card({required this.brand, required this.last4, required this.expiry,
      required this.isDefault, required this.color});
}

class _CardTile extends StatelessWidget {
  final _Card card;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  const _CardTile({required this.card, required this.onSetDefault, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: AppInsets.a16,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: card.isDefault ? Border.all(color: AppColors.primary, width: 1.5) : Border.all(color: context.colors.border),
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: card.color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Icon(Icons.credit_card_rounded, color: card.color, size: 24),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${card.brand} •••• ${card.last4}',
                        style: context.profilePrimaryLabelStyle),
                    if (card.isDefault) ...[
                      AppGap.w8,
                      AppTagPill(
                        label: 'Par défaut',
                        backgroundColor: AppColors.primary.withValues(alpha:0.1),
                        foregroundColor: AppColors.primary,
                        padding: AppInsets.h8v2,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ],
                ),
                Text('Expire ${card.expiry}', style: context.profileSecondaryLabelStyle),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: context.colors.textTertiary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
            onSelected: (value) {
              if (value == 'default') onSetDefault();
              if (value == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              if (!card.isDefault)
                const PopupMenuItem(value: 'default',
                    child: Row(children: [Icon(Icons.star_rounded, size: 18), AppGap.w10, Text('Définir par défaut')])),
              PopupMenuItem(value: 'remove',
                  child: Row(children: [const Icon(Icons.delete_rounded, size: 18, color: Colors.red), AppGap.w10,
                    Text('Supprimer', style: context.text.bodyMedium?.copyWith(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }
}
