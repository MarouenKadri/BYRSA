import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../app/widgets/cigale_app_bar.dart';
import '../../../../auth/services/image_picker_service.dart';
import '../../widgets/shared/user_common_widgets.dart';
import '../../../../post/post.dart';
import '../../../../post/post_provider.dart';
import '../freelancer/my_posts_page.dart';
import '../../../../reviews/presentation/pages/my_reviews_page.dart';
import '../client/client_wallet_page.dart';
import '../client/client_payment_methods_page.dart';
import '../client/client_payment_history_page.dart';
import '../shared/wallet_page.dart';
import '../shared/payment_history_page.dart';
import '../freelancer/freelancer_payment_methods_page.dart';
import '../shared/change_password_page.dart';
import '../../../profile_provider.dart';
import '../freelancer/edit_profile_page.dart';

/// Page Mon Compte avec TabBar
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: CigaleAppBar(
        pageTitle: 'Mon compte',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'À propos de vous'),
            Tab(text: 'Portefeuille'),
            Tab(text: 'Sécurité'),
            Tab(text: 'Support'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProfilTab(),
          _PortefeuilleTab(),
          _SecuriteTabPage(),
          _SupportTab(),
        ],
      ),
    );
  }

}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProv = context.watch<ProfileProvider>();
    final isFreelancerMode = auth.currentRole == UserRole.provider;
    final profile = profileProv.profile;
    final displayName = profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Utilisateur';
    final avatarUrl = profile?.avatarUrl;
    final isVerified = profile?.isVerified ?? false;
    final isUploading = profileProv.isSaving;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: isUploading ? null : () => _pickAvatar(context, profileProv),
            child: Stack(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.surfaceAlt,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person_rounded, size: 35, color: AppColors.textHint)
                      : null,
                ),
                // Overlay chargement
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Badge caméra (masqué pendant l'upload)
                if (!isUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                    ),
                  ),
                // Badge vérifié (coin opposé)
                if (isVerified && !isUploading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  isFreelancerMode ? 'Mode Freelancer actif' : 'Mode Client actif',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, ProfileProvider profileProv) async {
    final file = await ImagePickerService.showPicker(context);
    if (file == null) return;
    await profileProv.uploadAvatar(file);
  }
}

/// ─────────────────────────────────────────────────────────────
/// 👤 Onglet Profil
/// ─────────────────────────────────────────────────────────────
class _ProfilTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        context.watch<AuthProvider>().currentRole == UserRole.provider;

    return isFreelancer
        ? _FreelancerProfilTab(header: _ProfileHeader())
        : _ClientProfilTab(header: _ProfileHeader());
  }
}

/// ─── Profil Freelancer ───────────────────────────────────────────────────────
class _FreelancerProfilTab extends StatelessWidget {
  final Widget header;
  const _FreelancerProfilTab({required this.header});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        header,
        const SizedBox(height: 16),
        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.edit_rounded,
              iconColor: AppColors.success,
              title: 'Modifier mon profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _MenuItem(
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              title: 'Mes avis',
              subtitle: '112 avis • 4.9/5',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReviewsPage(isFreelancer: true)),
              ),
              showDivider: false,
            ),
          ],
        ),

        const SizedBox(height: 16),

        const SizedBox(height: 16),

        // ─── Section Mes Publications ───
        _MyPostsSection(),
      ],
    );
  }
}

