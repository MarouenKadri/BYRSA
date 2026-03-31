import 'package:flutter/material.dart' hide FilterChip;

import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../shared/mission_common_widgets.dart';
import '../../../../freelancer/presentation/pages/client_profile_view.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔧 Inkern - Widgets Freelancer
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Client Info Row ──────────────────────────────────────────────────────────

class ClientInfoRow extends StatelessWidget {
  final ClientInfo client;
  final bool compact;

  const ClientInfoRow({super.key, required this.client, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(imageUrl: client.avatarUrl, radius: compact ? 16 : 18, showVerified: client.isVerified),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(client.name, style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              RatingWidget(rating: client.rating, missionsCount: client.missionsCount, compact: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Client (Détail Mission) ─────────────────────────────────────────

class ClientSection extends StatelessWidget {
  final ClientInfo client;
  final String? missionBudget;
  final VoidCallback? onMessage;
  final VoidCallback? onPhone;
  final bool canViewProfile;

  const ClientSection({super.key, required this.client, this.missionBudget, this.onMessage, this.onPhone, this.canViewProfile = false});

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientProfileView(
          clientId: client.id,
          clientName: client.name,
          clientAvatar: client.avatarUrl,
          rating: client.rating,
          missionsCount: client.missionsCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Avatar + nom + avis ───
          GestureDetector(
            onTap: canViewProfile ? () => _goToProfile(context) : null,
            child: Row(
              children: [
                UserAvatar(imageUrl: client.avatarUrl, radius: 28, showVerified: client.isVerified),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            client.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          Text(
                            ' · ${client.missionsCount} mission${client.missionsCount > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canViewProfile)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),

          // ─── Budget de la mission ───
          if (missionBudget != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget de la mission',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text(
                    missionBudget!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],

          // ─── Boutons de contact ───
          if (onMessage != null || onPhone != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onMessage != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (onMessage != null && onPhone != null) const SizedBox(width: 10),
                if (onPhone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPhone,
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: const Text('Téléphone'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ClientStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ClientStatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Formulaire de Candidature ────────────────────────────────────────────────

class ApplicationForm extends StatelessWidget {
  final BudgetInfo suggestedBudget;
  final TextEditingController? priceController;
  final TextEditingController? messageController;

  const ApplicationForm({
    super.key,
    required this.suggestedBudget,
    this.priceController,
    this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Titre ───
          Row(children: [
            const Icon(Icons.send_rounded, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Votre proposition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),

          const SizedBox(height: 20),

          // ─── Tarif (obligatoire) ───
          Row(
            children: [
              const Text('Votre tarif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Obligatoire', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: priceController,
            initialValue: priceController == null ? suggestedBudget.averageAmount.toInt().toString() : null,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: suggestedBudget.averageAmount.toInt().toString(),
              hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.border),
              prefixIcon: const Icon(Icons.euro_rounded, color: AppColors.primary),
              suffixText: '€',
              suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              helperText: 'Budget suggéré par le client : ${suggestedBudget.displayText}',
              helperStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.primary.withOpacity(0.04),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),

          // ─── Message (optionnel) ───
          Row(
            children: [
              const Text('Message au client', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Optionnel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Présentez-vous et expliquez pourquoi vous êtes le bon choix...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 14),
          const TipBox(text: 'Conseil : Mentionnez votre expérience et votre disponibilité.'),
        ],
      ),
    );
  }
}

// ─── Tip Box ─────────────────────────────────────────────────────────────────

class TipBox extends StatelessWidget {
  final String text;
  final IconData icon;

  const TipBox({super.key, required this.text, this.icon = Icons.lightbulb_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.info, height: 1.4))),
        ],
      ),
    );
  }
}

// ─── Mission Filter Chip ──────────────────────────────────────────────────────

class MissionFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const MissionFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Distance Badge ───────────────────────────────────────────────────────────

class DistanceBadge extends StatelessWidget {
  final String distance;
  final bool compact;

  const DistanceBadge({super.key, required this.distance, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_outlined, size: compact ? 14 : 16, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          distance,
          style: TextStyle(fontSize: compact ? 12 : 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─── Mission Meta Row ─────────────────────────────────────────────────────────

class MissionMetaRow extends StatelessWidget {
  final int candidatesCount;
  final String postedAtText;

  const MissionMetaRow({super.key, required this.candidatesCount, required this.postedAtText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text('$candidatesCount candidat${candidatesCount > 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        const Spacer(),
        Icon(Icons.access_time_rounded, size: 16, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(postedAtText, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

// ─── Application Success Dialog ───────────────────────────────────────────────

class ApplicationSuccessDialog extends StatelessWidget {
  final String clientName;
  final VoidCallback onContinue;

  const ApplicationSuccessDialog({super.key, required this.clientName, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('Proposition envoyée !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Votre proposition a été envoyée à $clientName.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
            child: const Text('Continuer'),
          ),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context, {required String clientName, required VoidCallback onContinue}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApplicationSuccessDialog(clientName: clientName, onContinue: onContinue),
    );
  }
}
