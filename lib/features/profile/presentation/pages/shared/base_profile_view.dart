import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../mission/presentation/widgets/detail/mission_detail_primitives.dart';
import '../../../../reviews/presentation/providers/review_provider.dart';
import '../../../../reviews/presentation/widgets/reviews_summary.dart';
import '../../../../reviews/presentation/widgets/reviews_tab.dart';

enum _ProfileTab { info, reviews, publications }

/// ═══════════════════════════════════════════════════════════════════════════
/// Data classes
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileStatData {
  final IconData icon;
  final String value;
  final String label;
  const ProfileStatData({required this.icon, required this.value, required this.label});
}

class VerifiedItemData {
  final String label;
  final bool verified;
  final bool warning;
  const VerifiedItemData({required this.label, this.verified = false, this.warning = false});
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BaseProfileState — Template Method
///
/// Sous-classes :
///   _FreelancerProfilePageState  →  tarif €/h, bio DB, carte map
///   _ClientProfileViewState      →  rating étoiles, bio auto, pas de map
/// ═══════════════════════════════════════════════════════════════════════════

abstract class BaseProfileState<T extends StatefulWidget> extends State<T> {
  bool isOpeningChat = false;
  _ProfileTab _activeTab = _ProfileTab.info;

  // ── À fournir par la sous-classe ─────────────────────────────────────────

  String get profileName;
  String get profileAvatar;
  double get profileRating;
  int get profileReviewsCount;
  String get profileLevel;
  bool get isLoadingProfile;

  /// ID Supabase du profil affiché — pour charger ses avis reçus.
  String? get profileUserId;

  /// Affiche le 3ème onglet "Publications" (seulement FreelancerProfileView).
  bool get showPublicationsTab => false;

  /// Contenu de l'onglet Publications — surchargé par FreelancerProfileView.
  Widget buildPublicationsContent(BuildContext context) => const SizedBox.shrink();

  /// Barre de stories (cercles catégories) dans l'onglet Information — surchargé par FreelancerProfileView.
  Widget? buildStoriesBar(BuildContext context) => null;

  /// Badge hero haut-droite (tarif chez freelancer, rating chez client)
  Widget buildHeroBadge(BuildContext context);

  /// 3 cellules de stats
  List<ProfileStatData> buildProfileStats();

  /// Section optionnelle sous les stats (bio + map pour freelancer)
  Widget? buildExtraSection(BuildContext context) => null;

  /// Card offre de prix (candidature) — uniquement freelancer
  Widget? buildProposalSection(BuildContext context) => null;

  /// Éléments de la section "Informations vérifiées"
  List<VerifiedItemData> get verifiedItems;

  /// Construit le ChatPage à ouvrir (params différents selon le rôle)
  Widget buildChatPage(String? conversationId);

  /// Résout (ou crée) la conversation — retourne l'ID ou null
  Future<String?> resolveConversationId(BuildContext context);

  /// Label du bouton bas (peut être surchargé)
  String get contactButtonLabel => 'Contacter';

  // ── Chat — implémentation commune ────────────────────────────────────────

  Future<void> openChat(BuildContext context) async {
    if (isOpeningChat) return;
    setState(() => isOpeningChat = true);

    String? conversationId;
    try {
      conversationId = await resolveConversationId(context);
    } catch (_) {}

    if (!mounted) return;
    setState(() => isOpeningChat = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => buildChatPage(conversationId)),
    );
  }

  // ── Template build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final proposal = buildProposalSection(context);
    final extra = buildExtraSection(context);