class _MyPostsSection extends StatelessWidget {
  void _createPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts
        .where((p) => p.isOwner)
        .toList();
    final preview = posts.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grid_on_rounded, size: 18, color: Colors.pink),
                ),
                const SizedBox(width: 10),
                Text(
                  'Mes publications',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (posts.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${posts.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (posts.isNotEmpty)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPostsPage()),
                    ),
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          if (posts.isEmpty)
            // ─── Empty state ───
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Icon(Icons.post_add_rounded, size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune publication pour le moment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Partagez vos réalisations avec la communauté',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _createPost(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Créer une publication'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // ─── Grid de posts ───
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: preview.length + 1, // +1 for "add" cell
                    itemBuilder: (context, index) {
                      // Dernière cellule = bouton "+"
                      if (index == preview.length) {
                        return GestureDetector(
                          onTap: () => _createPost(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, size: 28, color: AppColors.primary),
                                const SizedBox(height: 4),
                                Text(
                                  'Publier',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final post = preview[index];
                      final hasImage = post.images.isNotEmpty;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyPostsPage(),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: hasImage
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      post.images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _PostTextThumb(post.content),
                                    ),
                                    if (post.images.length > 1)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.photo_library_rounded, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                )
                              : _PostTextThumb(post.content),
                        ),
                      );
                    },
                  ),
                  if (posts.length > 6) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyPostsPage()),
                      ),
                      child: Text(
                        'Voir les ${posts.length - 6} autres publications →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _PostTextThumb extends StatelessWidget {
  final String content;
  const _PostTextThumb(this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

/// ─── Profil Client ───────────────────────────────────────────────────────────
class _ClientProfilTab extends StatelessWidget {
  final Widget header;
  const _ClientProfilTab({required this.header});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        header,
        const SizedBox(height: 16),
        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.edit_rounded,
              iconColor: AppColors.success,
              title: 'Modifier mon profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _MenuItem(
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              title: 'Mes avis',
              subtitle: '24 avis • 4.7/5',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReviewsPage(isFreelancer: false)),
              ),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 💰 Onglet Paiements
/// ─────────────────────────────────────────────────────────────
/// ─────────────────────────────────────────────────────────────
/// 💳 Onglet Portefeuille
/// ─────────────────────────────────────────────────────────────
class _PortefeuilleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isFreelancer = context.read<AuthProvider>().currentRole == UserRole.provider;
    final gradient = isFreelancer
        ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
        : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)];
    final balance = isFreelancer ? '245,50 €' : '50,00 €';
    final balanceLabel = isFreelancer ? 'Solde disponible' : 'Crédit disponible';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(balanceLabel, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text(balance, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            ])),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _MenuCard(children: [
          _MenuItem(
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: 'Moyens de paiement',
            subtitle: 'Cartes et virements',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => isFreelancer ? const FreelancerPaymentMethodsPage() : const ClientPaymentMethodsPage())),
          ),
          _MenuItem(
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.info,
            title: 'Historique',
            subtitle: 'Toutes vos transactions',
            showDivider: false,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => isFreelancer ? const PaymentHistoryPage() : const ClientPaymentHistoryPage())),
          ),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🔒 Onglet Sécurité
