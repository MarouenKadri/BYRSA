import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import 'mission_detail_primitives.dart';

const kDetailHeroHeight = 220.0;

class MissionDetailHero extends StatefulWidget {
  final Mission mission;
  final VoidCallback onBack;

  /// Bouton menu injecté par la page parente (⋯ client ou ⋯ freelancer)
  /// null = pas de bouton menu
  final Widget? menuButton;

  const MissionDetailHero({
    super.key,
    required this.mission,
    required this.onBack,
    this.menuButton,
  });

  @override
  State<MissionDetailHero> createState() => _MissionDetailHeroState();
}

class _MissionDetailHeroState extends State<MissionDetailHero> {
  int _index = 0;
  final _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hasImages = widget.mission.images.isNotEmpty;

    return SizedBox(
      height: kDetailHeroHeight,
      child: Stack(
        children: [
          // ── Image / placeholder ──────────────────────────────────────────
          Positioned.fill(
            child: hasImages
                ? PageView.builder(
                    controller: _ctrl,
                    itemCount: widget.mission.images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final src = widget.mission.images[i];
                      Widget fallback(_, __, ___) =>
                          DetailGradientPlaceholder(mission: widget.mission);
                      return src.startsWith('http')
                          ? Image.network(
                              src,
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            )
                          : Image.file(
                              File(src),
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            );
                    },
                  )
                : DetailGradientPlaceholder(mission: widget.mission),
          ),

          // ── Gradient top (assombrit pour lisibilité boutons) ─────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC7000000),
                      Color(0x52000000),
                      Color(0x00000000),
                    ],
                    stops: [0.0, 0.28, 0.62],
                  ),
                ),
              ),
            ),
          ),

          // ── AppBar overlay (back + menu) ─────────────────────────────────
          Positioned(
            top: topPad + 4,
            left: 8,
            right: 8,
            child: Row(
              children: [
                DetailCircleBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: widget.onBack,
                ),
                const Spacer(),
                if (widget.menuButton != null) widget.menuButton!,
              ],
            ),
          ),

          // ── Titre + pagination dots ──────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mission.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.9,
                  ),
                ),
                if (hasImages && widget.mission.images.length > 1) ...[
                  AppGap.h14,
                  Row(
                    children: List.generate(
                      widget.mission.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: _index == i ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _index == i ? Colors.white : Colors.white38,
                          borderRadius:
                              BorderRadius.circular(AppRadius.micro),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
