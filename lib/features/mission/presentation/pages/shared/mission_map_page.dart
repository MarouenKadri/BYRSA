import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(48.8566, 2.3522);
  LatLng? _pinLatLng;
  bool _loading = false;
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.address.latitude != null && widget.address.longitude != null) {
      _pinLatLng = LatLng(widget.address.latitude!, widget.address.longitude!);
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
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final resp = await http.get(uri, headers: {
        'Accept-Language': 'fr',
        'User-Agent': 'HomserviceApp/1.0',
      });
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat'] as String);
          final lon = double.parse(data[0]['lon'] as String);
          setState(() {
            _pinLatLng = LatLng(lat, lon);
            _center = _pinLatLng!;
          });
          _mapController.move(_center, 15.4);
        }
      }
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _focusMap() async {
    final target = _pinLatLng ?? _center;
    _mapController.move(target, 16.8);
    await Future.delayed(const Duration(milliseconds: 170));
    if (!mounted) return;
    setState(() => _sheetVisible = true);
  }

  @override
  void dispose() {
    _mapController.dispose();
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.2,
              onTap: (_, __) => _focusMap(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.homservice',
              ),
              if (_pinLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinLatLng!,
                      width: 48,
                      height: 56,
                      child: const _MapPin(),
                    ),
                  ],
                ),
            ],
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x40FFFFFF), Color(0x00FFFFFF), Color(0x0DFFFFFF)],
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
                  BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 8)),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF8E98A4)),
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

// ── Pin ────────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF173B78),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24173B78),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
        ),
        CustomPaint(
          size: const Size(12, 10),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF173B78)
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
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
                color: Color(0x14000000),
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
                child: Icon(Icons.location_on_outlined, color: Color(0xFF173B78), size: 18),
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
                        color: const Color(0xFF98A1AC),
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
