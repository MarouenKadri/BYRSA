import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission.dart';
import '../../../data/models/mission_address.dart';
import '../../pages/shared/mission_map_page.dart';
import '../shared/status_timeline.dart';
import 'mission_detail_hero.dart';
import 'mission_detail_primitives.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MissionDetailBase — Template Method Pattern
///
/// Squelette de page mission (layout fixe) avec slots abstraits par rôle.
/// Ne contient aucun `if (isClient)` ni `if (isFreelancer)`.
/// ═══════════════════════════════════════════════════════════════════════════

abstract class MissionDetailBase<T extends StatefulWidget> extends State<T> {
  late Mission mission;

  // ─── Abstract — fournis par chaque rôle ────────────────────────────────────

  /// Mission initiale depuis le widget
  Mission get widgetMission;

  /// Synchronisation live depuis le Provider (appelé à chaque build)
  Mission syncMission(BuildContext ctx);

  /// Config data de la bannière status → null = pas de bannière
  StatusBannerConfig? resolveBanner();

  /// Pills + budget (différent client / freelancer)
  Widget buildTagsPrice(BuildContext ctx);

  /// Section rôle-spécifique (presta card ou client card)
  Widget buildRoleSection(BuildContext ctx);

  /// Carte finance exposée (retourne null si non pertinente)
  Widget? buildFinanceExposureCard(BuildContext ctx);

  /// CTA bas de page
  Widget buildBottom(BuildContext ctx);

  /// Bouton menu dans le hero (⋯) — null = pas de bouton
  Widget? buildHeroMenu(BuildContext ctx);

  /// Afficher la StatusTimeline ?
  bool get showTimeline;

  /// Cacher le bottom (ex: isReadOnly côté client)
  bool get isBottomHidden;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    mission = widgetMission;
  }

  // ─── Template Method — build squelette fixe ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    mission = syncMission(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final financeExposureCard = buildFinanceExposureCard(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero (fixe, non scrollable) ──────────────────────────────────
          MissionDetailHero(
            mission: mission,
            onBack: () => Navigator.pop(context),
            menuButton: buildHeroMenu(context),
          ),

          // ── Header (fixe, non scrollable) ────────────────────────────────
          AppGap.h20,
          Padding(
            padding: AppInsets.h16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                AppGap.h16,
                buildTagsPrice(context),
              ],
            ),
          ),
          AppGap.h20,

          // ── Corps scrollable ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTimeline)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: StatusTimeline(status: mission.status),
                    ),
                  if (financeExposureCard != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: financeExposureCard,
                    ),
                  _buildMap(context),
                  AppGap.h20,
                  _buildDescription(context),
                  AppGap.h20,
                  _buildStatusBanner(context),
                  buildRoleSection(context),
                  AppGap.h32,
                ],
              ),
            ),
          ),

          // ── Bottom fixe ──────────────────────────────────────────────────
          if (!isBottomHidden) buildBottom(context),
        ],
      ),
    );
  }

  // ─── Sections concrètes partagées ──────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mission.categoryName.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.1,
            color: context.colors.textTertiary,
          ),
        ),
        AppGap.h12,
        Row(
          children: [
            Expanded(
              child: DetailMetaChip(
                icon: Icons.calendar_today_outlined,
                label: mission.formattedDate,
              ),
            ),
            const DetailInlineDivider(),
            Expanded(
              child: DetailMetaChip(
                icon: Icons.schedule_outlined,
                label: mission.timeSlot,
              ),
            ),
            const DetailInlineDivider(),
            Expanded(
              child: DetailMetaChip(
                icon: Icons.location_on_outlined,
                label: mission.address.shortAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return Container(
      margin: AppInsets.h16,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 182,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _DetailMapPreview(address: mission.address),
                    ),
                  ),
                  // Overlay Flutter au-dessus de la platform view pour capturer les taps
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MissionMapPage(address: mission.address),
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const Center(child: DetailMiniMapPin()),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MissionMapPage(address: mission.address),
                        ),
                      ),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colors.border,
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h14,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: context.colors.textTertiary,
                  ),
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    mission.address.shortAddress.isNotEmpty
                        ? mission.address.shortAddress
                        : mission.address.fullAddress,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: AppInsets.h16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackAlpha03,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            AppGap.h12,
            Text(
              mission.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.65,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rendu centralisé — la base rend, les rôles fournissent les données
  Widget _buildStatusBanner(BuildContext context) {
    final cfg = resolveBanner();
    if (cfg == null) return const SizedBox.shrink();
    return DetailStatusBanner(config: cfg);
  }
}

class _DetailMapPreview extends StatefulWidget {
  final MissionAddress address;

  const _DetailMapPreview({required this.address});

  @override
  State<_DetailMapPreview> createState() => _DetailMapPreviewState();
}

class _DetailMapPreviewState extends State<_DetailMapPreview> {
  Future<LatLng?>? _centerFuture;

  @override
  void initState() {
    super.initState();
    _centerFuture = _resolveCenter();
  }

  Future<LatLng?> _resolveCenter() async {
    final lat = widget.address.latitude;
    final lon = widget.address.longitude;
    if (lat != null && lon != null) {
      return LatLng(lat, lon);
    }

    final query = widget.address.fullAddress.trim();
    if (query.isEmpty) return null;

    final place = await NominatimService.geocodeSingle(query);
    return place?.latLng;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng?>(
      future: _centerFuture,
      builder: (context, snapshot) {
        final center = snapshot.data;
        if (center == null) {
          return DetailMapPlaceholder(
            address: widget.address.shortAddress,
          );
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.location_on, color: AppColors.mapPin, size: 30),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
