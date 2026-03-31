import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../theme/design_tokens.dart';
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

// ─────────────────────────────────────────────────────────────
// LocationAppBar — barre de navigation avec localisation,
// cloche de notifications et switch de rôle via avatar.
// Accepte un paramètre [bottom] (ex: CigaleTabBar) optionnel.
// ─────────────────────────────────────────────────────────────

class LocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final VoidCallback? onGoToAccount;

  const LocationAppBar({super.key, this.bottom, this.onGoToAccount});

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
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
      duration: const Duration(milliseconds: 350),
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
    final current = _locationData?.label ?? _parseCity(currentAddress);
    // Déduire le type sélectionné depuis _locationData
    final initType = _locationData?.icon == Icons.location_on_rounded ||
            _locationData?.icon == Icons.location_city_rounded
        ? _LocationType.other
        : _LocationType.current;
    final previousOther = initType == _LocationType.other
        ? _locationData?.label
        : null;
    final result = await Navigator.push<LocationData>(
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

    // Données à afficher dans le titre
    final locIcon     = _locationData?.icon     ?? Icons.my_location_rounded;
    final locLabel    = _locationData?.label    ?? _parseCity(address);
    final locSubtitle = _locationData?.subtitle ?? '';

    if (unread > _prevUnread) _bellCtrl.forward(from: 0);
    _prevUnread = unread;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 0.8),
      ),
      bottom: widget.bottom,
      // ── Localisation (gauche) ──────────────────────────────
      title: GestureDetector(
        onTap: () => _openLocationSearch(context, address),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle icône mint
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(locIcon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            // Label + sous-titre + chevron
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$locLabel ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          if (locSubtitle.isNotEmpty)
                            TextSpan(
                              text: locSubtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF888888),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: Color(0xFF1C1C1E)),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── Actions (droite) ──────────────────────────────────
      actions: [
        // Cloche
        Stack(
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: _bellScale,
              child: IconButton(
                icon: Icon(
                  unread > 0
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined,
                  color: unread > 0
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 26,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsPage()),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: AppColors.urgent,
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Badge de mode — switch de rôle
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 2),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => RoleSwitchSheet(
                avatarUrl: '',
                firstName: firstName,
                onGoToAccount: widget.onGoToAccount,
              ),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                isClient ? 'C' : 'F',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _parseCity(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'Ma position';
    }
    final parts = address.split(',');
    final city = parts.last.trim();
    return city.isEmpty ? address.trim() : city;
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
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 16,
              offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Titre + avatar ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: onGoToAccount != null ? () {
                Navigator.pop(context);
                onGoToAccount!();
              } : null,
              child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isClient ? AppColors.primaryLight : const Color(0xFFEAEFF6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isClient ? AppColors.primary : const Color(0xFF1E3A5F),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isClient ? 'C' : 'F',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isClient ? AppColors.primary : const Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName.isNotEmpty ? firstName : 'Mon compte',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isClient ? 'Mode Client actif'
                                 : 'Mode Prestataire actif',
                        style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Titre section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CHANGER DE MODE',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888), letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Item Client ──────────────────────────────────────
          _RoleItem(
            icon: Icons.person_search_rounded,
            label: 'Client',
            subtitle: 'Trouvez des prestataires',
            isSelected: isClient,
            teal: AppColors.primary,
            tealLight: AppColors.primaryLight,
            onTap: isClient || isLoading ? null : () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().switchRole(UserRole.client);
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6),
              indent: 16, endIndent: 16),

          // ── Item Prestataire ─────────────────────────────────
          _RoleItem(
            icon: Icons.handyman_rounded,
            label: 'Prestataire',
            subtitle: 'Proposez vos services',
            isSelected: !isClient,
            teal: AppColors.primary,
            tealLight: AppColors.primaryLight,
            onTap: !isClient || isLoading ? null : () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().switchRole(UserRole.provider);
            },
          ),

          // ── Loading ──────────────────────────────────────────
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text('Changement en cours...',
                      style: TextStyle(fontSize: 13,
                          color: Color(0xFF888888))),
                ],
              ),
            ),

          // ── Déconnexion ──────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6),
              indent: 16, endIndent: 16),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Center(
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ),

          // ── Fermer ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16 + bottomPad),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color teal;
  final Color tealLight;
  final VoidCallback? onTap;

  const _RoleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.teal,
    required this.tealLight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: tealLight, shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6C757D))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? teal : Colors.transparent,
                border: Border.all(color: teal, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
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

enum _LocationType { current, other }

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
  final _LocationType initialType;
  final String? initialOtherAddress;
  const LocationSearchPage({
    super.key,
    required this.currentCity,
    this.initialType = _LocationType.current,
    this.initialOtherAddress,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {

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

  late _LocationType _selected;
  String? _otherAddress;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialType;
    _otherAddress = widget.initialOtherAddress;
    _searchCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _mapCtrl.dispose();
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
      _selected = _LocationType.other;
    });
    _mapCtrl.move(latlng, 13);
    Navigator.pop(context, LocationData(
      icon: Icons.location_on_rounded,
      label: r.shortName,
      subtitle: subtitle,
    ));
  }

  Future<void> _selectCurrentPosition() async {
    setState(() { _selected = _LocationType.current; _loadingLocation = true; });
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
    setState(() => _selected = _LocationType.other);
    Navigator.pop(context, LocationData(
      icon: Icons.location_on_rounded,
      label: address.split(',').first.trim(),
      subtitle: address.contains(',')
          ? address.split(',').skip(1).join(',').trim()
          : '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Carte (rétrécit quand clavier s'ouvre) ───────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(initialCenter: _center, initialZoom: 6),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.inkern',
                    ),
                    if (_pin != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _pin!,
                          width: 48, height: 48,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 8, spreadRadius: 2),
                                  ],
                                ),
                                child: const Icon(Icons.location_on_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              CustomPaint(
                                size: const Size(12, 6),
                                painter: _PinTailPainter(AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  ],
                ),
                // Bouton retour
                Positioned(
                  top: top + 12, left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Color(0xFF1C1C1E)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel bas (toujours au-dessus du clavier) ────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Color(0x22000000), blurRadius: 16,
                    offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Titre
                const Text(
                  'Lieu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 16),

                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom de rue ou par ville',
                      hintStyle: const TextStyle(
                          color: Color(0xFFADB5BD), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF6C757D), size: 20),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF6C757D), size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _focusNode.requestFocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Contenu (résultats ou adresses)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.32,
                  ),
                  child: _isSearching
                      ? _buildResults()
                      : _buildAddressList(),
                ),

                // Fermer
                Padding(
                  padding: EdgeInsets.only(
                      top: 12,
                      bottom: 16 + MediaQuery.of(context).padding.bottom),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
            Icon(Icons.search_off_rounded, size: 40,
                color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text('Aucun résultat',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
      itemBuilder: (_, i) {
        final r = _results[i];
        return InkWell(
          onTap: () => _selectResult(r),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_city_rounded,
                      size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.shortName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E))),
                      const SizedBox(height: 2),
                      Text(r.displayName,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6C757D))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFD1D5DB), size: 20),
              ],
            ),
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
            icon: Icons.navigation_rounded,
            label: 'Position actuelle',
            isSelected: _selected == _LocationType.current,
            isLoading: _loadingLocation,
            teal: AppColors.primary, tealLight: AppColors.primaryLight,
            onTap: _loadingLocation ? null : _selectCurrentPosition,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6),
              indent: 16, endIndent: 16),
          _AddrItem(
            icon: Icons.location_on_rounded,
            label: 'Autre',
            subtitle: _otherAddress,
            isSelected: _selected == _LocationType.other,
            teal: AppColors.primary, tealLight: AppColors.primaryLight,
            onTap: _otherAddress != null
                ? () => _selectOtherAddress(_otherAddress!)
                : null,
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
  final VoidCallback? onTap;

  const _AddrItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.isLoading = false,
    required this.teal,
    required this.tealLight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: tealLight, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6C757D)),
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isLoading)
              SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: teal),
              )
            else
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? teal : Colors.transparent,
                  border: Border.all(color: teal, width: 2),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
