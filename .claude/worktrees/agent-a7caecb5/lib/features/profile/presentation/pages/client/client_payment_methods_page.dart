import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

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
    _Card(brand: 'Visa', last4: '4242', expiry: '12/26', isDefault: true, color: const Color(0xFF2563EB)),
    _Card(brand: 'Mastercard', last4: '8888', expiry: '08/25', isDefault: false, color: const Color(0xFFEA580C)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Moyens de paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showAddCardSheet(context),
            child: Text('Ajouter', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text('Ajouter une carte',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Info sécurité ───
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFF2563EB), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vos informations bancaires sont chiffrées et sécurisées. Inkern ne stocke jamais vos numéros de carte complets.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1D4ED8), height: 1.5),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la carte ?'),
        content: Text('La carte ${_cards[index].brand} •••• ${_cards[index].last4} sera supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _removeCard(index); },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Ajouter une carte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _buildInput(label: 'Numéro de carte', hint: '1234 5678 9012 3456',
                  icon: Icons.credit_card_rounded, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildInput(label: 'Expiration', hint: 'MM/AA', keyboard: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'CVV', hint: '123',
                    keyboard: TextInputType.number, obscure: true)),
              ]),
              const SizedBox(height: 12),
              _buildInput(label: 'Nom du titulaire', hint: 'Jean Dupont'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter la carte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: card.isDefault ? Border.all(color: AppColors.primary, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.credit_card_rounded, color: card.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${card.brand} •••• ${card.last4}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (card.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Par défaut',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                Text('Expire ${card.expiry}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'default') onSetDefault();
              if (value == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              if (!card.isDefault)
                const PopupMenuItem(value: 'default',
                    child: Row(children: [Icon(Icons.star_rounded, size: 18), SizedBox(width: 10), Text('Définir par défaut')])),
              const PopupMenuItem(value: 'remove',
                  child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.red), SizedBox(width: 10),
                    Text('Supprimer', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }
}
