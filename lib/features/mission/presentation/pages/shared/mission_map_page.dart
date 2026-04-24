import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission_address.dart';
import '../../../../../core/design/app_design_system.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📍 Inkern - Page Carte — Lieu d'intervention
/// ═══════════════════════════════════════════════════════════════════════════

class MissionMapPage extends StatefulWidget {
  final MissionAddress address;

  const MissionMapPage({super.key, required this.address});

  @override
  State<MissionMapPage> createState() => _MissionMapPageState();
}

class _MissionMapPageState extends State<MissionMapPage> {
  gmaps.GoogleMapController? _mapController;

  ll.LatLng _center = const ll.LatLng(48.8566, 2.3522);
  ll.LatLng? _pinLatLng;
  bool _loading = false;
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.address.latitude != null && widget.address.longitude != null) {
      _pinLatLng = ll.LatLng(widget.address.latitude!, widget.address.longitude!);
      _center = _pinLatLng!;
    } else {
      _geocode();
    }
  }

  Future<void> _geocode() async {
    final query = widget.address.fullAddress;
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final place = await NominatimService.geocodeSingle(query);
      if (!mounted) return;
      if (place == null) return;
      setState(() {
        _pinLatLng = place.latLng;
        _center = place.latLng;
      });
      await _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(_center.latitude, _center.longitude),
          14.2,
        ),
      );
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _focusMap() async {
    final target = _pinLatLng ?? _center;
    await _mapController?.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(target.latitude, target.longitude),
        15.6,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 170));
    if (!mounted) return;
    setState(() => _sheetVisible = true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: Stack(
        children: [
          // ── Carte plein écran ──────────────────────────────────────────
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: gmaps.LatLng(_center.latitude, _center.longitude),
              zoom: 14.0,
            ),
            mapType: gmaps.MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => _focusMap(),
            markers: _pinLatLng == null
                ? const <gmaps.Marker>{}
                : {
                    gmaps.Marker(
                      markerId: const gmaps.MarkerId('mission'),
                      position: gmaps.LatLng(
                        _pinLatLng!.latitude,
                        _pinLatLng!.longitude,
                      ),
                    ),
                  },
          ),

          // ── Loader géocodage ──────────────────────────────────────────
          if (_loading)
            const Center(
              child: Card(
                child: Padding(
                  padding: AppInsets.a16,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    stops: [0.0, 0.22, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: topPadding + 8,
            left: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.colors.textTertiary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            bottom: _sheetVisible ? 0 : -220,
            left: 0,
            right: 0,
            child: _AddressCard(address: widget.address.fullAddress),
          ),
        ],
      ),
    );
  }
}

// ── Carte adresse ──────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final String address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 28,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.location_on_outlined, color: AppColors.mapPin, size: 18),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lieu d'intervention",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
