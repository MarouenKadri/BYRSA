import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/design/app_design_system.dart';
import '../../core/design/app_primitives.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../../features/notifications/notification_provider.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/profile_provider.dart';

// ─────────────────────────────────────────────────────────────
// Données de localisation sélectionnée
// ─────────────────────────────────────────────────────────────
class LocationData {
  final IconData icon;
  final String label;
  final String subtitle;

  const LocationData({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}

class AppLocationRoleBar extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String locationLabel;
  final int unreadCount;
  final String avatarLabel;

  final VoidCallback onLocationTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAvatarTap;
  final Animation<double>? bellScale;

  const AppLocationRoleBar({
    super.key,
    this.bottom,
    required this.locationLabel,
    required this.unreadCount,
    required this.avatarLabel,

    required this.onLocationTap,
    required this.onNotificationsTap,
    required this.onAvatarTap,
    this.bellScale,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        AppBarMetrics.toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final resolvedLocation = locationLabel.trim().isEmpty ||
            locationLabel.trim().toLowerCase() == 'ma position'
        ? 'Paris, France'
        : locationLabel;

    return AppPageAppBar(
      toolbarHeight: AppBarMetrics.toolbarHeight,
      bottom: bottom,
      titleWidget: GestureDetector(
        onTap: onLocationTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: context.colors.textSecondary,
            ),
            AppGap.w8,
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBarMetrics.locationMaxWidth,
              ),
              child: Text(
                resolvedLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppBarActionCircleButton(
          icon: unreadCount > 0
              ? Icons.notifications_none_rounded
              : Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          size: 34,
          iconSize: 20,
          backgroundColor: Colors.transparent,
          iconColor: context.colors.textSecondary,
          badgeLabel:
              unreadCount > 0 ? (unreadCount > 99 ? '99+' : '$unreadCount') : null,
          badgeColor: AppColors.urgent,
          scale: bellScale,
        ),
        AppBarActionCircleButton(
          icon: Icons.person_outline_rounded,
          onTap: onAvatarTap,
          size: 34,
          iconSize: 20,
          backgroundColor: Colors.transparent,
          iconColor: context.colors.textSecondary,
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class LocationAppBarCoordinator {
  const LocationAppBarCoordinator._();

  static Future<LocationData?> pickLocation(
    BuildContext context, {
    required String? currentAddress,
    LocationData? selectedLocation,
  }) {
    final current = selectedLocation?.label ?? parseCity(currentAddress);
    final initType = selectedLocation?.icon == Icons.location_on_rounded ||
            selectedLocation?.icon == Icons.location_city_rounded
        ? LocationType.other
        : LocationType.current;
    final previousOther =
        initType == LocationType.other ? selectedLocation?.label : null;

    return Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationSearchPage(
          currentCity: current,
          initialType: initType,
          initialOtherAddress: previousOther,
        ),
      ),
    );
  }

  static Future<void> openNotifications(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  static Future<void> openRoleSheet(
    BuildContext context, {
    required String firstName,
    VoidCallback? onGoToAccount,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      wrapWithSurface: false,
      child: RoleSwitchSheet(
        avatarUrl: '',
        firstName: firstName,
        onGoToAccount: onGoToAccount,
      ),
    );
  }

  static String parseCity(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'Ma position';
    }
    final parts = address.split(',');
    final city = parts.last.trim();
    return city.isEmpty ? address.trim() : city;
  }
}

// ─────────────────────────────────────────────────────────────
// LocationAppBar — barre de navigation avec localisation,
// cloche de notifications et switch de rôle via avatar.
// Accepte un paramètre [bottom] (ex: AppSegmentedTabBar) optionnel.
// ─────────────────────────────────────────────────────────────

class LocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final VoidCallback? onGoToAccount;

  const LocationAppBar({super.key, this.bottom, this.onGoToAccount});

  @override
  Size get preferredSize => Size.fromHeight(
        AppBarMetrics.toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  State<LocationAppBar> createState() => _LocationAppBarState();
}

class _LocationAppBarState extends State<LocationAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellScale;
  int _prevUnread = 0;

  // Localisation sélectionnée localement
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppBarMetrics.bellAnimationMs),
    );
    _bellScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLocationSearch(BuildContext context, String? currentAddress) async {
    final result = await LocationAppBarCoordinator.pickLocation(
      context,
      currentAddress: currentAddress,
      selectedLocation: _locationData,
    );
    if (!mounted || result == null) return;
    setState(() => _locationData = result);
  }

  @override
  Widget build(BuildContext context) {
    final profile   = context.watch<ProfileProvider>().profile;
    final unread    = context.watch<NotificationProvider>().unreadCount;
    final auth      = context.watch<AuthProvider>();
    final isClient  = auth.currentRole == UserRole.client;
    final address   = profile?.address;
    final firstName = profile?.firstName ?? '';
    final avatarLabel = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : (isClient ? 'C' : 'F');

    final locLabel =
        _locationData?.label ?? LocationAppBarCoordinator.parseCity(address);

    if (unread > _prevUnread) _bellCtrl.forward(from: 0);
    _prevUnread = unread;

    return AppLocationRoleBar(
      bottom: widget.bottom,
      locationLabel: locLabel,
      unreadCount: unread,
      avatarLabel: avatarLabel,

      bellScale: _bellScale,
      onLocationTap: () => _openLocationSearch(context, address),
      onNotificationsTap: () => LocationAppBarCoordinator.openNotifications(
        context,
      ),
      onAvatarTap: () => LocationAppBarCoordinator.openRoleSheet(
        context,
        firstName: firstName,
        onGoToAccount: widget.onGoToAccount,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom sheet — switch de rôle (style location picker)
// ─────────────────────────────────────────────────────────────
class RoleSwitchSheet extends StatelessWidget {
  final String firstName;
  final VoidCallback? onGoToAccount;

  const RoleSwitchSheet({
    super.key,
    required this.firstName,
    String? avatarUrl, // kept for compatibility, unused
    this.onGoToAccount,
  });


  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isClient  = auth.currentRole == UserRole.client;
    final isLoading = auth.isLoading;
    return AppActionSheet(
      title: 'Mode',
      header: Padding(
        padding: AppInsets.h20,
        child: GestureDetector(
          onTap: onGoToAccount != null
              ? () {
                  Navigator.pop(context);
                  onGoToAccount!();
                }
              : null,
          child: Row(
            children: [
              AppInitialCircle(
                label: firstName.isNotEmpty
                    ? firstName[0].toUpperCase()
                    : (isClient ? 'C' : 'F'),
                size: AppBarMetrics.sheetAvatarSize,
                fontSize: AppBarMetrics.sheetAvatarFontSize,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                foregroundColor: AppColors.snow,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.5,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isNotEmpty ? firstName : 'Mon compte',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.snow,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      isClient ? 'Mode Client actif' : 'Mode Prestataire actif',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      children: [
        const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
        AppGap.h8,
        _RoleItem(
          icon: Icons.person_outline_rounded,
          label: 'Client',
          subtitle: 'Trouvez des prestataires',
          isSelected: isClient,
          onTap: isClient || isLoading ? null : () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().switchRole(UserRole.client);
          },
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
        _RoleItem(
          icon: Icons.handyman_outlined,
          label: 'Prestataire',
          subtitle: 'Proposez vos services',
          isSelected: !isClient,
          onTap: !isClient || isLoading ? null : () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().switchRole(UserRole.provider);
          },
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(size: AppBarMetrics.loadingIndicatorSize),
                AppGap.w8,
                const Text(
                  'Changement en cours...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RoleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: isSelected ? AppColors.snow : const Color(0xFFD5DADE),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.snow,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.snow,
              ),
          ],
        ),
      ),
    );
  }
}

// Kept for external compatibility — no longer used internally
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}


// ─────────────────────────────────────────────────────────────
// LocationSheet — bottom sheet style TGTG
// ─────────────────────────────────────────────────────────────

enum LocationType { current, other }

class _NominatimResult {
  final String displayName;
  final String shortName;
  final double lat;
  final double lon;

  _NominatimResult({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lon,
  });

  factory _NominatimResult.fromJson(Map<String, dynamic> j) {
    final parts = (j['display_name'] as String).split(',');
    return _NominatimResult(
      displayName: j['display_name'] as String,
      shortName: parts.first.trim(),
      lat: double.parse(j['lat'] as String),
      lon: double.parse(j['lon'] as String),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Page plein écran — carte + recherche (style TGTG)
// ─────────────────────────────────────────────────────────────
class LocationSearchPage extends StatefulWidget {
  final String currentCity;
  final LocationType initialType;
  final String? initialOtherAddress;
  const LocationSearchPage({
    super.key,
    required this.currentCity,
    this.initialType = LocationType.current,
    this.initialOtherAddress,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> with SingleTickerProviderStateMixin {

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode             _focusNode  = FocusNode();
  final MapController         _mapCtrl    = MapController();

  LatLng _center    = const LatLng(46.6034, 1.8883); // Centre France
  LatLng? _pin;

  bool                   _isSearching     = false;
  bool                   _loadingResults  = false;
  bool                   _loadingLocation = false;
  List<_NominatimResult> _results         = [];
  Timer?                 _debounce;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  late LocationType _selected;
  String? _otherAddress;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialType;
    _otherAddress = widget.initialOtherAddress;
    _searchCtrl.addListener(_onQueryChanged);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _mapCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _searchCtrl.text.trim();
    setState(() => _isSearching = q.isNotEmpty);
    _debounce?.cancel();
    if (q.isEmpty) { setState(() => _results = []); return; }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String query) async {
    setState(() => _loadingResults = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=6&countrycodes=fr&addressdetails=0',
      );
      final resp = await http.get(uri, headers: {
        'Accept-Language': 'fr',
        'User-Agent': 'InkernApp/1.0',
      });
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() => _results =
            data.map((d) => _NominatimResult.fromJson(d as Map<String, dynamic>)).toList());
        if (_results.isNotEmpty) {
          final first = _results.first;
          final latlng = LatLng(first.lat, first.lon);
          setState(() { _pin = latlng; _center = latlng; });
          _mapCtrl.move(latlng, 12);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingResults = false);
    }
  }

  void _selectResult(_NominatimResult r) {
    final latlng = LatLng(r.lat, r.lon);
    final subtitle = r.displayName.split(',').skip(1).take(2).join(',').trim();
    setState(() {
      _pin = latlng;
      _center = latlng;
      _otherAddress = '${r.shortName}${subtitle.isNotEmpty ? ', $subtitle' : ''}';
      _selected = LocationType.other;
    });
    _mapCtrl.move(latlng, 13);
    Navigator.pop(context, LocationData(
      icon: Icons.location_on_rounded,
      label: r.shortName,
      subtitle: subtitle,
    ));
  }

  Future<void> _selectCurrentPosition() async {
    setState(() { _selected = LocationType.current; _loadingLocation = true; });
    try {
      // Vérifier/demander permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        Navigator.pop(context, const LocationData(
          icon: Icons.my_location_rounded,
          label: 'Position actuelle',
          subtitle: '',
        ));
        return;
      }

      // Obtenir coordonnées
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;

      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() { _pin = latlng; _center = latlng; });
      _mapCtrl.move(latlng, 14);

      // Reverse geocoding Nominatim
      String city = 'Position actuelle';
      String subtitle = '';
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${pos.latitude}&lon=${pos.longitude}'
          '&format=json&accept-language=fr',
        );
        final resp = await http.get(uri, headers: {
          'Accept-Language': 'fr',
          'User-Agent': 'InkernApp/1.0',
        });
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final addr = data['address'] as Map<String, dynamic>?;
          if (addr != null) {
            city = (addr['city'] ?? addr['town'] ?? addr['village'] ??
                addr['municipality'] ?? 'Position actuelle') as String;
            final postcode = addr['postcode'] ?? '';
            final country = addr['country'] ?? '';
            subtitle = [postcode, country]
                .where((s) => (s as String).isNotEmpty)
                .join(', ');
          }
        }
      } catch (_) {}

      if (!mounted) return;
      Navigator.pop(context, LocationData(
        icon: Icons.my_location_rounded,
        label: city,
        subtitle: subtitle,
      ));
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context, const LocationData(
        icon: Icons.my_location_rounded,
        label: 'Position actuelle',
        subtitle: '',
      ));
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _selectOtherAddress(String address) {
    setState(() => _selected = LocationType.other);
    Navigator.pop(context, LocationData(
      icon: Icons.location_on_rounded,
      label: address.split(',').first.trim(),
      subtitle: address.contains(',')
          ? address.split(',').skip(1).join(',').trim()
          : '',
    ));
  }

  InputDecoration _searchDecoration(BuildContext context) =>
      AppInputDecorations.formField(
        context,
        hintText: 'Rechercher...',
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8C96A3),
        ),
        prefixIcon: const Icon(
          Icons.search_outlined,
          color: Color(0xFF7D8794),
          size: 19,
        ),
        suffixIcon: _isSearching
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF7D8794),
                  size: 18,
                ),
                onPressed: () {
                  _searchCtrl.clear();
                  _focusNode.requestFocus();
                },
              )
            : null,
        fillColor: Colors.white.withValues(alpha: 0.42),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        radius: 24,
        noBorder: true,
      );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF4F4F2),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.9, 0.0, 0.0, 0.0, 10,
                    0.0, 0.9, 0.0, 0.0, 10,
                    0.0, 0.0, 0.9, 0.0, 10,
                    0.0, 0.0, 0.0, 1.0, 0,
                  ]),
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(initialCenter: _center, initialZoom: 6),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.inkern',
                      ),
                      if (_pin != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: _pin!,
                            width: AppBarMetrics.mapPinMarkerSize,
                            height: AppBarMetrics.mapPinMarkerSize,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIconCircle(
                                  icon: Icons.location_on_rounded,
                                  size: AppBarMetrics.mapPinIconSize,
                                  iconSize: AppBarMetrics.mapPinInnerIconSize,
                                  backgroundColor: const Color(0xFF222222),
                                  iconColor: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.12),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                const CustomPaint(
                                  size: Size(12, 6),
                                  painter: _PinTailPainter(Color(0xFF222222)),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xDDF8F8F6), Color(0x00F8F8F6), Color(0x14F8F8F6)],
                          stops: [0.0, 0.18, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(height: top + 76, color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                ),
                Positioned(
                  top: top + AppBarMetrics.mapTopInset,
                  left: AppBarMetrics.mapSideInset,
                  child: AppBarActionCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                    size: AppBarMetrics.mapBackButtonSize,
                    iconSize: AppBarMetrics.mapBackButtonIconSize,
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    iconColor: const Color(0xFF1A1A1A),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppBarSheetSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppBottomSheetHandle(),
                const SizedBox(height: 8),
                Text(
                  'Lieu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF20242B),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F4).withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(255, 255, 255, 0.85),
                          offset: Offset(-2, -2),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(15, 23, 42, 0.05),
                          offset: Offset(2, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFF20242B)),
                      decoration: _searchDecoration(context),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_isSearching) _buildRecentPlaces(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.30,
                  ),
                  child: _isSearching ? _buildResults() : _buildAddressList(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 16 + MediaQuery.of(context).padding.bottom),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Fermer', style: context.appBarSheetActionStyle),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Liste résultats Nominatim ──────────────────────────────
  Widget _buildResults() {
    if (_loadingResults) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: AppBarMetrics.emptyStateIconSize,
              color: context.colors.border,
            ),
            AppGap.h10,
            Text(
              'Aucun résultat',
              style: context.appBarEmptyStateStyle,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: AppInsets.h16v4,
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(
          height: 1, thickness: 1, color: context.colors.divider),
      itemBuilder: (_, i) {
        final r = _results[i];
        return AppBarOptionTile(
          onTap: () => _selectResult(r),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Icon(Icons.place_outlined, size: 20, color: const Color(0xFF6B7280)),
          title: r.shortName,
          subtitle: r.displayName,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: context.colors.textHint,
            size: 18,
          ),
        );
      },
    );
  }

  // ── Liste adresses sauvegardées ────────────────────────────
  Widget _buildAddressList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AddrItem(
            icon: Icons.my_location_outlined,
            label: 'Position actuelle',
            isSelected: _selected == LocationType.current,
            isLoading: _loadingLocation,
            teal: const Color(0xFF111827), tealLight: Colors.transparent,
            pulse: _pulseScale,
            onTap: _loadingLocation ? null : _selectCurrentPosition,
          ),
          Divider(height: 1, thickness: 1, color: context.colors.divider.withValues(alpha: 0.6), indent: 16, endIndent: 16),
          _AddrItem(
            icon: Icons.place_outlined,
            label: 'Autre',
            subtitle: _otherAddress,
            isSelected: _selected == LocationType.other,
            teal: const Color(0xFF111827), tealLight: Colors.transparent,
            onTap: _otherAddress != null ? () => _selectOtherAddress(_otherAddress!) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaces() {
    final places = [
      'Maison',
      'Paris 11e',
      'Bureau',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lieux récents',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: const Color(0xFF7C8593),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: places.map((place) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _selectOtherAddress(place),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.56),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      place,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF29303A),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pin tail painter ─────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

// ─── Item adresse sauvegardée ─────────────────────────────────
class _AddrItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isLoading;
  final Color teal;
  final Color tealLight;
  final Animation<double>? pulse;
  final VoidCallback? onTap;

  const _AddrItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.isLoading = false,
    required this.teal,
    required this.tealLight,
    this.pulse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final leadingIcon = Icon(
      icon,
      size: 20,
      color: isSelected ? teal : const Color(0xFF7A8491),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F3F5).withValues(alpha: 0.82) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppBarOptionTile(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        leading: pulse != null
            ? ScaleTransition(scale: pulse!, child: leadingIcon)
            : leadingIcon,
        title: label,
        subtitle: subtitle,
        trailing: isLoading
            ? AppLoadingIndicator(size: AppBarMetrics.trailingIndicatorSize, color: teal)
            : AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : 0,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: const Color(0xFF9AA3AF),
                ),
              ),
      ),
    );
  }
}