/// ─────────────────────────────────────────────────────────────
class _SecuriteTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuCard(children: [
          _MenuItem(
            icon: Icons.verified_rounded,
            iconColor: AppColors.primary,
            title: 'Vérification d\'identité',
            trailing: _StatusBadge(isActive: true, label: 'Vérifié'),
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.lock_rounded,
            iconColor: AppColors.error,
            title: 'Mot de passe',
            subtitle: 'Modifié il y a 3 mois',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
          ),
          _MenuItem(
            icon: Icons.visibility_rounded,
            iconColor: AppColors.info,
            title: 'Confidentialité',
            onTap: () {},
            showDivider: false,
          ),
        ]),
        const SizedBox(height: 12),
        _MenuCard(children: [
          _MenuItem(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.error,
            title: 'Supprimer mon compte',
            subtitle: 'Action irréversible',
            showDivider: false,
            onTap: () => _showDeleteAccount(context),
          ),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDeleteAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🆘 Onglet Support
/// ─────────────────────────────────────────────────────────────
class _SupportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuCard(children: [
          _MenuItem(icon: Icons.help_outline_rounded, iconColor: AppColors.primary, title: 'Centre d\'aide', onTap: () {}),
          _MenuItem(icon: Icons.chat_bubble_outline_rounded, iconColor: AppColors.success, title: 'Nous contacter', onTap: () {}),
          _MenuItem(icon: Icons.star_outline_rounded, iconColor: const Color(0xFFF59E0B), title: 'Noter l\'application', showDivider: false, onTap: () {}),
        ]),
        const SizedBox(height: 12),
        _MenuCard(children: [
          _MenuItem(
            icon: Icons.logout_rounded,
            iconColor: AppColors.error,
            title: 'Se déconnecter',
            showDivider: false,
            onTap: () async => await context.read<AuthProvider>().logout(),
          ),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Page suppression de compte ──────────────────────────────────────────────

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage();
  @override
  State<DeleteAccountPage> createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _confirmed = false;

  Future<void> _confirm() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isGoogleUser && _controller.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre mot de passe');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final errorMsg = await auth.deleteAccount(_controller.text.trim());
    if (!mounted) return;
    if (errorMsg != null) {
      setState(() { _isLoading = false; _error = errorMsg; });
    } else {
      // Utiliser le navigator racine pour sortir de toute la stack de navigation
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = context.read<AuthProvider>().isGoogleUser;
    final canDelete = _confirmed && (_isLoading == false);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
        title: const Text('Supprimer le compte', style: AppTextStyles.h4),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 28, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Icône danger ───────────────────────────────────────────────
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1.5),
                ),
                child: const Icon(Icons.no_accounts_rounded, color: AppColors.error, size: 38),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Supprimer mon compte', style: AppTextStyles.h3),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Cette action est permanente et irréversible.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // ─── Ce qui sera supprimé ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text('Les données suivantes seront supprimées :',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 10),
                  ...[
                    'Votre profil et informations personnelles',
                    'Vos missions et candidatures',
                    'Vos publications et votes',
                    'Vos avis et évaluations',
                    'Vos messages et conversations',
                    'Votre historique de transactions',
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.remove_circle_outline_rounded,
                              size: 13, color: AppColors.error),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary, height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Confirmation identité ──────────────────────────────────────
            Text(
              isGoogleUser ? 'Confirmation' : 'Confirmez votre identité',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 6),
            Text(
              isGoogleUser
                  ? 'Cochez la case ci-dessous pour confirmer la suppression.'
                  : 'Entrez votre mot de passe pour confirmer.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            if (!isGoogleUser) ...[
              TextField(
                controller: _controller,
                obscureText: _obscure,
                onSubmitted: (_) { if (canDelete) _confirm(); },
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.error)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, size: 15, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                ]),
              ),
              const SizedBox(height: 8),
            ],

            // ─── Checkbox confirmation ──────────────────────────────────────
            InkWell(
              onTap: _isLoading ? null : () => setState(() => _confirmed = !_confirmed),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _confirmed,
                        onChanged: _isLoading ? null : (v) => setState(() => _confirmed = v ?? false),
                        activeColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: _confirmed ? AppColors.error : AppColors.border, width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Je comprends que cette action est définitive et que mes données ne pourront pas être récupérées.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _confirmed ? AppColors.textPrimary : AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ─── Bouton supprimer ───────────────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: (canDelete && _confirmed) ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.error.withOpacity(0.3),
                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Supprimer définitivement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text('Annuler', style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.0,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────

class _PaiementsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isFreelancer = context.read<AuthProvider>().currentRole == UserRole.provider;
    final gradient = isFreelancer
        ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
        : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)];
    final balance = isFreelancer ? '245,50 €' : '50,00 €';
    final balanceLabel = isFreelancer ? 'Solde disponible' : 'Crédit disponible';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Carte solde ───
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => isFreelancer ? const WalletPage() : const ClientWalletPage())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(balanceLabel, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 8),
                Text(balance, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 16),
                Row(children: [
                  const Spacer(),
                  Text('Voir le portefeuille →',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ─── Menu ───
        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: isFreelancer ? AppColors.primary : const Color(0xFF2563EB),
              title: 'Mon portefeuille',
              subtitle: isFreelancer ? 'Solde & retraits' : 'Crédit & recharges',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => isFreelancer ? const WalletPage() : const ClientWalletPage())),
            ),
            _MenuItem(
              icon: isFreelancer ? Icons.account_balance_rounded : Icons.credit_card_rounded,
              iconColor: isFreelancer ? Colors.indigo : AppColors.info,
              title: isFreelancer ? 'Coordonnées bancaires' : 'Moyens de paiement',
              subtitle: isFreelancer ? 'IBAN •••• 1234' : 'Visa •••• 4242',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => isFreelancer
                      ? const FreelancerPaymentMethodsPage()
                      : const ClientPaymentMethodsPage())),
            ),
            _MenuItem(
              icon: Icons.receipt_long_rounded,
              iconColor: Colors.teal,
              title: 'Historique des paiements',
              subtitle: isFreelancer ? 'Revenus & retraits' : 'Paiements & remboursements',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => isFreelancer
                      ? const PaymentHistoryPage()
                      : const ClientPaymentHistoryPage())),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🔒 Onglet Sécurité
/// ─────────────────────────────────────────────────────────────
class _SecuriteTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.lock_rounded,
              iconColor: AppColors.error,
              title: 'Mot de passe',
              subtitle: 'Modifié il y a 3 mois',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
            ),
            _MenuItem(
              icon: Icons.visibility_rounded,
              iconColor: AppColors.info,
              title: 'Confidentialité',
              onTap: () {},
              showDivider: false,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Déconnexion
        OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => _showDeleteAccountDialog(context),
          child: const Text(
            'Supprimer mon compte',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
    );
  }
}


/// ─────────────────────────────────────────────────────────────
/// ❓ Onglet Aide
/// ─────────────────────────────────────────────────────────────
class _AideTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.chat_bubble_rounded,
              iconColor: AppColors.primary,
              title: 'Contacter le support',
              subtitle: 'Réponse sous 24h',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.bug_report_rounded,
              iconColor: Colors.orange,
              title: 'Signaler un problème',
              onTap: () {},
              showDivider: false,
            ),
          ],
        ),

        const SizedBox(height: 16),

        _MenuCard(
          children: [
            _MenuItem(
              icon: Icons.description_rounded,
              iconColor: Colors.grey,
              title: 'Conditions d\'utilisation',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.privacy_tip_rounded,
              iconColor: AppColors.secondary,
              title: 'Politique de confidentialité',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_rounded,
              iconColor: AppColors.primary,
              title: 'À propos de Inkern',
              subtitle: 'Version 1.0.0',
              onTap: () {},
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🏷️ Widgets auxiliaires
/// ─────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 16, color: AppColors.divider),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final String label;

  const _StatusBadge({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

