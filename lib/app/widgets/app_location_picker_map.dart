import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/design/app_design_system.dart';
import '../../core/location/nominatim_service.dart';

class AppLocationSelection {
  final LatLng latLng;
  final String address;

  const AppLocationSelection({
    required this.latLng,
    required this.address,
  });
}

class AppLocationPickerMap extends StatefulWidget {
  final LatLng? initialLatLng;
  final String initialAddress;
  final ValueChanged<AppLocationSelection> onChanged;
  final double height;
  final String searchHintText;
  final String emptyLabel;
  final String tapHintText;

  const AppLocationPickerMap({
    super.key,
    required this.initialLatLng,
    required this.initialAddress,
    required this.onChanged,
    this.height = 220,
    this.searchHintText = 'Rechercher une adresse…',
    this.emptyLabel = 'Aucune localisation définie',
    this.tapHintText = 'Appuyez pour poser le pin',
  });

  @override
  State<AppLocationPickerMap> createState() => _AppLocationPickerMapState();
}

class _AppLocationPickerMapState extends State<AppLocationPickerMap> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng _center = const LatLng(48.8566, 2.3522);
  LatLng? _pin;
  String _displayAddress = '';
  bool _isSearching = false;
  bool _isReversing = false;
  List<NominatimPlace> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _hydrateInitialState();
  }

  @override
  void didUpdateWidget(covariant AppLocationPickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latLngChanged = oldWidget.initialLatLng != widget.initialLatLng;
    final addressChanged = oldWidget.initialAddress != widget.initialAddress;
    if (latLngChanged || addressChanged) {
      _hydrateInitialState();
    }
  }

  void _hydrateInitialState() {
    _pin = widget.initialLatLng;
    _center = widget.initialLatLng ?? const LatLng(48.8566, 2.3522);
    _displayAddress = widget.initialAddress;
    _searchCtrl.text = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = const [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await NominatimService.search(query, limit: 5);
      if (!mounted) return;
      setState(() => _suggestions = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(NominatimPlace place) {
    setState(() {
      _pin = place.latLng;
      _center = place.latLng;
      _displayAddress = place.shortAddress;
      _suggestions = const [];
      _searchCtrl.text = place.shortAddress;
    });
    _mapController.move(place.latLng, 14);
    _searchFocus.unfocus();
    widget.onChanged(
      AppLocationSelection(latLng: place.latLng, address: place.shortAddress),
    );
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _isReversing = true);
    try {
      final place = await NominatimService.reverse(latLng);
      if (!mounted || place == null) return;
      setState(() {
        _displayAddress = place.shortAddress;
        _searchCtrl.text = place.shortAddress;
      });
      widget.onChanged(
        AppLocationSelection(latLng: latLng, address: place.shortAddress),
      );
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _isReversing = false);
    }
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    setState(() {
      _pin = latLng;
      _center = latLng;
      _suggestions = const [];
    });
    _searchFocus.unfocus();
    _reverseGeocode(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: _searchFocus.hasFocus
                      ? AppColors.primary
                      : context.colors.border,
                  width: _searchFocus.hasFocus ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: AppInsets.h12,
                    child: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: context.colors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: widget.searchHintText,
                        hintStyle: context.text.bodySmall?.copyWith(
                          color: context.colors.textHint,
                        ),
                        contentPadding: AppInsets.v13,
                        noBorder: true,
                        fillColor: Colors.transparent,
                      ).copyWith(isDense: true),
                      onChanged: _searchAddress,
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: AppInsets.h12,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _suggestions = const []);
                      },
                      child: Padding(
                        padding: AppInsets.h12,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: context.colors.textHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              AppGap.h8,
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: _suggestions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final suggestion = entry.value;
                    final short = suggestion.shortAddress.split(',').first.trim();
                    final rest = suggestion.shortAddress
                        .split(',')
                        .skip(1)
                        .join(',')
                        .trim();

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _selectSuggestion(suggestion),
                          child: Padding(
                            padding: AppInsets.h12v10,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                AppGap.w10,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        short,
                                        style: context.text.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (rest.isNotEmpty)
                                        Text(
                                          rest,
                                          style: context.text.labelSmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < _suggestions.length - 1)
                          Divider(height: 1, color: context.colors.divider),
                      ],
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ],
        ),
        AppGap.h12,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _pin != null ? 13 : 11,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.inkern',
                    ),
                    if (_pin != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pin!,
                            width: 44,
                            height: 52,
                            child: const _LocationPickerPin(),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_pin == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: AppInsets.h14v8,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              AppGap.w6,
                              Text(
                                widget.tapHintText,
                                style: context.text.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isReversing)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: AppInsets.a8,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppGap.h10,
        Container(
          padding: AppInsets.a12,
          decoration: BoxDecoration(
            color: _displayAddress.isNotEmpty
                ? AppColors.secondary
                : context.colors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: _displayAddress.isNotEmpty
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : context.colors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _displayAddress.isNotEmpty
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 16,
                color: _displayAddress.isNotEmpty
                    ? AppColors.primary
                    : context.colors.textHint,
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  _displayAddress.isNotEmpty
                      ? _displayAddress
                      : widget.emptyLabel,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: _displayAddress.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _displayAddress.isNotEmpty
                        ? AppColors.primary
                        : context.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPickerPin extends StatelessWidget {
  const _LocationPickerPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.mapPin,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.mapPin.withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
        CustomPaint(
          size: const Size(12, 10),
          painter: _LocationPickerPinTailPainter(),
        ),
      ],
    );
  }
}

class _LocationPickerPinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mapPin
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
