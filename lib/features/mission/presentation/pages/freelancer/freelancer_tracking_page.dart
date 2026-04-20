import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';
import '../../../../../features/notifications/notification_provider.dart';

class FreelancerTrackingPage extends StatefulWidget {
  final Mission mission;
  const FreelancerTrackingPage({super.key, required this.mission});

  @override
  State<FreelancerTrackingPage> createState() => _FreelancerTrackingPageState();
}

class _FreelancerTrackingPageState extends State<FreelancerTrackingPage> {
  late Mission _mission;

  // Map
  final MapController _mapController = MapController();
  bool _following = true;

  // GPS
  StreamSubscription<Position>? _positionSub;
  LatLng? _currentPosition;
  bool _locationError = false;

  // Destination
  LatLng? _destinationLatLng;

  // ETA / distance
  double? _distanceKm;
  int _etaMinutes = 0;

  // Supabase broadcast channel
  RealtimeChannel? _broadcastChannel;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _initBroadcastChannel();
    _startLocationTracking();
    _geocodeDestination();
  }

  void _initBroadcastChannel() {
    _broadcastChannel = Supabase.instance.client
        .channel('tracking:${_mission.id}')
      ..subscribe();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _broadcastChannel?.unsubscribe();
    super.dispose();
  }

  // ── GPS ──────────────────────────────────────────────────────

  Future<void> _startLocationTracking() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationError = true);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      _onNewPosition(LatLng(pos.latitude, pos.longitude), moveMap: true);
    } catch (_) {}

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (!mounted) return;
      _onNewPosition(LatLng(pos.latitude, pos.longitude));
    });
  }

  void _onNewPosition(LatLng latlng, {bool moveMap = false}) {
    setState(() => _currentPosition = latlng);
    if (_following || moveMap) {
      _mapController.move(latlng, _following ? 15 : _mapController.camera.zoom);
    }
    _updateDistanceEta(latlng);
    _broadcastPosition(latlng);
  }

  void _broadcastPosition(LatLng latlng) {
    // Broadcast temps réel
    _broadcastChannel?.sendBroadcastMessage(
      event: 'position',
      payload: {'lat': latlng.latitude, 'lng': latlng.longitude},
    );
    // Persister dans la table missions existante
    Supabase.instance.client.from('missions').update({
      'tracking_lat': latlng.latitude,
      'tracking_lng': latlng.longitude,
      'tracking_updated_at': DateTime.now().toIso8601String(),
    }).eq('id', _mission.id).then((_) {}).catchError((_) {});
  }

  // ── Géocodage ────────────────────────────────────────────────

  Future<void> _geocodeDestination() async {
    try {
      final query = Uri.encodeComponent(_mission.address.fullAddress);
      final resp = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=$query&format=json&limit=1&countrycodes=fr',
        ),
        headers: {'Accept-Language': 'fr', 'User-Agent': 'InkernApp/1.0'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        if (data.isNotEmpty) {
          final dest = LatLng(
            double.parse(data.first['lat'] as String),
            double.parse(data.first['lon'] as String),
          );
          setState(() => _destinationLatLng = dest);
          if (_currentPosition != null) _updateDistanceEta(_currentPosition!);
        }
      }
    } catch (_) {}
  }

  // ── ETA & distance ───────────────────────────────────────────

  void _updateDistanceEta(LatLng current) {
    if (_destinationLatLng == null) return;
    final meters = const Distance()(current, _destinationLatLng!);
    final km = meters / 1000;
    setState(() {
      _distanceKm = km;
      // 30 km/h moyenne urbaine
      _etaMinutes = (km / 30 * 60).ceil().clamp(1, 999);
    });
  }

  String get _etaLabel {
    if (_currentPosition == null || _distanceKm == null) return '…';
    final dist = _distanceKm! < 1
        ? '${(_distanceKm! * 1000).round()} m'
        : '${_distanceKm!.toStringAsFixed(1)} km';
    final eta = _etaMinutes >= 60
        ? '${_etaMinutes ~/ 60}h ${_etaMinutes % 60}min'
        : '$_etaMinutes min';
    return '~$eta · $dist';
  }

  // ── Recentrage ───────────────────────────────────────────────

  void _recenter() {
    if (_currentPosition == null) return;
    setState(() => _following = true);
    _mapController.move(_currentPosition!, 15);
  }

  // ── Statut mission ───────────────────────────────────────────

  void _updateStatus(MissionStatus newStatus) {
    context.read<MissionProvider>().updateMissionStatus(_mission.id, newStatus);
    final notifProvider = context.read<NotificationProvider>();

    final (title, body) = switch (newStatus) {
      MissionStatus.onTheWay => (
          'Prestataire en route',
          '${_mission.assignedPresta?.name ?? 'Votre prestataire'} est en route pour "${_mission.title}"',
        ),
      MissionStatus.inProgress => (
          'Mission demarree',
          '"${_mission.title}" est maintenant en cours',
        ),
      MissionStatus.completionRequested => (
          'Fin de mission signalee',
          '"${_mission.title}" attend maintenant la reponse du client',
        ),
      _ => ('', ''),
    };

    if (title.isNotEmpty) {
      notifProvider.addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotifType.mission,
          title: title,
          body: body,
          timeAgo: 'A l\'instant',
        ),
      );
    }

    setState(() => _mission = _mission.copyWith(status: newStatus));
  }

  Future<void> _openStartCodeSheet() async {
    await showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      isScrollControlled: true,
      child: _StartCodeSheet(
        missionTitle: _mission.title,
        onSubmit: (code) async {
          final ok = await context
              .read<MissionProvider>()
              .unlockMissionStart(_mission.id, code);
          if (!mounted) return ok;
          if (ok) {
            showAppSnackBar(context, 'Code valide. Mission demarree.',
                icon: Icons.check_circle_rounded);
          }
          return ok;
        },
      ),
    );
  }

  String get _pageTitle => switch (_mission.status) {
        MissionStatus.confirmed => 'Pret pour le code',
        MissionStatus.onTheWay => 'En route',
        MissionStatus.inProgress => 'Mission en cours',
        MissionStatus.completionRequested => 'Fin signalee',
        MissionStatus.awaitingRelease => 'Mission terminee',
        _ => 'Suivi de mission',
      };

  @override
  Widget build(BuildContext context) {
    final liveMissions = context.watch<MissionProvider>().freelancerMissions;
    final live = liveMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => _mission,
    );
    if (live.status != _mission.status) _mission = live;

    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ── Carte réelle ───────────────────────────────────
          _RealMap(
            mapController: _mapController,
            currentPosition: _currentPosition,
            destinationLatLng: _destinationLatLng,
            onGesture: () {
              if (_following) setState(() => _following = false);
            },
          ),

          // ── Recentrer ──────────────────────────────────────
          if (!_following && _currentPosition != null)
            Positioned(
              bottom: screenHeight * 0.42,
              right: 16,
              child: _RecenterButton(onTap: _recenter),
            ),

          // ── Indicateur GPS ─────────────────────────────────
          if (_currentPosition == null && !_locationError)
            Positioned(
              top: topPadding + 64,
              left: 0,
              right: 0,
              child: Center(
                child: AppSurfaceCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: AppShadows.card,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.iosBlue,
                        ),
                      ),
                      AppGap.w8,
                      Text(
                        'Localisation en cours…',
                        style: context.text.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_locationError)
            Positioned(
              top: topPadding + 64,
              left: 16,
              right: 16,
              child: AppSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: context.colors.errorLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.card,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 18,
                      color: AppColors.urgent,
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        'Localisation non disponible. Vérifiez les permissions.',
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.urgent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bouton retour ──────────────────────────────────
          Positioned(
            top: topPadding + 4,
            left: 4,
            child: Padding(
              padding: AppInsets.a8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDesign.radiusFull),
                  onTap: () => Navigator.pop(context),
                  child: AppIconCircle(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 42,
                    iconSize: 18,
                    backgroundColor: context.colors.surface,
                    iconColor: context.colors.textPrimary,
                    boxShadow: AppShadows.button,
                  ),
                ),
              ),
            ),
          ),

          // ── Titre ─────────────────────────────────────────
          Positioned(
            top: topPadding + 12,
            left: 60,
            right: 60,
            child: Center(
              child: AppSurfaceCard(
                padding: AppInsets.h16v8,
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
                boxShadow: AppShadows.card,
                child: Text(
                  _pageTitle,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // ── Carte ETA flottante ────────────────────────────
          if (_distanceKm != null)
            Positioned(
              bottom: screenHeight * 0.41,
              left: 20,
              right: 20,
              child: _EtaCard(
                etaMinutes: _etaMinutes,
                distanceKm: _distanceKm!,
                color: _mission.status == MissionStatus.onTheWay
                    ? AppColors.iosBlue
                    : AppColors.primary,
                label: _mission.status == MissionStatus.onTheWay
                    ? 'Distance jusqu\'au client'
                    : 'Mission en cours',
              ),
            ),

          // ── Panneau bas ────────────────────────────────────
          AppScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.24,
            maxChildSize: 0.68,
            builder: (_, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              children: [
                _FreelancerTrackingPanel(
                  mission: _mission,
                  etaLabel: _distanceKm != null ? _etaLabel : null,
                  onStartRoute: _mission.status == MissionStatus.confirmed
                      ? () => _updateStatus(MissionStatus.onTheWay)
                      : null,
                  onEnterStartCode:
                      _mission.status == MissionStatus.confirmed ||
                              _mission.status == MissionStatus.onTheWay
                          ? _openStartCodeSheet
                          : null,
                  startCodeHint: _mission.startCode,
                  onCopyHint: _mission.startCode == null
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: _mission.startCode!),
                          );
                          if (context.mounted) {
                            showAppSnackBar(
                              context,
                              'Code copie pour test local',
                              icon: Icons.copy_rounded,
                            );
                          }
                        },
                  onFinishMission:
                      _mission.status == MissionStatus.inProgress
                          ? () =>
                              _updateStatus(MissionStatus.completionRequested)
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte réelle flutter_map ─────────────────────────────────────────────────

class _RealMap extends StatelessWidget {
  final MapController mapController;
  final LatLng? currentPosition;
  final LatLng? destinationLatLng;
  final VoidCallback onGesture;

  const _RealMap({
    required this.mapController,
    required this.currentPosition,
    required this.destinationLatLng,
    required this.onGesture,
  });

  @override
  Widget build(BuildContext context) {
    final center = currentPosition ??
        destinationLatLng ??
        const LatLng(46.6034, 1.8883);

    final routePoints = [
      if (currentPosition != null) currentPosition!,
      if (destinationLatLng != null) destinationLatLng!,
    ];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: currentPosition != null ? 15 : 12,
        onMapEvent: (event) {
          if (event is MapEventMoveStart &&
              event.source == MapEventSource.dragStart) {
            onGesture();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.inkern',
        ),
        if (routePoints.length == 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: AppColors.iosBlue.withValues(alpha: 0.55),
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (destinationLatLng != null)
              Marker(
                point: destinationLatLng!,
                width: 40,
                height: 52,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Container(width: 2, height: 12, color: AppColors.primary),
                  ],
                ),
              ),
            if (currentPosition != null)
              Marker(
                point: currentPosition!,
                width: 28,
                height: 28,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.iosBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.iosBlue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Bouton recentrer ─────────────────────────────────────────────────────────

class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppIconCircle(
        icon: Icons.my_location_rounded,
        size: 44,
        iconSize: 20,
        backgroundColor: Colors.white,
        iconColor: AppColors.iosBlue,
        boxShadow: AppShadows.card,
      ),
    );
  }
}

// ─── Code de démarrage (bottom sheet) ────────────────────────────────────────

class _StartCodeSheet extends StatefulWidget {
  final String missionTitle;
  final Future<bool> Function(String code) onSubmit;

  const _StartCodeSheet({
    required this.missionTitle,
    required this.onSubmit,
  });

  @override
  State<_StartCodeSheet> createState() => _StartCodeSheetState();
}

class _StartCodeSheetState extends State<_StartCodeSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Entrez un code a 6 chiffres.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await widget.onSubmit(code);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _loading = false;
      _error = 'Code invalide. Verifiez avec le client.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: AppFormSheet(
        title: 'Entrer le code client',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demandez au client le code de demarrage pour lancer "${widget.missionTitle}".',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.45,
              ),
            ),
            AppGap.h18,
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
              ),
              decoration: AppInputDecorations.formField(
                context,
                hintText: '000000',
                errorText: _error,
              ),
            ),
          ],
        ),
        footer: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _verify,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verifier le code'),
          ),
        ),
      ),
    );
  }
}

