import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Header ───
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withGreen(200)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: AppInsets.a20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppGap.h20,
                        Text(
                          'Comment pouvons-nous vous aider ?',
                          style: context.profilePageTitleStyle.copyWith(
                            fontSize: AppFontSize.h2,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppGap.h16,
                        AppSurfaceCard(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDesign.radius12),
                          child: TextField(
                            controller: _searchController,
                            decoration: AppInputDecorations.searchField(
                              context,
                              hintText: 'Rechercher une question...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Catégories rapides ───
          SliverToBoxAdapter(
            child: Padding(
              padding: AppInsets.a16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Catégories', padding: EdgeInsets.zero),
                  AppGap.h12,
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _CategoryCard(
                        icon: Icons.rocket_launch_rounded,
                        title: 'Débuter',
                        color: AppColors.info,
                        onTap: () {},
                      ),
                      _CategoryCard(
                        icon: Icons.work_rounded,
                        title: 'Missions',
                        color: AppColors.success,
                        onTap: () {},
                      ),
                      _CategoryCard(
                        icon: Icons.payments_rounded,
                        title: 'Paiements',
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      _CategoryCard(
                        icon: Icons.person_rounded,
                        title: 'Mon compte',
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _CategoryCard(
                        icon: Icons.security_rounded,
                        title: 'Sécurité',
                        color: Colors.red,
                        onTap: () {},
                      ),
                      _CategoryCard(
                        icon: Icons.gavel_rounded,
                        title: 'Litiges',
                        color: AppColors.secondary,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Questions fréquentes ───
          SliverToBoxAdapter(
            child: Padding(
              padding: AppInsets.h16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Questions fréquentes', padding: EdgeInsets.zero),
                  AppGap.h12,
                  _FAQSection(
                    title: 'Missions',
                    questions: [
                      _FAQ(
                        question: 'Comment postuler à une mission ?',
                        answer: 'Pour postuler à une mission, rendez-vous sur la page d\'accueil et parcourez les missions disponibles. Cliquez sur une mission qui vous intéresse, puis sur "Postuler". Vous devrez indiquer votre tarif et envoyer un message de présentation au client.',
                      ),
                      _FAQ(
                        question: 'Comment annuler une mission ?',
                        answer: 'Pour annuler une mission, rendez-vous dans "Mes missions", sélectionnez la mission concernée et cliquez sur "Annuler". Attention : les annulations répétées peuvent affecter votre note.',
                      ),
                      _FAQ(
                        question: 'Que faire en cas de problème pendant une mission ?',
                        answer: 'En cas de problème, contactez d\'abord le client via la messagerie. Si le problème persiste, vous pouvez ouvrir un litige depuis la page de la mission ou contacter notre support.',
                      ),
                    ],
                  ),
                  AppGap.h16,
                  _FAQSection(
                    title: 'Paiements',
                    questions: [
                      _FAQ(
                        question: 'Quand vais-je recevoir mon paiement ?',
                        answer: 'Le paiement est crédité sur votre portefeuille Inkern 24h après la validation de la mission par le client. Vous pouvez ensuite retirer les fonds vers votre compte bancaire (2-3 jours ouvrés).',
                      ),
                      _FAQ(
                        question: 'Quelle est la commission Inkern ?',
                        answer: 'Inkern prélève une commission de 10% sur chaque mission réalisée. Cette commission couvre les frais de paiement sécurisé, l\'assurance et le support.',
                      ),
                      _FAQ(
                        question: 'Comment retirer mon argent ?',
                        answer: 'Rendez-vous dans votre portefeuille, cliquez sur "Retirer" et saisissez le montant souhaité. Le virement sera effectué sous 2-3 jours ouvrés sur votre compte bancaire enregistré.',
                      ),
                    ],
                  ),
                  AppGap.h16,
                  _FAQSection(
                    title: 'Compte et profil',
                    questions: [
                      _FAQ(
                        question: 'Comment vérifier mon compte ?',
                        answer: 'Pour vérifier votre compte, rendez-vous dans Paramètres > Vérification d\'identité. Vous devrez fournir une pièce d\'identité et prendre un selfie. La vérification prend généralement 24-48h.',
                      ),
                      _FAQ(
                        question: 'Comment modifier mes disponibilités ?',
                        answer: 'Accédez à votre profil, cliquez sur "Modifier" puis sur la section "Disponibilités". Vous pouvez définir vos horaires pour chaque jour de la semaine.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Contact support ───
          SliverToBoxAdapter(
            child: Padding(
              padding: AppInsets.a16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Besoin d\'aide supplémentaire ?', padding: EdgeInsets.zero),
                  AppGap.h12,
                  AppSurfaceCard(
                    padding: AppInsets.a20,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    child: Column(
                      children: [
                        _ContactOption(
                          icon: Icons.chat_bubble_rounded,
                          title: 'Chat en direct',
                          subtitle: 'Réponse immédiate',
                          color: AppColors.primary,
                          onTap: () {},
                        ),
                        const Divider(height: 24),
                        _ContactOption(
                          icon: Icons.email_rounded,
                          title: 'Envoyer un email',
                          subtitle: 'support@cigale.fr',
                          color: AppColors.info,
                          onTap: () {},
                        ),
                        const Divider(height: 24),
                        _ContactOption(
                          icon: Icons.phone_rounded,
                          title: 'Appeler',
                          subtitle: '01 23 45 67 89 (9h-18h)',
                          color: AppColors.success,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Tutoriels vidéo ───
          SliverToBoxAdapter(
            child: Padding(
              padding: AppInsets.h16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: 'Tutoriels vidéo',
                    padding: EdgeInsets.zero,
                    trailing: AppButton(
                      label: 'Voir tout',
                      variant: ButtonVariant.ghost,
                      width: null,
                      onPressed: () {},
                    ),
                  ),
                  AppGap.h8,
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _VideoCard(
                          title: 'Créer votre profil parfait',
                          duration: '3:42',
                          thumbnail: 'https://picsum.photos/200/120?random=1',
                        ),
                        _VideoCard(
                          title: 'Postuler à votre première mission',
                          duration: '5:15',
                          thumbnail: 'https://picsum.photos/200/120?random=2',
                        ),
                        _VideoCard(
                          title: 'Gérer vos paiements',
                          duration: '4:28',
                          thumbnail: 'https://picsum.photos/200/120?random=3',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: AppGap.h32,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppSurfaceCard(
        padding: AppInsets.a16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSurfaceCard(
              padding: AppInsets.a12,
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesign.radiusFull),
              child: Icon(icon, color: color, size: 26),
            ),
            AppGap.h10,
            Text(
              title,
              style: context.profilePrimaryLabelStyle.copyWith(
                fontSize: AppFontSize.base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQSection extends StatelessWidget {
  final String title;
  final List<_FAQ> questions;

  const _FAQSection({
    required this.title,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: context.profilePrimaryLabelStyle.copyWith(
                fontSize: AppFontSize.base,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ...questions.map((q) => _FAQTile(faq: q)),
        ],
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;

  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: AppInsets.h16v14,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: context.profilePrimaryLabelStyle.copyWith(
                      fontSize: AppFontSize.body,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.faq.answer,
              style: context.profileSecondaryLabelStyle.copyWith(
                fontSize: AppFontSize.base,
                height: 1.5,
              ),
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(height: 1, color: context.colors.divider),
      ],
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a12,
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            child: Icon(icon, color: color, size: 24),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.profilePrimaryLabelStyle.copyWith(fontSize: AppFontSize.body)),
                Text(subtitle, style: context.profileSecondaryLabelStyle),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textHint),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String thumbnail;

  const _VideoCard({
    required this.title,
    required this.duration,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDesign.radius12),
                child: Image.network(
                  thumbnail,
                  width: 200,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200,
                    height: 110,
                    color: context.colors.border,
                    child: Icon(Icons.play_circle_fill, size: 40, color: context.colors.textHint),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: AppInsets.h8v4,
                  decoration: BoxDecoration(
                    color: context.colors.textPrimary,
                    borderRadius: BorderRadius.circular(AppDesign.radius4),
                  ),
                  child: Text(
                    duration,
                    style: context.profilePrimaryLabelStyle.copyWith(
                      color: Colors.white,
                      fontSize: AppFontSize.sm,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: AppInsets.a12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                  ),
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            title,
            style: context.profilePrimaryLabelStyle.copyWith(
              fontSize: AppFontSize.md,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ({required this.question, required this.answer});
}
