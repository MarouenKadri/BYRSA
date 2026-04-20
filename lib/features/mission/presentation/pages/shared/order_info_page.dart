import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class OrderInfoPage extends StatelessWidget {
  final String orderNumber;
  final String receiverName;
  final String receiverAddress;
  final String deliveryDate;
  final String deliveryTime;
  final String deliveryType;
  final VoidCallback? onGoHome;
  final VoidCallback? onRate;

  const OrderInfoPage({
    super.key,
    this.orderNumber = '1234',
    this.receiverName = 'John Doe',
    this.receiverAddress = '123 Rue de la Paix, Paris',
    this.deliveryDate = '20 Avril 2026',
    this.deliveryTime = '14h30',
    this.deliveryType = 'Livraison standard',
    this.onGoHome,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _CircleBackButton(onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  Text(
                    'Order #$orderNumber',
                    style: context.text.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dark status card
                    _DeliveryStatusCard(),
                    const SizedBox(height: 20),

                    // Order receiver card
                    _InfoCard(
                      title: 'Destinataire',
                      rows: [
                        _InfoRow(icon: Icons.person_outline_rounded, label: 'Nom', value: receiverName),
                        _InfoRow(icon: Icons.location_on_outlined, label: 'Adresse', value: receiverAddress),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Delivery details card
                    _InfoCard(
                      title: 'Détails de livraison',
                      rows: [
                        _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date', value: deliveryDate),
                        _InfoRow(icon: Icons.access_time_rounded, label: 'Heure', value: deliveryTime),
                        _InfoRow(icon: Icons.local_shipping_outlined, label: 'Type', value: deliveryType),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ───────────────────────────────────────────────
            _BottomActions(onGoHome: onGoHome, onRate: onRate),
          ],
        ),
      ),
    );
  }
}

// ─── Back button ─────────────────────────────────────────────────────────────

class _CircleBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _CircleBackButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.12),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Dark status card ─────────────────────────────────────────────────────────

class _DeliveryStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre commande',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'a été livrée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.20),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.expand((row) => [row, const SizedBox(height: 10)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: context.colors.textSecondary.withValues(alpha: 0.70),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.text.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback? onGoHome;
  final VoidCallback? onRate;

  const _BottomActions({this.onGoHome, this.onRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(
          top: BorderSide(color: context.colors.divider),
        ),
      ),
      child: Row(
        children: [
          // Outline button — Retour home
          Expanded(
            child: _OutlineButton(
              label: 'Retour home',
              onPressed: onGoHome,
            ),
          ),
          const SizedBox(width: 12),
          // Dark button — Rate
          _DarkButton(
            label: 'Évaluer',
            onPressed: onRate,
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _OutlineButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(21.5),
          border: Border.all(color: context.colors.border, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DarkButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: AppColors.inkDark,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
