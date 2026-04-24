import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../auth/services/image_picker_service.dart';
import '../../../../reviews/presentation/pages/my_reviews_page.dart';
import '../../../../story/story.dart';
import '../../../../mission/data/models/service_category.dart';
import '../client/client_payment_methods_page.dart';
import '../shared/archives_page.dart';
import '../freelancer/freelancer_activity_page.dart';
import '../freelancer/freelancer_payment_methods_page.dart';
import 'change_password_page.dart';
import 'my_information_page.dart';
import '../../../profile_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 👤 Inkern - Page Mon Compte
/// ═══════════════════════════════════════════════════════════════════════════

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        context.watch<AuthProvider>().currentRole == UserRole.provider;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppSectionBar(pageTitle: 'Mon compte'),
      body: AppPageBody(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        useSafeAreaBottom: true,
        child: ListView(
          children: [
            _ProfileHeader(),
            if (isFreelancer) const _MyStoriesSection(),
            AppGap.h12,
            _FlatSection(
              label: 'COMPTE',
              children: [
                _FlatTile(
                  icon: Icons.badge_outlined,
                  title: 'Mes informations',
                  subtitle: '',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyInformationPage(),
                    ),
                  ),
                ),
                if (isFreelancer)
                  _FlatTile(
                    icon: Icons.work_outline,
                    title: 'Mon activité',
                    subtitle: 'Skills, tarif, localisation, disponibilité',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FreelancerActivityPage(),
                      ),
                    ),
                  ),
                if (!isFreelancer)
                  _FlatTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Archives',
                    subtitle: 'Missions terminées et annulées',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ArchivesPage()),
                    ),
                  ),
                _FlatTile(
                  icon: Icons.star_outline,
                  title: 'Mes avis',
                  subtitle: isFreelancer ? '112 avis · 4.9 / 5' : '24 avis · 4.7 / 5',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyReviewsPage(isFreelancer: isFreelancer),
                    ),
                  ),
                ),
              ],
            ),
            _FlatSection(
              label: 'PAIEMENTS ET SÉCURITÉ',
              children: [
                _FlatTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Finance',
                  subtitle: isFreelancer ? 'IBAN •••• 1234' : 'Visa •••• 4242',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => isFreelancer
                          ? const FreelancerPaymentMethodsPage()
                          : const ClientPaymentMethodsPage(),
                    ),
                  ),
                ),
                _FlatTile(
                  icon: Icons.verified_user_outlined,
                  title: "Vérification d'identité",
                  subtitle: 'Compte vérifié et protégé',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.success.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.colors.success.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Vérifié',
                      style: context.text.labelMedium?.copyWith(
                        fontSize: AppFontSize.sm,
                        fontWeight: FontWeight.w600,
                        color: context.colors.success,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.key_outlined,
                  title: 'Mot de passe',
                  subtitle: 'Modifié il y a 3 mois',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
                _FlatTile(
                  icon: Icons.shield_outlined,
                  title: 'Confidentialité',
                  subtitle: 'Autorisations, visibilité et données',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Supprimer mon compte',
                  subtitle: 'Action irréversible',
                  iconColor: context.colors.error,
                  titleColor: context.colors.error,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeleteAccountPage(),
                    ),
                  ),
                ),
              ],
            ),
            _FlatSection(
              label: 'AIDE ET SESSION',
              children: [
                _FlatTile(
                  icon: Icons.help_outline_rounded,
                  title: "Centre d'aide",
                  subtitle: 'Guides et réponses rapides',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Nous contacter',
                  subtitle: 'Réponse sous 24h',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.favorite_border_rounded,
                  title: "Noter l'application",
                  subtitle: 'Partager votre expérience',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.info_outline_rounded,
                  title: 'À propos de Inkern',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.logout_rounded,
                  title: 'Se déconnecter',
                  subtitle: 'Quitter la session en cours',
                  onTap: () async =>
                      await context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Widgets flat génériques ─────────────────────────────────────────────────

class _FlatSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FlatSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 16, bottom: 8),
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FlatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  const _FlatTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? context.colors.textSecondary,
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.w12,
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}

// ─── En-tête profil ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProv = context.watch<ProfileProvider>();
    final isFreelancerMode = auth.currentRole == UserRole.provider;
    final profile = profileProv.profile;
    final displayName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : 'Utilisateur';
    final avatarUrl = profile?.avatarUrl;
    final isVerified = profile?.isVerified ?? false;
    final isUploading = profileProv.isSaving;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: isUploading ? null : () => _pickAvatar(context, profileProv),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surfaceAlt,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.transparent,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary,
                            ),
                          )
                        : null,
                  ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isVerified && !isUploading)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: context.colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFontSize.h2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: context.colors.textPrimary,
                  ),
                ),
                AppGap.h4,
                Text(
                  isFreelancerMode ? 'Freelancer' : 'Client',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFontSize.md,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                  ),
                ),
                AppGap.h12,
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () => _pickAvatar(context, profileProv),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    backgroundColor: context.colors.surfaceAlt,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: context.colors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Modifier le profil',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      AppGap.w8,
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 15,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(
    BuildContext context,
    ProfileProvider profileProv,
  ) async {
    final file = await ImagePickerService.showPicker(context);
    if (file == null) return;
    await profileProv.uploadAvatar(file);
  }
}

