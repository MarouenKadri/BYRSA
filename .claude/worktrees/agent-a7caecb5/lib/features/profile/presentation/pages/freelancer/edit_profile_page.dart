import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../profile_provider.dart';
import '../../../data/models/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  late TabController _tabController;

  // ── Champs partagés ──────────────────────────────────────────────────────
  final _phoneController   = TextEditingController();
  final _emailController   = TextEditingController();
  final _addressController = TextEditingController();

  // ── Champs freelancer uniquement ─────────────────────────────────────────
  final _bioController        = TextEditingController();
  final _hourlyRateController = TextEditingController();
  double _zoneRadius = 10;

  // ── Localisation freelancer ──────────────────────────────────────────────
  LatLng?  _locationLatLng;
  String   _locationAddress = '';

  final List<Map<String, dynamic>> _allSkills = [
    {'label': 'Ménage',                   'icon': Icons.cleaning_services_rounded},
    {'label': 'Jardinage',                'icon': Icons.grass_rounded},
    {'label': 'Bricolage',                'icon': Icons.handyman_rounded},
    {'label': 'Repassage',                'icon': Icons.iron_rounded},
    {'label': 'Plomberie',                'icon': Icons.plumbing_rounded},
    {'label': 'Électricité',              'icon': Icons.electrical_services_rounded},
    {'label': 'Peinture',                 'icon': Icons.format_paint_rounded},
    {'label': 'Déménagement',             'icon': Icons.local_shipping_rounded},
    {'label': 'Courses',                  'icon': Icons.shopping_cart_rounded},
    {'label': 'Garde d\'enfants',         'icon': Icons.child_care_rounded},
    {'label': 'Aide aux personnes âgées', 'icon': Icons.elderly_rounded},
  ];
  final Set<String> _selectedSkills = {};

  bool get _isFreelancer =>
      context.read<AuthProvider>().currentRole == UserRole.provider;

  int get _completionScore {
    int s = 0;
    if (_bioController.text.isNotEmpty)        s += 25;
    if (_phoneController.text.isNotEmpty)      s += 15;
    if (_selectedSkills.isNotEmpty)            s += 25;
    if (_hourlyRateController.text.isNotEmpty) s += 15;
    if (_locationLatLng != null)               s += 20;
    return s.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile == null) return;
      if (profile.phone      != null) _phoneController.text   = profile.phone!;
      if (profile.email      != null) _emailController.text   = profile.email!;
      if (profile.address    != null) {
        _addressController.text = profile.address!;
        _locationAddress        = profile.address!;
      }
      if (profile.bio        != null) _bioController.text     = profile.bio!;
      if (profile.hourlyRate != null) {
        _hourlyRateController.text = profile.hourlyRate!.toStringAsFixed(0);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profileProv = context.read<ProfileProvider>();
    final existing    = profileProv.profile;
    if (existing == null) { Navigator.pop(context); return; }
    setState(() => _isSaving = true);

    final isF = _isFreelancer;
    // Si une localisation a été choisie sur la carte, on l'utilise
    final finalAddress = _locationAddress.isNotEmpty
        ? _locationAddress
        : _addressController.text.trim();

    final updated = existing.copyWith(
      phone:      _phoneController.text.trim(),
      address:    finalAddress,
      bio:        isF ? _bioController.text.trim()                        : existing.bio,
      hourlyRate: isF ? double.tryParse(_hourlyRateController.text.trim()) : existing.hourlyRate,
    );
    final error = await profileProv.updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error == null) Navigator.pop(context);
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile      = context.watch<ProfileProvider>().profile;
    final isFreelancer = context.watch<AuthProvider>().currentRole == UserRole.provider;
    final bottom       = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: isFreelancer
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 14),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Profil'),
                      Tab(text: 'Activité'),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: isFreelancer
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Onglet Profil ──
                      _FreelancerProfileTab(
                        profile:           profile,
                        phoneController:   _phoneController,
                        emailController:   _emailController,
                        bioController:     _bioController,
                        completionScore:   _completionScore,
                      ),
                      // ── Onglet Activité ──
                      _FreelancerActivityTab(
                        hourlyRateController: _hourlyRateController,
                        allSkills:            _allSkills,
                        selectedSkills:       _selectedSkills,
                        zoneRadius:           _zoneRadius,
                        locationLatLng:       _locationLatLng,
                        locationAddress:      _locationAddress,
                        onZoneChanged: (v)    => setState(() => _zoneRadius = v),
                        onSkillToggle: (l)    => setState(() =>
                            _selectedSkills.contains(l)
                                ? _selectedSkills.remove(l)
                                : _selectedSkills.add(l)),
                        onRateChanged:        () => setState(() {}),
                        onLocationChanged: (latlng, address) => setState(() {
                          _locationLatLng  = latlng;
                          _locationAddress = address;
                        }),
                      ),
                    ],
                  )
                // ── Mode Client ──
                : _ClientProfileTab(
                    profile:           profile,
                    phoneController:   _phoneController,
                    emailController:   _emailController,
                    addressController: _addressController,
                  ),
          ),
          _SaveBar(isSaving: _isSaving, onSave: _saveProfile, bottom: bottom),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB FREELANCER — PROFIL