    final storiesBar = buildStoriesBar(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: context.colors.background,
            border: Border(top: BorderSide(color: context.colors.divider)),
          ),
          child: AppButton(
            label: isOpeningChat ? 'Connexion...' : contactButtonLabel,
            variant: ButtonVariant.black,
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: isOpeningChat ? null : () => openChat(context),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(context),
          // ── Pills toujours visibles ──
          _buildTabPills(context),
          // ── Contenu qui switche ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _activeTab == _ProfileTab.publications
                  ? KeyedSubtree(
                      key: const ValueKey('publications'),
                      child: buildPublicationsContent(context),
                    )
                  : _activeTab == _ProfileTab.reviews
                      ? _buildInlineReviews(context)
                      : SingleChildScrollView(
                          key: const ValueKey('info'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (proposal != null) proposal,
                              _buildProfileMetaSection(context),
                              if (storiesBar != null) storiesBar,
                              _buildVerifiedSection(context),
                              if (extra != null) extra,
                              AppGap.h32,
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineReviews(BuildContext context) {
    final userId = profileUserId;
    if (userId == null) {
      return Center(
        key: const ValueKey('reviews_empty'),
        child: Text(
          'Profil non disponible',
          style: context.text.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
      );
    }
    return ChangeNotifierProvider(
      key: ValueKey('reviews_$userId'),
      create: (_) => ReviewProvider(autoLoad: false)..loadReceivedFor(userId),
      child: _InlineReviewsContent(userId: userId),
    );
  }

  // ── Header photo plein écran ──────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        if (isLoadingProfile) const LinearProgressIndicator(minHeight: 2),
        SizedBox(
          height: 290,
          child: Stack(
            children: [
              Positioned.fill(
                child: profileAvatar.isNotEmpty
                    ? Image.network(
                        profileAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                      )
                    : _buildAvatarFallback(),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xC7000000),
                          Color(0x52000000),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.28, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPad + 4,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    DetailCircleBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    buildHeroBadge(context),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                    AppGap.h10,
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: ProfileLevelPill(level: profileLevel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF23272D), Color(0xFF3A4048)],
          ),
        ),
      );

  // ── Tab pills ─────────────────────────────────────────────────────────────

  Widget _buildTabPills(BuildContext context) {
    final pills = [
      ProfileTabPill(
        label: 'Information',
        icon: Icons.info_outline_rounded,
        active: _activeTab == _ProfileTab.info,
        onTap: () => setState(() => _activeTab = _ProfileTab.info),
      ),
      AppGap.w8,
      ProfileTabPill(
        label: '$profileReviewsCount avis · ${profileRating.toStringAsFixed(1)}★',
        icon: Icons.star_rounded,
        active: _activeTab == _ProfileTab.reviews,
        onTap: () => setState(() => _activeTab = _ProfileTab.reviews),
      ),
      if (showPublicationsTab) ...[
        AppGap.w8,
        ProfileTabPill(
          label: 'Publications',
          icon: Icons.photo_library_rounded,
          active: _activeTab == _ProfileTab.publications,
          onTap: () => setState(() => _activeTab = _ProfileTab.publications),
        ),
      ],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pills,
            ),
          ),
        );
      },
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _buildProfileMetaSection(BuildContext context) {
    final stats = buildProfileStats();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.gray50),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              if (i > 0) const ProfileStatDivider(),
              Expanded(
                child: ProfileStatCell(
                  icon: stats[i].icon,
                  value: stats[i].value,
                  label: stats[i].label,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Informations vérifiées ────────────────────────────────────────────────

  Widget _buildVerifiedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Informations vérifiées'),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < verifiedItems.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.gray50, indent: 31),
                  ProfileVerificationItem(
                    label: verifiedItems[i].label,
                    verified: verifiedItems[i].verified,
                    warning: verifiedItems[i].warning,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenu avis inline (provider isolé, scoped au ChangeNotifierProvider parent)
// ─────────────────────────────────────────────────────────────────────────────

class _InlineReviewsContent extends StatelessWidget {
  final String userId;
  const _InlineReviewsContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final reviews = provider.receivedReviews;

    if (provider.isLoading && reviews.isEmpty) {
      return const Center(
        key: ValueKey('reviews_loading'),
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      key: const ValueKey('reviews'),
      children: [
        ReviewsSummary(reviews: reviews),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<ReviewProvider>().loadReceivedFor(userId),
            child: ReviewsTab(
              reviews: reviews,
              emptyLabel: 'Aucun avis pour le moment',
              isReceived: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Widgets partagés (public pour être utilisés dans les sous-classes)
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileTabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const ProfileTabPill({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.inkDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.inkDark : AppColors.gray50),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : AppColors.gray600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.inkDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileLevelPill extends StatelessWidget {
  final String level;
  const ProfileLevelPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final lower = level.toLowerCase();
    final IconData icon;
    if (lower == 'ambassadeur') {
      icon = Icons.workspace_premium_rounded;
    } else if (lower == 'expert') {
      icon = Icons.military_tech_rounded;
    } else if (lower == 'pro') {
      icon = Icons.verified_rounded;
    } else {
      icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gray50, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gray600),
          const SizedBox(width: 5),
          Text(level, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ProfileStatDivider extends StatelessWidget {
  const ProfileStatDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: AppColors.gray50);
}

class ProfileStatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const ProfileStatCell({super.key, required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gray600),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class ProfileVerificationItem extends StatelessWidget {
  final String label;
  final bool verified;
  final bool warning;

  const ProfileVerificationItem({
    super.key,
    required this.label,
    this.verified = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData iconData;

    if (warning) {
      iconColor = AppColors.warning;
      iconData = Icons.warning_amber_rounded;
    } else if (verified) {
      iconColor = AppColors.successDark;
      iconData = Icons.check_circle_rounded;
    } else {
      iconColor = AppColors.error;
      iconData = Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(iconData, size: 17, color: iconColor),
          AppGap.w14,
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
