import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // ── Champs freelancer uniquement ─────────────────────────────────────────
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  double _zoneRadius = 10;

  // ── Localisation freelancer ──────────────────────────────────────────────
  LatLng? _locationLatLng;
  String _locationAddress = '';

  final List<Map<String, dynamic>> _allSkills = [
    {'label': 'Ménage', 'icon': Icons.cleaning_services_rounded},
    {'label': 'Jardinage', 'icon': Icons.grass_rounded},
    {'label': 'Bricolage', 'icon': Icons.handyman_rounded},
    {'label': 'Repassage', 'icon': Icons.iron_rounded},
    {'label': 'Plomberie', 'icon': Icons.plumbing_rounded},
    {'label': 'Électricité', 'icon': Icons.electrical_services_rounded},
    {'label': 'Peinture', 'icon': Icons.format_paint_rounded},
    {'label': 'Déménagement', 'icon': Icons.local_shipping_rounded},
    {'label': 'Courses', 'icon': Icons.shopping_cart_rounded},
    {'label': 'Garde d\'enfants', 'icon': Icons.child_care_rounded},
    {'label': 'Aide aux personnes âgées', 'icon': Icons.elderly_rounded},
  ];
  final Set<String> _selectedSkills = {};

  bool get _isFreelancer =>
      context.read<AuthProvider>().currentRole == UserRole.provider;

  int get _completionScore {
    int s = 0;
    if (_bioController.text.isNotEmpty) s += 25;
    if (_phoneController.text.isNotEmpty) s += 15;
    if (_selectedSkills.isNotEmpty) s += 25;
    if (_hourlyRateController.text.isNotEmpty) s += 15;
    if (_locationLatLng != null) s += 20;
    return s.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile == null) return;
      if (profile.phone != null) _phoneController.text = profile.phone!;
      if (profile.email != null) _emailController.text = profile.email!;
      if (profile.address != null) {
        _addressController.text = profile.address!;
        _locationAddress = profile.address!;
      }
      if (profile.bio != null) _bioController.text = profile.bio!;
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
    final existing = profileProv.profile;
    if (existing == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = true);

    final isF = _isFreelancer;
    // Si une localisation a été choisie sur la carte, on l'utilise
    final finalAddress = _locationAddress.isNotEmpty
        ? _locationAddress
        : _addressController.text.trim();

    final updated = existing.copyWith(
      phone: _phoneController.text.trim(),
      address: finalAddress,
      bio: isF ? _bioController.text.trim() : existing.bio,
      hourlyRate: isF
          ? double.tryParse(_hourlyRateController.text.trim())
          : existing.hourlyRate,
    );
    final error = await profileProv.updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error == null) Navigator.pop(context);
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final isFreelancer =
        context.watch<AuthProvider>().currentRole == UserRole.provider;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          'Modifier mon profil',
          style: context.profilePageTitleStyle,
        ),
        centerTitle: true,
        bottom: isFreelancer
            ? AppSegmentedTabBar(
                controller: _tabController,
                tabs: const [
                  AppSegmentedTab(icon: Icons.person_rounded, label: 'Profil'),
                  AppSegmentedTab(
                    icon: Icons.trending_up_rounded,
                    label: 'Activité',
                  ),
                ],
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
                        profile: profile,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        bioController: _bioController,
                        completionScore: _completionScore,
                      ),
                      // ── Onglet Activité ──
                      _FreelancerActivityTab(
                        hourlyRateController: _hourlyRateController,
                        allSkills: _allSkills,
                        selectedSkills: _selectedSkills,
                        zoneRadius: _zoneRadius,
                        locationLatLng: _locationLatLng,
                        locationAddress: _locationAddress,
                        onZoneChanged: (v) => setState(() => _zoneRadius = v),
                        onSkillToggle: (l) => setState(
                          () => _selectedSkills.contains(l)
                              ? _selectedSkills.remove(l)
                              : _selectedSkills.add(l),
                        ),
                        onRateChanged: () => setState(() {}),
                        onLocationChanged: (latlng, address) => setState(() {
                          _locationLatLng = latlng;
                          _locationAddress = address;
                        }),
                      ),
                    ],
                  )
                // ── Mode Client ──
                : _ClientProfileTab(
                    profile: profile,
                    phoneController: _phoneController,
                    emailController: _emailController,
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
        AppGap.h12,

        // ── Identité verrouillée ──
        _SectionCard(
          icon: Icons.person_rounded,
          iconColor: AppColors.info,
          iconBg: context.colors.infoLight,
          title: 'Identité',
          trailing: _PillBadge(
            label: 'Verrouillé',
            icon: Icons.lock_rounded,
            color: AppColors.info,
          ),
          child: Column(
            children: [
              _InfoBanner(
                icon: Icons.info_outline_rounded,
                text: 'Ces informations sont verrouillées après vérification.',
                color: AppColors.info,
              ),
              AppGap.h12,
              _LockedField(
                label: 'Prénom',
                value: profile?.firstName.isNotEmpty == true
                    ? profile!.firstName
                    : '—',
                icon: Icons.person_outline_rounded,
              ),
              AppGap.h10,
              _LockedField(
                label: 'Nom',
                value: profile?.lastName.isNotEmpty == true
                    ? profile!.lastName
                    : '—',
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ── Coordonnées ──
        _SectionCard(
          icon: Icons.contact_page_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Coordonnées',
          child: Column(
            children: [
              _EditField(
                label: 'Adresse email',
                controller: emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              AppGap.h12,
              _EditField(
                label: 'Téléphone',
                controller: phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ── Présentation ──
        _BioCard(controller: bioController),
        AppGap.h12,
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
        AppGap.h12,
        _SkillsCard(
          allSkills: allSkills,
          selectedSkills: selectedSkills,
          onToggle: onSkillToggle,
        ),
        AppGap.h12,
        // ── Localisation sur carte ──
        _LocationMapCard(
          initialLatLng: locationLatLng,
          initialAddress: locationAddress,
          onChanged: onLocationChanged,
        ),
        AppGap.h12,
        // ── Rayon d'intervention ──
        _ZoneCard(zoneRadius: zoneRadius, onChanged: onZoneChanged),
        AppGap.h12,
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
          iconBg: context.colors.infoLight,
          title: 'Identité',
          trailing: _PillBadge(
            label: 'Verrouillé',
            icon: Icons.lock_rounded,
            color: AppColors.info,
          ),
          child: Column(
            children: [
              _InfoBanner(
                icon: Icons.info_outline_rounded,
                text: 'Ces informations sont verrouillées après vérification.',
                color: AppColors.info,
              ),
              AppGap.h12,
              _LockedField(
                label: 'Prénom',
                value: profile?.firstName.isNotEmpty == true
                    ? profile!.firstName
                    : '—',
                icon: Icons.person_outline_rounded,
              ),
              AppGap.h10,
              _LockedField(
                label: 'Nom',
                value: profile?.lastName.isNotEmpty == true
                    ? profile!.lastName
                    : '—',
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ── Coordonnées ──
        _SectionCard(
          icon: Icons.contact_page_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Coordonnées',
          child: Column(
            children: [
              _EditField(
                label: 'Adresse email',
                controller: emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              AppGap.h12,
              _EditField(
                label: 'Téléphone',
                controller: phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              AppGap.h12,
              _EditField(
                label: 'Adresse principale',
                controller: addressController,
                icon: Icons.home_outlined,
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ── Compte vérifié ──
        Container(
          padding: AppInsets.a16,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compte vérifié',
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      'Votre identité a été confirmée avec succès.',
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        AppGap.h12,
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CARTE LOCALISATION (freelancer)
// ═════════════════════════════════════════════════════════════════════════════

class _LocationMapCard extends StatefulWidget {
  final LatLng? initialLatLng;
  final String initialAddress;
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
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng _center = const LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _pin;
  String _displayAddress = '';
  bool _isSearching = false;
  bool _isReversing = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLatLng != null) {
      _pin = widget.initialLatLng;
      _center = widget.initialLatLng!;
    }
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
      final resp = await http.get(
        uri,
        headers: {'Accept-Language': 'fr', 'User-Agent': 'InkernApp/1.0'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _suggestions = data
              .map(
                (e) => {
                  'display': e['display_name'] as String,
                  'lat': double.parse(e['lat'] as String),
                  'lon': double.parse(e['lon'] as String),
                },
              )
              .toList();
        });
      }
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(Map<String, dynamic> s) {
    final latlng = LatLng(s['lat'] as double, s['lon'] as double);
    final address = s['display'] as String;
    // Raccourcit l'adresse affichée (premier segment)
    final short = address.split(',').take(3).join(',');
    setState(() {
      _pin = latlng;
      _center = latlng;
      _displayAddress = short;
      _suggestions = [];
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
      final resp = await http.get(
        uri,
        headers: {'Accept-Language': 'fr', 'User-Agent': 'InkernApp/1.0'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final full = data['display_name'] as String? ?? '';
        final short = full.split(',').take(3).join(',');
        setState(() {
          _displayAddress = short;
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
      _pin = latlng;
      _center = latlng;
      _suggestions = [];
    });
    _searchFocus.unfocus();
    _reverseGeocode(latlng);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.location_on_rounded,
      iconColor: AppColors.error,
      iconBg: context.colors.errorLight,
      title: 'Ma localisation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Définissez votre ville ou adresse de base. Les clients à proximité pourront vous trouver.',
            style: context.text.labelMedium?.copyWith(height: 1.5),
          ),
          AppGap.h14,

          // ── Champ de recherche ──────────────────────────────────────────
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
                          hintText: 'Rechercher une adresse…',
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
                          setState(() => _suggestions = []);
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

              // ── Suggestions ──────────────────────────────────────────────
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: Column(
                      children: _suggestions.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        final display = s['display'] as String;
                        final short = display.split(',').first;
                        final rest = display
                            .split(',')
                            .skip(1)
                            .take(2)
                            .join(',')
                            .trim();
                        return Column(
                          children: [
                            if (i > 0)
                              Divider(height: 1, color: context.colors.divider),
                            InkWell(
                              onTap: () => _selectSuggestion(s),
                              child: Padding(
                                padding: AppInsets.h14v12,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: AppInsets.a6,
                                      decoration: BoxDecoration(
                                        color: context.colors.errorLight,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.xs,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    AppGap.w10,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            short,
                                            style: context.text.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: context
                                                      .colors
                                                      .textPrimary,
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
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),

          AppGap.h12,

          // ── Carte interactive ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: SizedBox(
              height: 220,
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
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.flutter_application_1',
                      ),
                      if (_pin != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pin!,
                              width: 44,
                              height: 52,
                              child: const _MapPin(),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Hint "appuyer pour déplacer"
                  if (_pin == null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            padding: AppInsets.h14v8,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                AppGap.w6,
                                Text(
                                  'Appuyez pour poser le pin',
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

                  // Loader géocodage inverse
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

          // ── Adresse sélectionnée ───────────────────────────────────────
          if (_displayAddress.isNotEmpty) ...[
            AppGap.h10,
            Container(
              padding: AppInsets.a12,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  AppGap.w8,
                  Expanded(
                    child: Text(
                      _displayAddress,
                      style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppGap.h10,
            Container(
              padding: AppInsets.a12,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: context.colors.textHint,
                  ),
                  AppGap.w8,
                  Text(
                    'Aucune localisation définie',
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
            border: Border.all(color: context.colors.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        CustomPaint(size: const Size(12, 8), painter: _PinTailPainter()),
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
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill,
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
    if (score < 50) {
      color = AppColors.error;
      label = 'Profil incomplet';
      icon = Icons.warning_amber_rounded;
    } else if (score < 80) {
      color = AppColors.warning;
      label = 'Presque complet';
      icon = Icons.trending_up_rounded;
    } else {
      color = AppColors.primary;
      label = 'Profil complet';
      icon = Icons.verified_rounded;
    }

    return AppSurfaceCard(
      padding: AppInsets.a16,
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: color.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              AppGap.w8,
              Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '$score%',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          AppGap.h10,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          if (score < 100) ...[
            AppGap.h8,
            Text(
              score < 50
                  ? 'Ajoutez une bio et vos compétences pour attirer des clients.'
                  : score < 80
                  ? 'Ajoutez votre tarif horaire pour compléter votre profil.'
                  : 'Définissez votre localisation pour finaliser votre profil.',
              style: context.text.labelMedium?.copyWith(
                color: color.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
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
      iconBg: context.colors.warningLight,
      title: 'Présentation',
      trailing: Text(
        '$count / 500',
        style: context.text.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: count > 450 ? AppColors.warning : context.colors.textTertiary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Présentez votre expérience et vos points forts aux clients.',
            style: context.text.labelMedium?.copyWith(height: 1.5),
          ),
          AppGap.h12,
          TextField(
            controller: widget.controller,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textPrimary,
              height: 1.6,
            ),
            decoration: AppInputDecorations.formField(
              context,
              hintText: 'Ex : Professionnel ponctuel et sérieux…',
              hintStyle: context.text.bodySmall?.copyWith(
                color: context.colors.textHint,
                height: 1.5,
              ),
              fillColor: context.colors.surface,
              contentPadding: AppInsets.a14,
            ).copyWith(counterText: ''),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              widget.onChanged();
              setState(() {});
            },
            style: TextStyle(
              fontSize: AppFontSize.h1Lg,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
            decoration: AppInputDecorations.formField(
              context,
              hintText: '25',
              hintStyle: TextStyle(
                fontSize: AppFontSize.h1Lg,
                fontWeight: FontWeight.w800,
                color: context.colors.border,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Icon(
                  Icons.euro_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
              fillColor: context.colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ).copyWith(
              suffixText: '€ / heure',
              suffixStyle: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGap.h14,
          Text(
            'Suggestions rapides',
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppGap.h8,
          Wrap(
            spacing: 8,
            children: [15, 20, 25, 30, 35, 50].map((v) {
              final sel = widget.controller.text == '$v';
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.controller.text = '$v';
                  widget.onChanged();
                  setState(() {});
                },
                child: AppPillChip(label: '$v €', selected: sel),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Skills card ───────────────────────────────────────────────────────────────

class _SkillsCard extends StatelessWidget {
  final List<Map<String, dynamic>> allSkills;
  final Set<String> selectedSkills;
  final ValueChanged<String> onToggle;
  const _SkillsCard({
    required this.allSkills,
    required this.selectedSkills,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.build_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
      title: 'Compétences',
      trailing: AppTagPill(
        label: '${selectedSkills.length}/${allSkills.length}',
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        fontSize: AppFontSize.xs,
        fontWeight: FontWeight.w500,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: allSkills.map((skill) {
          final label = skill['label'] as String;
          final icon = skill['icon'] as IconData;
          final sel = selectedSkills.contains(label);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle(label);
            },
            child: AppPillChip(label: label, icon: icon, selected: sel),
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
      iconBg: context.colors.errorLight,
      title: "Rayon d'intervention",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSurfaceCard(
            padding: AppInsets.h14v10,
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Row(
              children: [
                const Icon(
                  Icons.social_distance_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                AppGap.w8,
                Text('Rayon : ', style: context.text.bodySmall),
                Text(
                  '${zoneRadius.toInt()} km',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: context.colors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: zoneRadius,
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 km',
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.textHint,
                ),
              ),
              Text(
                '100 km',
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final double bottom;
  const _SaveBar({
    required this.isSaving,
    required this.onSave,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: AppButton(
        onPressed: isSaving ? null : onSave,
        isLoading: isSaving,
        isEnabled: !isSaving,
        label: 'Enregistrer les modifications',
        icon: Icons.check_rounded,
        variant: ButtonVariant.primary,
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
  const _SectionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: AppInsets.a16,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: context.colors.border),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppSurfaceCard(
              padding: AppInsets.a8,
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.badge),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            AppGap.w10,
            Text(
              title,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        AppGap.h16,
        child,
      ],
    ),
  );
}

class _PillBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _PillBadge({
    required this.label,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => AppTagPill(
    label: label,
    icon: icon,
    backgroundColor: color.withValues(alpha: 0.1),
    foregroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
  );
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
  });
  @override
  Widget build(BuildContext context) =>
      AppInfoBanner(icon: icon, message: text, color: color);
}

class _LockedField extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _LockedField({
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      AppGap.h6,
      AppSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: context.colors.border),
        child: Row(
          children: [
            Icon(icon, size: 17, color: context.colors.textHint),
            AppGap.w10,
            Expanded(
              child: Text(
                value,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ),
            Icon(Icons.lock_rounded, size: 13, color: context.colors.textHint),
          ],
        ),
      ),
    ],
  );
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      AppGap.h6,
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.textPrimary,
        ),
        decoration: AppInputDecorations.formField(
          context,
          prefixIcon: Icon(icon, size: 18, color: context.colors.textTertiary),
          fillColor: context.colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    ],
  );
}