// ═════════════════════════════════════════════════════════════════════════════

class _FreelancerProfileTab extends StatelessWidget {
  final UserProfile? profile;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController bioController;
  final int completionScore;

  const _FreelancerProfileTab({
    required this.profile,
    required this.phoneController,
    required this.emailController,
    required this.bioController,
    required this.completionScore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: [
        // ── Complétion ──
        _CompletionCard(score: completionScore),
        const SizedBox(height: 12),

        // ── Identité verrouillée ──
        _SectionCard(
          icon: Icons.person_rounded,
          iconColor: AppColors.info,
          iconBg: AppColors.lightBlue,
          title: 'Identité',
          trailing: _PillBadge(label: 'Verrouillé', icon: Icons.lock_rounded, color: AppColors.info),
          child: Column(children: [
            _InfoBanner(
              icon: Icons.info_outline_rounded,
              text: 'Ces informations sont verrouillées après vérification.',
              color: AppColors.info,
            ),
            const SizedBox(height: 12),
            _LockedField(
              label: 'Prénom',
              value: profile?.firstName.isNotEmpty == true ? profile!.firstName : '—',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            _LockedField(
              label: 'Nom',
              value: profile?.lastName.isNotEmpty == true ? profile!.lastName : '—',
              icon: Icons.badge_outlined,
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Coordonnées ──
        _SectionCard(
          icon: Icons.contact_page_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Coordonnées',
          child: Column(children: [
            _EditField(label: 'Adresse email', controller: emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _EditField(label: 'Téléphone',     controller: phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Présentation ──
        _BioCard(controller: bioController),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB FREELANCER — ACTIVITÉ
// ═════════════════════════════════════════════════════════════════════════════

class _FreelancerActivityTab extends StatelessWidget {
  final TextEditingController hourlyRateController;
  final List<Map<String, dynamic>> allSkills;
  final Set<String> selectedSkills;
  final double zoneRadius;
  final LatLng? locationLatLng;
  final String locationAddress;
  final ValueChanged<double> onZoneChanged;
  final ValueChanged<String> onSkillToggle;
  final VoidCallback onRateChanged;
  final void Function(LatLng latlng, String address) onLocationChanged;

  const _FreelancerActivityTab({
    required this.hourlyRateController,
    required this.allSkills,
    required this.selectedSkills,
    required this.zoneRadius,
    required this.locationLatLng,
    required this.locationAddress,
    required this.onZoneChanged,
    required this.onSkillToggle,
    required this.onRateChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: [
        _TarifCard(controller: hourlyRateController, onChanged: onRateChanged),
        const SizedBox(height: 12),
        _SkillsCard(allSkills: allSkills, selectedSkills: selectedSkills, onToggle: onSkillToggle),
        const SizedBox(height: 12),
        // ── Localisation sur carte ──
        _LocationMapCard(
          initialLatLng:  locationLatLng,
          initialAddress: locationAddress,
          onChanged:      onLocationChanged,
        ),
        const SizedBox(height: 12),
        // ── Rayon d'intervention ──
        _ZoneCard(zoneRadius: zoneRadius, onChanged: onZoneChanged),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB CLIENT — PROFIL
// ═════════════════════════════════════════════════════════════════════════════

class _ClientProfileTab extends StatelessWidget {
  final UserProfile? profile;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  const _ClientProfileTab({
    required this.profile,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: [
        // ── Identité ──
        _SectionCard(
          icon: Icons.person_rounded,
          iconColor: AppColors.info,
          iconBg: AppColors.lightBlue,
          title: 'Identité',
          trailing: _PillBadge(label: 'Verrouillé', icon: Icons.lock_rounded, color: AppColors.info),
          child: Column(children: [
            _InfoBanner(
              icon: Icons.info_outline_rounded,
              text: 'Ces informations sont verrouillées après vérification.',
              color: AppColors.info,
            ),
            const SizedBox(height: 12),
            _LockedField(
              label: 'Prénom',
              value: profile?.firstName.isNotEmpty == true ? profile!.firstName : '—',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            _LockedField(
              label: 'Nom',
              value: profile?.lastName.isNotEmpty == true ? profile!.lastName : '—',
              icon: Icons.badge_outlined,
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Coordonnées ──
        _SectionCard(
          icon: Icons.contact_page_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Coordonnées',
          child: Column(children: [
            _EditField(label: 'Adresse email',      controller: emailController,   icon: Icons.email_outlined,   keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _EditField(label: 'Téléphone',          controller: phoneController,   icon: Icons.phone_outlined,   keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _EditField(label: 'Adresse principale', controller: addressController, icon: Icons.home_outlined),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Compte vérifié ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.badge)),
              child: const Icon(Icons.verified_user_rounded, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Compte vérifié',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                SizedBox(height: 2),
                Text('Votre identité a été confirmée avec succès.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.primary),
          ]),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CARTE LOCALISATION (freelancer)
// ═════════════════════════════════════════════════════════════════════════════

class _LocationMapCard extends StatefulWidget {
  final LatLng? initialLatLng;
  final String  initialAddress;
  final void Function(LatLng, String) onChanged;

  const _LocationMapCard({
    required this.initialLatLng,
    required this.initialAddress,
    required this.onChanged,
  });

  @override
  State<_LocationMapCard> createState() => _LocationMapCardState();
}

class _LocationMapCardState extends State<_LocationMapCard> {
  final MapController      _mapController  = MapController();
  final TextEditingController _searchCtrl  = TextEditingController();
  final FocusNode          _searchFocus    = FocusNode();

  LatLng  _center          = const LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _pin;
  String  _displayAddress  = '';
  bool    _isSearching     = false;
  bool    _isReversing     = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLatLng != null) {
      _pin    = widget.initialLatLng;
      _center = widget.initialLatLng!;
    }
    _displayAddress    = widget.initialAddress;
    _searchCtrl.text   = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Géocodage : adresse → LatLng ─────────────────────────────────────────

  Future<void> _searchAddress(String query) async {
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
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
        'User-Agent': 'InkernApp/1.0',
      });
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _suggestions = data.map((e) => {
            'display': e['display_name'] as String,
            'lat': double.parse(e['lat'] as String),
            'lon': double.parse(e['lon'] as String),
          }).toList();
        });
      }
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(Map<String, dynamic> s) {
    final latlng  = LatLng(s['lat'] as double, s['lon'] as double);
    final address = s['display'] as String;
    // Raccourcit l'adresse affichée (premier segment)
    final short   = address.split(',').take(3).join(',');
    setState(() {
      _pin            = latlng;
      _center         = latlng;
      _displayAddress = short;
      _suggestions    = [];
      _searchCtrl.text = short;
    });
    _mapController.move(latlng, 14);
    _searchFocus.unfocus();
    widget.onChanged(latlng, short);
  }

  // ── Géocodage inverse : LatLng → adresse ─────────────────────────────────

  Future<void> _reverseGeocode(LatLng latlng) async {
    setState(() => _isReversing = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${latlng.latitude}&lon=${latlng.longitude}&format=json',
      );
      final resp = await http.get(uri, headers: {
        'Accept-Language': 'fr',
        'User-Agent': 'InkernApp/1.0',
      });
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data  = jsonDecode(resp.body) as Map<String, dynamic>;
        final full  = data['display_name'] as String? ?? '';
        final short = full.split(',').take(3).join(',');
        setState(() {
          _displayAddress  = short;
          _searchCtrl.text = short;
        });
        widget.onChanged(latlng, short);
      }
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _isReversing = false);
    }
  }

  // ── Tap sur carte ─────────────────────────────────────────────────────────

  void _onMapTap(TapPosition _, LatLng latlng) {
    setState(() {
      _pin    = latlng;
      _center = latlng;
      _suggestions = [];
    });
    _searchFocus.unfocus();
    _reverseGeocode(latlng);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon:       Icons.location_on_rounded,
      iconColor:  AppColors.error,
      iconBg:     AppColors.errorLight,
      title:      'Ma localisation',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(
          'Définissez votre ville ou adresse de base. Les clients à proximité pourront vous trouver.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 14),

        // ── Champ de recherche ──────────────────────────────────────────
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: _searchFocus.hasFocus ? AppColors.primary : AppColors.border,
                width: _searchFocus.hasFocus ? 1.8 : 1,
              ),
            ),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
              ),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une adresse…',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                  onChanged: _searchAddress,
                ),
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              else if (_searchCtrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _suggestions = []);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                  ),
                ),
            ]),
          ),

          // ── Suggestions ──────────────────────────────────────────────
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.input),
                boxShadow: AppShadows.elevated,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.input),
                child: Column(
                  children: _suggestions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final display = s['display'] as String;
                    final short   = display.split(',').first;
                    final rest    = display.split(',').skip(1).take(2).join(',').trim();
                    return Column(children: [
                      if (i > 0) const Divider(height: 1, color: AppColors.divider),
                      InkWell(
                        onTap: () => _selectSuggestion(s),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.error),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(short,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    overflow: TextOverflow.ellipsis),
                                if (rest.isNotEmpty)
                                  Text(rest,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                      overflow: TextOverflow.ellipsis),
                              ],
                            )),
                          ]),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ]),

        const SizedBox(height: 12),

        // ── Carte interactive ──────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(
            height: 220,
            child: Stack(children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: _pin != null ? 13 : 11,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_application_1',
                  ),
                  if (_pin != null)
                    MarkerLayer(markers: [
                      Marker(
                        point: _pin!,
                        width: 44,
                        height: 52,
                        child: const _MapPin(),
                      ),
                    ]),
                ],
              ),

              // Hint "appuyer pour déplacer"
              if (_pin == null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.touch_app_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Appuyez pour poser le pin',
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                ),

              // Loader géocodage inverse
              if (_isReversing)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      boxShadow: AppShadows.button,
                    ),
                    child: const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                ),
            ]),
          ),
        ),

        // ── Adresse sélectionnée ───────────────────────────────────────
        if (_displayAddress.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayAddress,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textHint),
              SizedBox(width: 8),
              Text('Aucune localisation définie',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── Pin carte ─────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = AppColors.primary..style = PaintingStyle.fill,
    );
  }
  @override
  bool shouldRepaint(_) => false;
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS RÉUTILISABLES
// ═════════════════════════════════════════════════════════════════════════════

// ── Complétion ────────────────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  final int score;
  const _CompletionCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;
    if (score < 50)      { color = AppColors.error;   label = 'Profil incomplet';   icon = Icons.warning_amber_rounded; }
    else if (score < 80) { color = AppColors.warning;  label = 'Presque complet';    icon = Icons.trending_up_rounded; }
    else                 { color = AppColors.primary;  label = 'Profil complet';     icon = Icons.verified_rounded; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const Spacer(),
          Text('$score%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        if (score < 100) ...[
          const SizedBox(height: 8),
          Text(
            score < 50
                ? 'Ajoutez une bio et vos compétences pour attirer des clients.'
                : score < 80
                    ? 'Ajoutez votre tarif horaire pour compléter votre profil.'
                    : 'Définissez votre localisation pour finaliser votre profil.',
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), height: 1.4),
          ),
        ],
      ]),
    );
  }
}

