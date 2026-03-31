import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../../app/widgets/location_app_bar.dart';
import '../../../post/post_provider.dart';
import '../../../post/presentation/widgets/post_card.dart';
import '../../../profile/profile_provider.dart';
import 'freelancer_profile_view.dart';

/// ─────────────────────────────────────────────────────────────
/// 🏠 Inkern - Page d'accueil Client
/// Haut : aperçu freelancers + "Voir plus"
/// Bas  : fil d'actualité
/// ─────────────────────────────────────────────────────────────
class ClientHomePage extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  const ClientHomePage({super.key, this.onGoToAccount});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().loadFreelancers(),
      context.read<PostProvider>().refresh(),
    ]);
  }

  static Map<String, dynamic> _normalize(Map<String, dynamic> row) {
    final firstName = (row['first_name'] ?? '') as String;
    final lastName = (row['last_name'] ?? '') as String;
    final fullName = '$firstName $lastName'.trim();
    final hourlyRate = (row['hourly_rate'] ?? 0);
    return {
      'id': row['id'] ?? '',
      'name': fullName.isEmpty ? 'Prestataire' : fullName,
      'avatar': (row['avatar_url'] ?? '') as String,
      'rating': 0.0,
      'reviewsCount': 0,
      'hourlyRate': (hourlyRate is int) ? hourlyRate : (hourlyRate as num).toInt(),
      'isVerified': (row['is_verified'] ?? false) as bool,
      'missionsCount': 0,
      'responseTime': '2h',
      'experienceLevel': 'Pro',
    };
  }

  void _openFreelancerProfile(Map<String, dynamic> f) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: f['id'] as String?,
          freelancerName: f['name'] as String,
          freelancerAvatar: f['avatar'] as String,
          hourlyRate: (f['hourlyRate'] as int).toDouble(),
          experienceLevel: f['experienceLevel'] as String,
          rating: f['rating'] as double,
          reviewsCount: f['reviewsCount'] as int,
          missionsCount: f['missionsCount'] as int,
          responseTime: 'Répond en ${f['responseTime']}',
        ),
      ),
    );
  }

  void _goToDiscovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FreelancerDiscoveryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = context.watch<ProfileProvider>().profile?.firstName ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: LocationAppBar(onGoToAccount: widget.onGoToAccount),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Greeting + Search ────────────────────────────────
            SliverToBoxAdapter(
              child: _GreetingSection(
                firstName: firstName,
                onSearchTap: _goToDiscovery,
              ),
            ),

            // ── Catégories ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategoriesRow(
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
              ),
            ),

            // ── Section Freelancers (scroll horizontal) ──────────
            SliverToBoxAdapter(
              child: Consumer<ProfileProvider>(
                builder: (context, provider, _) {
                  final items = provider.freelancers
                      .take(8)
                      .map(_normalize)
                      .toList();
                  return _FreelancersSection(
                    isLoading: provider.isLoadingFreelancers,
                    freelancers: items,
                    onTap: _openFreelancerProfile,
                    onSeeAll: _goToDiscovery,
                  );
                },
              ),
            ),

            // ── Liste des posts ──────────────────────────────────
            Consumer<PostProvider>(
              builder: (context, provider, _) {
                final posts = provider.posts;

                if (provider.isLoading && posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.dynamic_feed_rounded,
                                size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune publication pour l\'instant',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = posts[index].copyWith(isOwner: false);
                        return PostCard(
                          post: post,
                          onVote: (vote) => context
                              .read<PostProvider>()
                              .vote(posts[index].id, vote),
                          onEdit: () {},
                          onDelete: () {},
                          onTap: () {},
                        );
                      },
                      childCount: posts.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Greeting + Search bar
// ─────────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String firstName;
  final VoidCallback onSearchTap;

  const _GreetingSection({
    required this.firstName,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'Bonjour'),
                if (firstName.isNotEmpty)
                  TextSpan(
                    text: ' $firstName',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                const TextSpan(text: ' 👋'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Que recherchez-vous aujourd\'hui ?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Search bar
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 12),
                  Text(
                    'Ménage, jardinage, bricolage...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Catégories horizontales
// ─────────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  static const _items = [
    (Icons.apps_rounded,        'Tous'),
    (Icons.home_rounded,        'Ménage'),
    (Icons.grass_rounded,       'Jardinage'),
    (Icons.handyman_rounded,    'Bricolage'),
    (Icons.water_drop_rounded,  'Plomberie'),
    (Icons.bolt_rounded,        'Électricité'),
    (Icons.format_paint_rounded,'Peinture'),
    (Icons.local_shipping_rounded, 'Déménagement'),
  ];

  const _CategoriesRow({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final (icon, label) = _items[index];
            final isSelected = label == selected;
            return GestureDetector(
              onTap: () => onSelect(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(
                    right: index < _items.length - 1 ? 10 : 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.chipBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section freelancers — scroll horizontal (style home page)
// ─────────────────────────────────────────────────────────────
class _FreelancersSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> freelancers;
  final void Function(Map<String, dynamic>) onTap;
  final VoidCallback onSeeAll;

  const _FreelancersSection({
    required this.isLoading,
    required this.freelancers,
    required this.onTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Prestataires recommandés',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Row(
                    children: [
                      Text(
                        'Voir plus',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (freelancers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Aucun prestataire disponible',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: freelancers.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    right: index < freelancers.length - 1 ? 12 : 0,
                  ),
                  child: _FreelancerChip(
                    freelancer: freelancers[index],
                    onTap: () => onTap(freelancers[index]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Carte freelancer — photo pleine + infos en bas
// ─────────────────────────────────────────────────────────────
class _FreelancerChip extends StatelessWidget {
  final Map<String, dynamic> freelancer;
  final VoidCallback onTap;

  const _FreelancerChip({required this.freelancer, required this.onTap});

  static String _level(int missions) {
    if (missions >= 50) return 'Ambassadeur';
    if (missions >= 20) return 'Expert';
    if (missions >= 5)  return 'Pro';
    return 'Nouveau';
  }

  static _LevelStyle _levelStyle(String level) {
    switch (level) {
      case 'Ambassadeur':
        return _LevelStyle(
          bg: const Color(0xFFFFF8E1),
          fg: const Color(0xFFB45309),
          icon: Icons.workspace_premium_rounded,
        );
      case 'Expert':
        return _LevelStyle(
          bg: const Color(0xFFEFF6FF),
          fg: const Color(0xFF1D4ED8),
          icon: Icons.military_tech_rounded,
        );
      case 'Pro':
        return _LevelStyle(
          bg: AppColors.verifiedBg,
          fg: AppColors.primary,
          icon: Icons.verified_rounded,
        );
      default:
        return _LevelStyle(
          bg: AppColors.background,
          fg: AppColors.textSecondary,
          icon: Icons.person_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name       = freelancer['name'] as String;
    final avatar     = freelancer['avatar'] as String;
    final rating     = freelancer['rating'] as double;
    final isVerified = freelancer['isVerified'] as bool;
    final hourlyRate = freelancer['hourlyRate'] as int;
    final missions   = freelancer['missionsCount'] as int;
    final level      = _level(missions);
    final lvlStyle   = _levelStyle(level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Photo pleine carte ──────────────────────────
              avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _AvatarPlaceholder(name: name),
                    )
                  : _AvatarPlaceholder(name: name),

              // ── Dégradé noir en bas ─────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Badge niveau — haut droite ──────────────────
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lvlStyle.bg.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(lvlStyle.icon, size: 10, color: lvlStyle.fg),
                      const SizedBox(width: 3),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: lvlStyle.fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Badge vérifié — haut gauche ─────────────────
              if (isVerified)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_rounded,
                        size: 12, color: AppColors.primary),
                  ),
                ),

              // ── Infos overlay bas ───────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 0, 11, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Rating · missions · tarif
                      Row(
                        children: [
                          // Rating
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFFFB800)),
                          const SizedBox(width: 3),
                          Text(
                            rating > 0
                                ? rating.toStringAsFixed(1)
                                : '—',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Séparateur
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Missions
                          Icon(Icons.check_circle_rounded,
                              size: 11,
                              color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 3),
                          Text(
                            '$missions missions',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Tarif
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '$hourlyRate€/h',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _LevelStyle({required this.bg, required this.fg, required this.icon});
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  const _AvatarPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.primary.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Page découverte freelancers (standalone via "Voir plus")
// ─────────────────────────────────────────────────────────────
class FreelancerDiscoveryPage extends StatelessWidget {
  const FreelancerDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prestataires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: const _FreelancerDiscoveryView(),
    );
  }
}

/// Page d'accueil du client — recherche et filtrage des Freelancers
class _FreelancerDiscoveryView extends StatefulWidget {
  const _FreelancerDiscoveryView({super.key});

  @override
  State<_FreelancerDiscoveryView> createState() =>
      _FreelancerDiscoveryViewState();
}

class _FreelancerDiscoveryViewState extends State<_FreelancerDiscoveryView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  String _sortBy = 'recommended';
  RangeValues _priceRange = const RangeValues(10, 100);
  double _minRating = 0;
  bool _onlineOnly = false;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  final List<String> _categories = [
    'Tous',
    'Ménage',
    'Jardinage',
    'Bricolage',
    'Plomberie',
    'Électricité',
    'Peinture',
    'Déménagement',
    'Repassage',
  ];

  /// Normalise une entrée Supabase en Map uniforme pour les cards/filtres.
  Map<String, dynamic> _normalize(Map<String, dynamic> row) {
    final firstName = (row['first_name'] ?? '') as String;
    final lastName = (row['last_name'] ?? '') as String;
    final fullName = '${firstName} ${lastName}'.trim();
    final hourlyRate = (row['hourly_rate'] ?? 0);
    return {
      'id': row['id'] ?? '',
      'name': fullName.isEmpty ? 'Prestataire' : fullName,
      'avatar': (row['avatar_url'] ?? '') as String,
      'category': 'Pro',
      'rating': 0.0,
      'reviewsCount': 0,
      'hourlyRate': (hourlyRate is int) ? hourlyRate : (hourlyRate as num).toInt(),
      'isVerified': (row['is_verified'] ?? false) as bool,
      'isOnline': false,
      'experienceLevel': 'Pro',
      'missionsCount': 0,
      'responseTime': '2h',
      'zone': (row['address'] ?? '') as String,
      'services': <String>[],
    };
  }

  List<Map<String, dynamic>> get _filteredFreelancers {
    final rawList = context.watch<ProfileProvider>().freelancers;
    final normalized = rawList.map(_normalize).toList();

    return normalized.where((f) {
      // Filtre par recherche (côté client sur le nom)
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final name = (f['name'] as String).toLowerCase();
        final services = (f['services'] as List).join(' ').toLowerCase();
        if (!name.contains(query) && !services.contains(query)) {
          return false;
        }
      }

      // Filtre par catégorie (non disponible en DB pour l'instant — ignoré)
      // if (_selectedCategory != 'Tous' && f['category'] != _selectedCategory) {
      //   return false;
      // }

      // Filtre par prix
      final rate = f['hourlyRate'] as int;
      if (rate < _priceRange.start || rate > _priceRange.end) {
        return false;
      }

      // Filtre par note (toujours 0.0 en l'absence de données DB)
      if ((f['rating'] as double) < _minRating) {
        return false;
      }

      // Filtre en ligne
      if (_onlineOnly && !(f['isOnline'] as bool)) {
        return false;
      }

      // Filtre vérifié
      if (_verifiedOnly && !(f['isVerified'] as bool)) {
        return false;
      }

      return true;
    }).toList()..sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return (a['hourlyRate'] as int).compareTo(b['hourlyRate'] as int);
        case 'price_high':
          return (b['hourlyRate'] as int).compareTo(a['hourlyRate'] as int);
        case 'rating':
          return (b['rating'] as double).compareTo(a['rating'] as double);
        case 'reviews':
          return (b['reviewsCount'] as int).compareTo(a['reviewsCount'] as int);
        default: // recommended
          return (b['missionsCount'] as int).compareTo(
            a['missionsCount'] as int,
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                      context.read<ProfileProvider>().loadFreelancers(
                            search: _searchController.text,
                          );
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service, un nom...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[500],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context.read<ProfileProvider>().loadFreelancers();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Categories chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < _categories.length - 1 ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // Filter button
                GestureDetector(
                  onTap: () => _showFiltersSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_hasActiveFilters()) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _countActiveFilters().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Sort dropdown
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showSortSheet(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getSortLabel(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Results count
                Text(
                  '${_filteredFreelancers.length} résultats',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Freelancers list
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingFreelancers) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = _filteredFreelancers;
                if (items.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _FreelancerCard(
                      freelancer: items[index],
                      onTap: () => _openFreelancerProfile(items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun freelancer trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réinitialiser les filtres'),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _priceRange.start > 10 ||
        _priceRange.end < 100 ||
        _minRating > 0 ||
        _onlineOnly ||
        _verifiedOnly;
  }

  int _countActiveFilters() {
    int count = 0;
    if (_priceRange.start > 10 || _priceRange.end < 100) count++;
    if (_minRating > 0) count++;
    if (_onlineOnly) count++;
    if (_verifiedOnly) count++;
    return count;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Prix croissant';
      case 'price_high':
        return 'Prix décroissant';
      case 'rating':
        return 'Meilleures notes';
      case 'reviews':
        return 'Plus d\'avis';
      default:
        return 'Recommandés';
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'Tous';
      _priceRange = const RangeValues(10, 100);
      _minRating = 0;
      _onlineOnly = false;
      _verifiedOnly = false;
      _sortBy = 'recommended';
    });
    context.read<ProfileProvider>().loadFreelancers();
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersSheet(
        priceRange: _priceRange,
        minRating: _minRating,
        onlineOnly: _onlineOnly,
        verifiedOnly: _verifiedOnly,
        onApply: (priceRange, minRating, onlineOnly, verifiedOnly) {
          setState(() {
            _priceRange = priceRange;
            _minRating = minRating;
            _onlineOnly = onlineOnly;
            _verifiedOnly = verifiedOnly;
          });
        },
        onReset: _resetFilters,
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(
        currentSort: _sortBy,
        onSelect: (sort) {
          setState(() => _sortBy = sort);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openFreelancerProfile(Map<String, dynamic> freelancer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: freelancer['id'] as String?,
          freelancerName: freelancer['name'] as String,
          freelancerAvatar: freelancer['avatar'] as String,
          hourlyRate: (freelancer['hourlyRate'] as int).toDouble(),
          experienceLevel: freelancer['experienceLevel'] as String,
          rating: freelancer['rating'] as double,
          reviewsCount: freelancer['reviewsCount'] as int,
          missionsCount: freelancer['missionsCount'] as int,
          responseTime: 'Répond en ${freelancer['responseTime']}',
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📇 Card Freelancer (Modern Card Design)
/// ─────────────────────────────────────────────────────────────
class _FreelancerCard extends StatefulWidget {
  final Map<String, dynamic> freelancer;
  final VoidCallback onTap;

  const _FreelancerCard({required this.freelancer, required this.onTap});

  @override
  State<_FreelancerCard> createState() => _FreelancerCardState();
}

class _FreelancerCardState extends State<_FreelancerCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final freelancer = widget.freelancer;
    final isOnline = freelancer['isOnline'] as bool;
    final isVerified = freelancer['isVerified'] as bool;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.02),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Avatar with ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isOnline ? Colors.green : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: (freelancer['avatar'] as String).isNotEmpty
                          ? NetworkImage(freelancer['avatar'] as String)
                          : null,
                      child: (freelancer['avatar'] as String).isEmpty
                          ? Text(
                              (freelancer['name'] as String).isNotEmpty
                                  ? (freelancer['name'] as String)[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Verified
                        Row(
                          children: [
                            Text(
                              freelancer['name'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Category + Level
                        Row(
                          children: [
                            Text(
                              freelancer['category'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              freelancer['experienceLevel'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite
                  GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isFavorite ? Colors.red : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle section - Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _StatItem(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFB800),
                    value: '${freelancer['rating']}',
                    label: '${freelancer['reviewsCount']} avis',
                  ),
                  const SizedBox(width: 20),
                  _StatItem(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.primary,
                    value: '${freelancer['missionsCount']}',
                    label: 'missions',
                  ),
                  const SizedBox(width: 20),
                  _StatItem(
                    icon: Icons.flash_on_rounded,
                    iconColor: Colors.orange,
                    value: freelancer['responseTime'] ?? '2h',
                    label: 'réponse',
                  ),
                  const Spacer(),
                  // Price tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${freelancer['hourlyRate']}€',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section - Services
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (freelancer['services'] as List)
                          .take(3)
                          .map<Widget>((service) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🎛️ Sheet Filtres
/// ─────────────────────────────────────────────────────────────
class _FiltersSheet extends StatefulWidget {
  final RangeValues priceRange;
  final double minRating;
  final bool onlineOnly;
  final bool verifiedOnly;
  final Function(RangeValues, double, bool, bool) onApply;
  final VoidCallback onReset;

  const _FiltersSheet({
    required this.priceRange,
    required this.minRating,
    required this.onlineOnly,
    required this.verifiedOnly,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late RangeValues _priceRange;
  late double _minRating;
  late bool _onlineOnly;
  late bool _verifiedOnly;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.priceRange;
    _minRating = widget.minRating;
    _onlineOnly = widget.onlineOnly;
    _verifiedOnly = widget.verifiedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Réinitialiser',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix
                  const Text(
                    'Tarif horaire',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_priceRange.start.round()} €',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '${_priceRange.end.round()} €',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey[300],
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),

                  const SizedBox(height: 24),

                  // Note minimale
                  const Text(
                    'Note minimale',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [0.0, 3.0, 3.5, 4.0, 4.5].map((rating) {
                      final isSelected = _minRating == rating;
                      return GestureDetector(
                        onTap: () => setState(() => _minRating = rating),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (rating > 0) ...[
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                rating == 0 ? 'Tous' : rating.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Autres filtres
                  const Text(
                    'Autres options',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  _FilterSwitch(
                    icon: Icons.circle,
                    iconColor: Colors.green,
                    label: 'Disponibles maintenant',
                    value: _onlineOnly,
                    onChanged: (v) => setState(() => _onlineOnly = v),
                  ),

                  _FilterSwitch(
                    icon: Icons.verified_rounded,
                    iconColor: AppColors.primary,
                    label: 'Profils vérifiés uniquement',
                    value: _verifiedOnly,
                    onChanged: (v) => setState(() => _verifiedOnly = v),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _priceRange,
                    _minRating,
                    _onlineOnly,
                    _verifiedOnly,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitch({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📊 Sheet Tri
/// ─────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSelect;

  const _SortSheet({required this.currentSort, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'value': 'recommended',
        'label': 'Recommandés',
        'icon': Icons.recommend_rounded,
      },
      {
        'value': 'rating',
        'label': 'Meilleures notes',
        'icon': Icons.star_rounded,
      },
      {
        'value': 'reviews',
        'label': 'Plus d\'avis',
        'icon': Icons.reviews_rounded,
      },
      {
        'value': 'price_low',
        'label': 'Prix croissant',
        'icon': Icons.arrow_upward_rounded,
      },
      {
        'value': 'price_high',
        'label': 'Prix décroissant',
        'icon': Icons.arrow_downward_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text(
            'Trier par',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          ...options.map((option) {
            final isSelected = currentSort == option['value'];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  option['icon'] as IconData,
                  size: 20,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
              ),
              title: Text(
                option['label'] as String,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : Colors.grey[700],
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => onSelect(option['value'] as String),
            );
          }),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
