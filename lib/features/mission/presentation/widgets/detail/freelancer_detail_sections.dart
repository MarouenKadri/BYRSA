import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import '../../../../freelancer/presentation/pages/client_profile_view.dart';

// ─── FreelancerClientCard ─────────────────────────────────────────────────────

class FreelancerClientCard extends StatelessWidget {
  final ClientInfo client;
  final VoidCallback? onPhone;
  final VoidCallback? onChat;

  const FreelancerClientCard({
    super.key,
    required this.client,
    this.onPhone,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.h16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publie par',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            AppGap.h14,
            GestureDetector(
              onTap: () => Navigator.push(
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
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8EBEF),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: client.avatarUrl.isNotEmpty
                        ? Image.network(
                            client.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ClientAvatarFallback(name: client.name),
                          )
                        : _ClientAvatarFallback(name: client.name),
                  ),
                  AppGap.w14,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                client.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            if (client.isVerified) ...[
                              AppGap.w6,
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.ink,
                              ),
                            ],
                          ],
                        ),
                        AppGap.h6,
                        Text(
                          '${client.rating.toStringAsFixed(1)} · ${client.missionsCount} mission${client.missionsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8F98A3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFB0B8C1)),
                ],
              ),
            ),
            if (onPhone != null || onChat != null) ...[
              AppGap.h16,
              Row(
                children: [
                  if (onPhone != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPhone,
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Appeler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: Color(0xFFE1E6EB)),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (onPhone != null && onChat != null) AppGap.w10,
                  if (onChat != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onChat,
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text('Contacter'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.ink,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FreelancerLocationShareCard extends StatelessWidget {
  final MissionStatus status;
  final VoidCallback onOpenMissionPilot;

  const FreelancerLocationShareCard({
    super.key,
    required this.status,
    required this.onOpenMissionPilot,
  });

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      MissionStatus.confirmed => (
          icon: Icons.navigation_rounded,
          title: 'Code client requis',
          subtitle:
              'Quand vous arrivez, demandez le code de demarrage au client pour lancer officiellement la mission.',
          cta: 'Lancer le suivi',
          accent: AppColors.iosBlue,
        ),
      MissionStatus.onTheWay => (
          icon: Icons.location_searching_rounded,
          title: 'En route vers la mission',
          subtitle:
              'Une fois arrive, entrez le code donne par le client pour demarrer la mission.',
          cta: 'Gerer le suivi',
          accent: AppColors.primary,
        ),
      MissionStatus.inProgress => (
          icon: Icons.my_location_rounded,
          title: 'Position active sur mission',
          subtitle:
              'Le client peut verifier que vous etes bien sur place pendant l intervention.',
          cta: 'Voir le pilotage',
          accent: AppColors.primary,
        ),
      _ => (
          icon: Icons.location_disabled_rounded,
          title: 'Partage de position indisponible',
          subtitle:
              'Le suivi live apparait uniquement pour une mission confirmee ou en cours.',
          cta: 'Voir le pilotage',
          accent: const Color(0xFF98A1AC),
        ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9ECF0), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: config.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(config.icon, size: 20, color: config.accent),
                ),
                AppGap.w12,
                Expanded(
                  child: Text(
                    config.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h14,
            Text(
              config.subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: const Color(0xFF6E7781),
              ),
            ),
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: config.accent,
                  ),
                  AppGap.w8,
                  Expanded(
                    child: Text(
                      'Le partage live doit etre active depuis le pilotage de mission.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4C5661),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOpenMissionPilot,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(config.cta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientAvatarFallback extends StatelessWidget {
  final String name;
  const _ClientAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: context.text.headlineSmall?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ─── FreelancerActionSheet ────────────────────────────────────────────────────

class FreelancerActionSheet extends StatelessWidget {
  final VoidCallback onReport;

  const FreelancerActionSheet({super.key, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Options',
      children: [
        AppActionSheetItem(
          icon: Icons.flag_outlined,
          title: 'Signaler cette mission',
          destructive: true,
          onTap: onReport,
        ),
      ],
    );
  }
}

// ─── FreelancerReportConfirmSheet ─────────────────────────────────────────────

class FreelancerReportConfirmSheet extends StatefulWidget {
  final String missionTitle;
  final VoidCallback onConfirm;

  const FreelancerReportConfirmSheet({
    super.key,
    required this.missionTitle,
    required this.onConfirm,
  });

  @override
  State<FreelancerReportConfirmSheet> createState() =>
      _FreelancerReportConfirmSheetState();
}

class _FreelancerReportConfirmSheetState
    extends State<FreelancerReportConfirmSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Signaler la mission ?',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signaler la mission ?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.snow,
              ),
            ),
            AppGap.h6,
            Text(
              widget.missionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.gray500,
              ),
            ),
            AppGap.h18,
            const Text(
              'Merci de nous aider à garder la plateforme sûre. Votre signalement sera examiné par notre équipe.',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: AppColors.gray500,
              ),
            ),
            AppGap.h24,
            const Divider(height: 1, color: Color(0x1FFFFFFF)),
            AppGap.h24,
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() => _loading = true);
                      widget.onConfirm();
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFE57373),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Signaler'),
            ),
          ),
        ),
        AppGap.h12,
        Center(
          child: GestureDetector(
            onTap: _loading ? null : () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── FreelancerProposalSheet ──────────────────────────────────────────────────

class FreelancerProposalSheet extends StatefulWidget {
  final Mission mission;
  final TextEditingController priceController;
  final TextEditingController messageController;
  final void Function(double price, String message) onSubmit;

  const FreelancerProposalSheet({
    super.key,
    required this.mission,
    required this.priceController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  State<FreelancerProposalSheet> createState() =>
      _FreelancerProposalSheetState();
}

class _FreelancerProposalSheetState extends State<FreelancerProposalSheet> {
  late final List<int> _quickAmounts;
  int _messageLength = 0;

  @override
  void initState() {
    super.initState();
    final base = widget.mission.budget.totalAmount.toInt();
    _quickAmounts = base > 0
        ? [
            (base * 0.8).round(),
            (base * 0.9).round(),
            base,
            (base * 1.1).round(),
            (base * 1.2).round(),
          ]
        : [50, 80, 100, 120, 150];
    _messageLength = widget.messageController.text.length;
    widget.messageController.addListener(_onMsg);
  }

  void _onMsg() {
    if (mounted) setState(() => _messageLength = widget.messageController.text.length);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onMsg);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final priceText = widget.priceController.text;
    final canSubmit = priceText.isNotEmpty &&
        int.tryParse(priceText) != null &&
        int.parse(priceText) > 0;

    return SizedBox(
      height: h * 0.88,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DDE3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // ── Title row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Votre proposition',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF98A1AC),
                    ),
                  ),
                ],
              ),
            ),
            // ── Scrollable fields ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.mission.title} • ${widget.mission.formattedDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5F6975),
                      ),
                    ),
                    AppGap.h24,
                    Text(
                      'Votre tarif',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7E8792),
                      ),
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.priceController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1.2,
                        color: AppColors.ink,
                      ),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: '0',
                        hintStyle: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.2,
                          color: Color(0xFFD5D9DE),
                        ),
                        contentPadding: EdgeInsets.zero,
                        noBorder: true,
                        fillColor: Colors.transparent,
                      ).copyWith(
                        prefixText: '€ ',
                        prefixStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    AppGap.h8,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((amount) {
                        final isActive =
                            widget.priceController.text == amount.toString();
                        return GestureDetector(
                          onTap: () {
                            widget.priceController.text = amount.toString();
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.black
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$amount €',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AppGap.h28,
                    Row(
                      children: [
                        Text(
                          'Message au client',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7E8792),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_messageLength/400',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA1A9B3),
                          ),
                        ),
                      ],
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.messageController,
                      maxLines: 5,
                      maxLength: 400,
                      buildCounter:
                          (_, {required currentLength, required isFocused, maxLength}) =>
                              null,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText:
                            'Présentez-vous, vos atouts, votre expérience...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFA4ACB5),
                        ),
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        radius: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Submit button ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(22, 12, 22, 16 + bottomPad),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () => widget.onSubmit(
                            double.parse(widget.priceController.text),
                            widget.messageController.text,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.black,
                    disabledBackgroundColor:
                        Colors.black.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Envoyer ma proposition'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