// ─── Panneau de suivi ─────────────────────────────────────────────────────────

class _FreelancerTrackingPanel extends StatelessWidget {
  final Mission mission;
  final String? etaLabel;
  final VoidCallback? onStartRoute;
  final VoidCallback? onEnterStartCode;
  final VoidCallback? onFinishMission;
  final String? startCodeHint;
  final VoidCallback? onCopyHint;

  const _FreelancerTrackingPanel({
    required this.mission,
    this.etaLabel,
    this.onStartRoute,
    this.onEnterStartCode,
    this.onFinishMission,
    this.startCodeHint,
    this.onCopyHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: mission.status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                mission.status.icon,
                color: mission.status.color,
                size: 28,
              ),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      MissionStatusBadge(
                        status: mission.status,
                        compact: true,
                      ),
                      if (etaLabel != null &&
                          mission.status == MissionStatus.onTheWay) ...[
                        AppGap.w10,
                        Text(
                          etaLabel!,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.iosBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        AppGap.h18,
        AppSurfaceCard(
          padding: AppInsets.a14,
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDesign.radius14),
          child: Row(
            children: [
              Icon(
                mission.status == MissionStatus.inProgress
                    ? Icons.handyman_rounded
                    : Icons.password_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              AppGap.w10,
              Expanded(
                child: Text(
                  switch (mission.status) {
                    MissionStatus.confirmed =>
                      'Partez vers le client puis demandez le code a 6 chiffres une fois sur place.',
                    MissionStatus.onTheWay =>
                      'Quand vous arrivez, entrez le code donne par le client pour demarrer la mission.',
                    MissionStatus.inProgress =>
                      'La mission est en cours. Terminez-la ici a la fin de l intervention.',
                    MissionStatus.completionRequested =>
                      'Vous avez signale la fin. Le client doit maintenant confirmer ou contester.',
                    _ => 'Le suivi de mission est termine.',
                  },
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (startCodeHint != null &&
            (mission.status == MissionStatus.confirmed ||
                mission.status == MissionStatus.onTheWay)) ...[
          AppGap.h12,
          Row(
            children: [
              Expanded(
                child: Text(
                  'Test local: code ${startCodeHint!.substring(0, 3)} ${startCodeHint!.substring(3)}',
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              if (onCopyHint != null)
                TextButton(
                  onPressed: onCopyHint,
                  child: const Text('Copier'),
                ),
            ],
          ),
        ],
        AppGap.h16,
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: AppColors.urgent,
            ),
            AppGap.w6,
            Expanded(
              child: Text(
                mission.address.fullAddress,
                style: context.text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AppGap.h18,
        if (onStartRoute != null)
          _TrackingPrimaryButton(
            label: 'Je suis en route',
            icon: Icons.navigation_rounded,
            onTap: onStartRoute!,
          ),
        if (onEnterStartCode != null) ...[
          if (onStartRoute != null) AppGap.h10,
          _TrackingPrimaryButton(
            label: 'Entrer le code client',
            icon: Icons.password_rounded,
            onTap: onEnterStartCode!,
          ),
        ],
        if (onFinishMission != null) ...[
          AppGap.h10,
          _TrackingPrimaryButton(
            label: 'J ai termine',
            icon: Icons.check_circle_rounded,
            onTap: onFinishMission!,
          ),
        ],
      ],
    );
  }
}

// ─── Carte ETA flottante ──────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  final int etaMinutes;
  final double distanceKm;
  final Color color;
  final String label;

  const _EtaCard({
    required this.etaMinutes,
    required this.distanceKm,
    required this.color,
    required this.label,
  });

  String get _timeLabel {
    if (etaMinutes >= 60) return '${etaMinutes ~/ 60}h ${etaMinutes % 60}min';
    return '$etaMinutes min';
  }

  String get _distLabel => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule_rounded, color: color, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                AppGap.h2,
                Text(
                  _timeLabel,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _distLabel,
              style: context.text.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TrackingPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
