import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/payment_security_card.dart';
import '../../widgets/status_dot_badge.dart';
import '../login/login_page.dart';
import '../register/register_flow.dart';
import 'widgets/categories_section.dart';
import 'widgets/freelancers_section.dart';
import 'widgets/users_section.dart';

// ─── Page d'accueil visiteur ──────────────────────────────────────────────────

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _HeroSection()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AppSectionHeader(title: 'Catégories populaires', padding: EdgeInsets.zero),
                        AppGap.h14,
                        const CategoriesRow(),
                        AppGap.h32,
                        const StatusDotBadge(),
                        AppGap.h32,
                        AppSectionHeader(title: 'Prestataires de confiance', padding: EdgeInsets.zero),
                        AppGap.h6,
                        Text(
                          'Basés sur les avis, la fiabilité et la réactivité',
                          style: context.text.bodyMedium?.copyWith(
                            fontSize: AppFontSize.base,
                            color: context.colors.textTertiary,
                          ),
                        ),
                        AppGap.h20,
                        const FreelancersRow(),
                        AppGap.h16,
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                'Voir tous les prestataires',
                                style: context.text.titleSmall?.copyWith(
                                  fontSize: AppFontSize.base,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppGap.w4,
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        AppGap.h32,
                        const PaymentSecurityCard(),
                        AppGap.h32,
                        AppSectionHeader(title: 'Inkern, pour qui ?', padding: EdgeInsets.zero),
                        AppGap.h6,
                        Text(
                          'Découvrez comment Inkern peut vous aider',
                          style: context.text.bodyMedium?.copyWith(
                            fontSize: AppFontSize.base,
                            color: context.colors.textTertiary,
                          ),
                        ),
                        AppGap.h16,
                        const FeaturesSection(),
                        AppGap.h32,
                        AppSurfaceCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 20,
                          ),
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppDesign.radius16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('10K+', 'Prestataires'),
                              Container(
                                height: 36,
                                width: 1,
                                color: Colors.white24,
                              ),
                              _statItem('50K+', 'Missions'),
                              Container(
                                height: 36,
                                width: 1,
                                color: Colors.white24,
                              ),
                              _statItem('4.8', 'Note moyenne'),
                            ],
                          ),
                        ),
                        AppGap.h8,
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const _BottomAuthBar(),
          ],
        ),
      ),
    );
  }

  static Widget _statItem(String value, String label) {
    return Builder(
      builder: (context) => Column(
        children: [
          Text(
            value,
            style: context.text.headlineLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          AppGap.h4,
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section hero ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      color: context.colors.surface,
      borderRadius: BorderRadius.zero,
      border: Border(
        bottom: BorderSide(color: context.colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Marque ───
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDesign.radius10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              AppGap.w10,
              Text(
                'La Cigale',
                style: context.text.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          AppGap.h22,

          // ─── Titre principal ───
          Text(
            'Trouvez le prestataire\nqu\'il vous faut',
            style: context.text.bodyMedium?.copyWith(
              fontSize: AppFontSize.d1,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
              height: 1.2,
            ),
          ),
          AppGap.h10,
          Text(
            'Ménage, jardinage, bricolage et bien plus encore.',
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),

          AppGap.h20,

          // ─── Indicateurs de confiance ───
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.rating,
                size: 16,
              ),
              AppGap.w4,
              Text(
                '4.8/5',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.w4,
              Text(
                'note moyenne',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              AppGap.w12,
              Container(width: 1, height: 14, color: context.colors.border),
              AppGap.w12,
              Text(
                '10K+',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              AppGap.w4,
              Text(
                'prestataires',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Barre fixe en bas : Créer un compte / Se connecter ──────────────────────

class _BottomAuthBar extends StatelessWidget {
  const _BottomAuthBar();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AppSection(
      color: context.colors.surface,
      child: SafeArea(
        top: false,
        child: AppSection(
          padding: AppInsets.h20v14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoogleSignInButton(
                isLoading: auth.isLoading,
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final err = await context.read<AuthProvider>().signInWithGoogle();
                        if (err != null && context.mounted) {
                          showAppSnackBar(context, err, type: SnackBarType.error);
                        }
                      },
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.border)),
                  Padding(
                    padding: AppInsets.h12,
                    child: Text(
                      'ou',
                      style: context.text.bodySmall?.copyWith(
                        fontSize: AppFontSize.md,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.border)),
                ],
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Créer un compte',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterFlow(),
                        ),
                      ),
                      variant: ButtonVariant.black,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: AppButton(
                      label: 'Se connecter',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      variant: ButtonVariant.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
