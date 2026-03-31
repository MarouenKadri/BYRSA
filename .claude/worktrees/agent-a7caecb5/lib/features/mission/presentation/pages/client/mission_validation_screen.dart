import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../mission_provider.dart';
import '../../widgets/shared/mission_common_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../../../../features/notifications/notification_provider.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ✅ Inkern - MissionValidationScreen (Client)
/// Écran de validation de mission : paiement, note, litige.
/// ═══════════════════════════════════════════════════════════════════════════

class MissionValidationScreen extends StatefulWidget {
  final Mission mission;

  const MissionValidationScreen({super.key, required this.mission});

  @override
  State<MissionValidationScreen> createState() => _MissionValidationScreenState();
}

class _MissionValidationScreenState extends State<MissionValidationScreen> {
  int _starRating = 0;

  double get _prestaAmount => widget.mission.budget.averageAmount * 0.9;
  double get _cigaleAmount => widget.mission.budget.averageAmount * 0.1;

  @override
  Widget build(BuildContext context) {
    final presta = widget.mission.assignedPresta;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Valider la mission', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───
                  Container(
                    padding: AppPadding.cardLarge,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.mission.title, style: AppTextStyles.h2),
                        if (presta != null) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            UserAvatar(imageUrl: presta.avatarUrl, radius: 22, showVerified: presta.isVerified),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(presta.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount, compact: true),
                            ]),
                          ]),
                        ],
                      ],
                    ),
                  ),

                  // ─── Timeline ───
                  StatusTimeline(status: widget.mission.status),

                  // ─── Récap paiement ───
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: AppPadding.cardLarge,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.payments_rounded, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Récapitulatif du paiement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 16),
                        _PaymentRow(
                          label: 'Montant total bloqué',
                          amount: widget.mission.budget.averageAmount,
                          bold: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1),
                        ),
                        _PaymentRow(
                          label: 'Versement prestataire (90%)',
                          amount: _prestaAmount,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        _PaymentRow(
                          label: 'Commission Inkern (10%)',
                          amount: _cigaleAmount,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  // ─── Notation ───
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: AppPadding.cardLarge,
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notez la prestation (optionnel)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () => setState(() => _starRating = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  i < _starRating ? Icons.star_rounded : Icons.star_border_rounded,
                                  size: 40,
                                  color: i < _starRating ? AppColors.rating : AppColors.border,
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_starRating > 0) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              _ratingLabel(_starRating),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Boutons d'action ───
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _validate,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('Valider et libérer ${_prestaAmount.round()} €'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openDispute,
              icon: const Icon(Icons.flag_rounded, color: AppColors.urgent),
              label: const Text('Ouvrir un litige', style: TextStyle(color: AppColors.urgent)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.urgent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validate() {
    final missionProvider = context.read<MissionProvider>();
    final notifProvider = context.read<NotificationProvider>();

    missionProvider.updateMissionStatus(widget.mission.id, MissionStatus.closed);

    notifProvider.addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.payment,
      title: 'Paiement reçu',
      body: 'Vous avez reçu ${_prestaAmount.round()} € pour la mission "${widget.mission.title}".',
      timeAgo: 'À l\'instant',
    ));

    Navigator.pop(context);
  }

  void _openDispute() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: const Text('Ouvrir un litige'),
        content: const Text(
          'Un conseiller Inkern vous contactera sous 24h. Le paiement reste bloqué pendant la procédure.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final missionProvider = context.read<MissionProvider>();
              final notifProvider = context.read<NotificationProvider>();

              missionProvider.updateMissionStatus(widget.mission.id, MissionStatus.dispute);

              notifProvider.addNotification(AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: NotifType.mission,
                title: 'Litige ouvert',
                body: 'Un litige a été ouvert pour la mission "${widget.mission.title}".',
                timeAgo: 'À l\'instant',
              ));

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.urgent, foregroundColor: Colors.white),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int stars) => switch (stars) {
    1 => 'Décevant',
    2 => 'Passable',
    3 => 'Bien',
    4 => 'Très bien',
    _ => 'Excellent !',
  };
}

// ─── Ligne de paiement ────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;

  const _PaymentRow({required this.label, required this.amount, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(
          '${amount.round()} €',
          style: TextStyle(fontSize: bold ? 18 : 15, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: effectiveColor),
        ),
      ],
    );
  }
}