// ── Bio card ──────────────────────────────────────────────────────────────────

class _BioCard extends StatefulWidget {
  final TextEditingController controller;
  const _BioCard({required this.controller});
  @override
  State<_BioCard> createState() => _BioCardState();
}
class _BioCardState extends State<_BioCard> {
  @override
  Widget build(BuildContext context) {
    final count = widget.controller.text.length;
    return _SectionCard(
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.warning,
      iconBg: AppColors.warningLight,
      title: 'Présentation',
      trailing: Text('$count / 500',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: count > 450 ? AppColors.warning : AppColors.textTertiary)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Présentez votre expérience et vos points forts aux clients.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        TextField(
          controller: widget.controller,
          maxLines: 5, maxLength: 500,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
          decoration: InputDecoration(
            hintText: 'Ex : Professionnel ponctuel et sérieux…',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint, height: 1.5),
            counterText: '',
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.primary, width: 1.8)),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ]),
    );
  }
}

// ── Tarif card ────────────────────────────────────────────────────────────────

class _TarifCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _TarifCard({required this.controller, required this.onChanged});
  @override
  State<_TarifCard> createState() => _TarifCardState();
}
class _TarifCardState extends State<_TarifCard> {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.euro_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryLight,
      title: 'Tarif horaire',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) { widget.onChanged(); setState(() {}); },
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '25',
            hintStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.border),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.euro_rounded, color: AppColors.primary, size: 24),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixText: '€ / heure',
            suffixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            filled: true, fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.primary, width: 1.8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Suggestions rapides',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [15, 20, 25, 30, 35, 50].map((v) {
            final sel = widget.controller.text == '$v';
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); widget.controller.text = '$v'; widget.onChanged(); setState(() {}); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: 1.5),
                ),
                child: Text('$v €', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppColors.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ── Skills card ───────────────────────────────────────────────────────────────

class _SkillsCard extends StatelessWidget {
  final List<Map<String, dynamic>> allSkills;
  final Set<String> selectedSkills;
  final ValueChanged<String> onToggle;
  const _SkillsCard({required this.allSkills, required this.selectedSkills, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.build_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
      title: 'Compétences',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
        child: Text('${selectedSkills.length}/${allSkills.length}',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: allSkills.map((skill) {
          final label = skill['label'] as String;
          final icon  = skill['icon'] as IconData;
          final sel   = selectedSkills.contains(label);
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); onToggle(label); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.badge),
                border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: sel ? Colors.white : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSecondary)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Zone card ─────────────────────────────────────────────────────────────────

class _ZoneCard extends StatelessWidget {
  final double zoneRadius;
  final ValueChanged<double> onChanged;
  const _ZoneCard({required this.zoneRadius, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.radar_rounded,
      iconColor: AppColors.error,
      iconBg: AppColors.errorLight,
      title: "Rayon d'intervention",
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(children: [
            const Icon(Icons.social_distance_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Rayon : ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('${zoneRadius.toInt()} km',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ]),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.15),
          ),
          child: Slider(
            value: zoneRadius, min: 5, max: 100, divisions: 19,
            onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); },
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('5 km',   style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          Text('100 km', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final double bottom;
  const _SaveBar({required this.isSaving, required this.onSave, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.45),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          elevation: 0,
        ),
        child: isSaving
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_rounded, size: 20),
                SizedBox(width: 8),
                Text('Enregistrer les modifications',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({required this.icon, required this.iconBg, required this.iconColor, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppRadius.badge)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (trailing != null) ...[const Spacer(), trailing!],
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class _PillBadge extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _PillBadge({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

class _InfoBanner extends StatelessWidget {
  final IconData icon; final String text; final Color color;
  const _InfoBanner({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(AppRadius.input)),
        child: Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color, height: 1.4))),
        ]),
      );
}

class _LockedField extends StatelessWidget {
  final String label, value; final IconData icon;
  const _LockedField({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.input), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Icon(icon, size: 17, color: AppColors.textHint),
            const SizedBox(width: 10),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary))),
            const Icon(Icons.lock_rounded, size: 13, color: AppColors.textHint),
          ]),
        ),
      ]);
}

class _EditField extends StatelessWidget {
  final String label; final TextEditingController controller; final IconData icon;
  final TextInputType? keyboardType; final int maxLines;
  const _EditField({required this.label, required this.controller, required this.icon, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller, keyboardType: keyboardType, maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.primary, width: 1.8)),
          ),
        ),
      ]);
}