// ─── Page suppression de compte ──────────────────────────────────────────────

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;
  bool _confirmed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isGoogleUser && _controller.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre mot de passe');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final errorMsg = await auth.deleteAccount(_controller.text.trim());
    if (!mounted) return;
    if (errorMsg != null) {
      setState(() {
        _isLoading = false;
        _error = errorMsg;
      });
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
  }

  bool get canDelete => _confirmed && !_isLoading;

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = context.read<AuthProvider>().isGoogleUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        titleWidget: Text(
          'Supprimer le compte',
          style: context.accountDialogTitleStyle,
        ),
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: AppInsets.a24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDangerBanner(
              title: 'Les données suivantes seront supprimées :',
              items: const [
                'Votre profil et informations personnelles',
                'Vos missions et candidatures',
                'Vos publications et votes',
                'Vos avis et évaluations',
                'Vos messages et conversations',
                'Votre historique de transactions',
              ],
            ),
            AppGap.h24,
            Text(
              isGoogleUser ? 'Confirmation' : 'Confirmez votre identité',
              style: context.text.labelLarge,
            ),
            AppGap.h6,
            Text(
              isGoogleUser
                  ? 'Cochez la case ci-dessous pour confirmer la suppression.'
                  : 'Entrez votre mot de passe pour confirmer.',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h14,
            if (!isGoogleUser) ...[
              TextField(
                controller: _controller,
                obscureText: _obscure,
                onSubmitted: (_) {
                  if (canDelete) _confirm();
                },
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.body,
                ),
                decoration:
                    AppInputDecorations.formField(
                      context,
                      hintText: 'Mot de passe',
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: context.colors.textTertiary,
                      ),
                      contentPadding: AppInsets.h16v16,
                    ).copyWith(
                      hintStyle: context.text.bodyLarge?.copyWith(
                        color: context.colors.textHint,
                        fontSize: AppFontSize.base,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: context.colors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
              ),
              AppGap.h8,
            ],
            if (_error != null) ...[
              AppErrorMessage(message: _error!),
              AppGap.h8,
            ],
            InkWell(
              onTap: _isLoading
                  ? null
                  : () => setState(() => _confirmed = !_confirmed),
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              child: Padding(
                padding: AppInsets.v4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _confirmed,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(() => _confirmed = v ?? false),
                        activeColor: context.colors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesign.radius4,
                          ),
                        ),
                        side: BorderSide(
                          color: _confirmed
                              ? context.colors.error
                              : context.colors.border,
                          width: 1.5,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    AppGap.w10,
                    Expanded(
                      child: Text(
                        'Je comprends que cette action est définitive et que mes données ne pourront pas être récupérées.',
                        style: context.text.bodyMedium?.copyWith(
                          color: _confirmed
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppGap.h28,
            AppButton(
              label: 'Supprimer définitivement',
              variant: ButtonVariant.destructive,
              onPressed: (canDelete && _confirmed) ? _confirm : null,
              isLoading: _isLoading,
              height: 54,
            ),
            AppGap.h10,
            AppButton(
              label: 'Annuler',
              variant: ButtonVariant.ghost,
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mes stories par catégorie ───────────────────────────────────────────────

class _MyStoriesSection extends StatefulWidget {
  const _MyStoriesSection();

  @override
  State<_MyStoriesSection> createState() => _MyStoriesSectionState();
}

class _MyStoriesSectionState extends State<_MyStoriesSection> {
  final Set<String> _viewed = {};

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<StoryProvider>().myStoryGroups;
    final profile = context.watch<ProfileProvider>().profile;
    final entries = CategoryStoryEntries.build(
      selectedCategories: profile?.serviceCategories ?? const <String>[],
      groups: groups,
    );

    final items = entries
        .map((entry) {
          final viewed = entry.hasStories
              ? _viewed.contains(entry.categoryId)
              : true;
          return CategoryStoryStripItem(
            categoryId: entry.categoryId,
            label: entry.label,
            count: entry.count,
            viewed: viewed,
            onTap: entry.hasStories
                ? () {
                    final index =
                        groups.indexWhere((g) => g.groupId == entry.categoryId);
                    if (index >= 0) _openViewer(context, groups, index);
                  }
                : null,
            onLongPress: entry.hasStories
                ? () => _showOptions(context, entry.group!)
                : null,
          );
        })
        .toList(growable: false);

    return CategoryStoryStrip(
      addAction: CategoryStoryStripAddAction(
        label: 'Ajouter',
        onTap: () => pickAndOpenComposer(context),
      ),
      items: items,
    );
  }

  void _openViewer(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: index,
          onViewed: (id) => setState(() => _viewed.add(id)),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _showOptions(BuildContext context, StoryGroup group) {
    final cat = ServiceCategory.findById(group.categoryId);
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: group.groupName,
        dark: false,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      cat?.color.withValues(alpha: 0.12) ??
                      context.colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  cat?.icon ?? Icons.photo_library_rounded,
                  size: 18,
                  color: cat?.color ?? AppColors.primary,
                ),
              ),
              AppGap.w10,
              Text(
                group.groupName,
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${group.stories.length} story${group.stories.length > 1 ? 's' : ''}',
                style: context.text.bodySmall?.copyWith(
                  fontSize: AppFontSize.sm,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        children: [
          Divider(height: 1, indent: 20, endIndent: 20),
          AppActionSheetItem(
            icon: Icons.play_circle_outline_rounded,
            title: 'Voir les stories',
            dark: false,
            onTap: () {
              Navigator.pop(context);
              final groups = context.read<StoryProvider>().myStoryGroups;
              final idx = groups.indexWhere((g) => g.groupId == group.groupId);
              if (idx >= 0) _openViewer(context, groups, idx);
            },
          ),
          AppActionSheetItem(
            icon: Icons.add_a_photo_rounded,
            title: 'Ajouter une story',
            dark: false,
            onTap: () {
              Navigator.pop(context);
              pickAndOpenComposer(context);
            },
          ),
          AppActionSheetItem(
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer cette catégorie',
            destructive: true,
            dark: false,
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteCategory(context, group);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, StoryGroup group) {
    showAppDialog(
      context: context,
      title: Text(
        'Supprimer "${group.groupName}"',
        style: context.accountDialogTitleStyle,
      ),
      content: Text(
        'Supprimer les ${group.stories.length} story${group.stories.length > 1 ? 's' : ''} de cette catégorie ? Action irréversible.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () async {
        Navigator.pop(context);
        final provider = context.read<StoryProvider>();
        for (final story in group.stories) {
          await provider.deleteStory(story.id);
        }
      },
    );
  }
}
