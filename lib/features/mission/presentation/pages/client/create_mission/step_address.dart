import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../../../../core/design/app_design_system.dart';

/// ─────────────────────────────────────────────────────────────
/// 📍 Step 4 — Adresse avec carte dynamique
/// ─────────────────────────────────────────────────────────────
class StepAddress extends StatefulWidget {
  final String address;
  final Function(String) onAddressChanged;

  const StepAddress({
    super.key,
    required this.address,
    required this.onAddressChanged,
  });

  @override
  State<StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<StepAddress> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final MapController _mapController = MapController();

  LatLng _mapCenter = const LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _selectedLatLng;
  List<_Place> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.address;
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _showSuggestions = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Géocodage Nominatim ───────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );
      final resp = await http.get(uri, headers: {
        'Accept-Language': 'fr',
        'User-Agent': 'HomserviceApp/1.0',
      });

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _suggestions = data.map((e) => _Place.fromJson(e)).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (_) {
      // Erreur réseau silencieuse
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectPlace(_Place place) {
    _ctrl.text = place.displayName;
    widget.onAddressChanged(place.displayName);
    _focus.unfocus();

    setState(() {
      _selectedLatLng = LatLng(place.lat, place.lon);
      _mapCenter = _selectedLatLng!;
      _showSuggestions = false;
      _suggestions = [];
    });

    _mapController.move(_selectedLatLng!, 15);
  }

  void _clearSelection() {
    _ctrl.clear();
    widget.onAddressChanged('');
    setState(() {
      _selectedLatLng = null;
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _useCurrentLocation() {
    const current = LatLng(48.8566, 2.3522);
    _ctrl.text = 'Paris, France';
    widget.onAddressChanged(_ctrl.text);
    _focus.unfocus();
    setState(() {
      _selectedLatLng = current;
      _mapCenter = current;
      _showSuggestions = false;
      _suggestions = [];
    });
    _mapController.move(current, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Carte ─────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 13,
            onTap: (_, __) {
              _focus.unfocus();
              setState(() => _showSuggestions = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.homservice',
            ),
            if (_selectedLatLng != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng!,
                    width: 48,
                    height: 56,
                    child: const _MapPin(),
                  ),
                ],
              ),
          ],
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.white.withValues(alpha: 0.14), Colors.transparent],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),

        // ── Barre de recherche (flottante en haut) ────────────
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              _SearchBar(
                controller: _ctrl,
                focusNode: _focus,
                isSearching: _isSearching,
                hasValue: _ctrl.text.isNotEmpty,
                onChanged: (v) {
                  widget.onAddressChanged(v);
                  _search(v);
                  setState(() => _showSuggestions = v.isNotEmpty);
                },
                onClear: _clearSelection,
              ),

              // ── Suggestions ───────────────────────────────
              if (_showSuggestions && _suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDesign.radius14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _suggestions.asMap().entries.map((e) {
                        final i = e.key;
                        final place = e.value;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _selectPlace(place),
                              child: Padding(
                                padding: AppInsets.h16v12,
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 18,
                                        color: AppColors.primary),
                                    AppGap.w12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.name,
                                            style: TextStyle(fontSize: AppFontSize.baseHalf, fontWeight: FontWeight.w600, color: AppColors.inkDark),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            place.subtitle,
                                            style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < _suggestions.length - 1)
                              Divider(
                                  height: 1, color: context.colors.divider),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          left: 16,
          right: 16,
          bottom: _selectedLatLng != null && !_showSuggestions ? 96 : 30,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: OutlinedButton.icon(
              onPressed: _useCurrentLocation,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: BorderSide(color: context.colors.border, width: 1),
                backgroundColor: Colors.white.withValues(alpha: 0.94),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.my_location_outlined, size: 18),
              label: Text(
                'Utiliser ma position actuelle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray700,
                ),
              ),
            ),
          ),
        ),

        if (_selectedLatLng != null && !_showSuggestions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SelectedAddressCard(
              address: _ctrl.text,
              onEdit: () => _focus.requestFocus(),
            ),
          ),
      ],
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final bool hasValue;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.hasValue,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 20, 24, 0.06),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: AppInputDecorations.formField(
          context,
          hintText: 'Rechercher une adresse...',
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: context.colors.textTertiary,
          ),
          prefixIcon: isSearching
              ? Padding(
                  padding: AppInsets.a14,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : Icon(
                  Icons.search_outlined,
                  color: context.colors.textSecondary,
                  size: 20,
                ),
          suffixIcon: hasValue
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: context.colors.textHint, size: 20),
                  onPressed: onClear,
                )
              : null,
          contentPadding: AppInsets.h16v16,
          noBorder: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.stepBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(24, 71, 168, 0.24),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.place_outlined,
              color: Colors.white, size: 16),
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
      ..color = AppColors.stepBlue
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

class _SelectedAddressCard extends StatelessWidget {
  final String address;
  final VoidCallback onEdit;

  const _SelectedAddressCard({
    required this.address,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 20, 24, 0.08),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: AppColors.inkDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 18),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse sélectionnée',
                  style: TextStyle(fontSize: AppFontSize.xsHalf, fontWeight: FontWeight.w500, color: AppColors.gray600),
                ),
                AppGap.h2,
                Text(
                  address,
                  style: TextStyle(fontSize: AppFontSize.baseHalf, fontWeight: FontWeight.w600, color: AppColors.inkDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded,
                size: 18, color: context.colors.textSecondary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// ── Modèle de lieu ────────────────────────────────────────────

class _Place {
  final String displayName;
  final String name;
  final String subtitle;
  final double lat;
  final double lon;

  _Place({
    required this.displayName,
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lon,
  });

  factory _Place.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final name = (json['name'] as String?)?.isNotEmpty == true
        ? json['name'] as String
        : (address['road'] as String?) ??
            (json['display_name'] as String).split(',').first;

    final parts = <String>[];
    if (address['city'] != null) parts.add(address['city'] as String);
    if (address['postcode'] != null) parts.add(address['postcode'] as String);
    if (address['country'] != null) parts.add(address['country'] as String);

    return _Place(
      displayName: json['display_name'] as String,
      name: name,
      subtitle: parts.join(', '),
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }
}
