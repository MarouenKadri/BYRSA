import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
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

                        // ─── Catégories ───
                        _sectionHeader('Catégories populaires'),
                        const SizedBox(height: 14),
                        const CategoriesRow(),
                        const SizedBox(height: 32),

                        // ─── Disponibilité ───
                        const StatusDotBadge(),
                        const SizedBox(height: 32),

                        // ─── Prestataires ───
                        _sectionHeader('Prestataires de confiance'),
                        const SizedBox(height: 6),
                        Text(
                          'Basés sur les avis, la fiabilité et la réactivité',
                          style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 20),
                        const FreelancersRow(),
                        const SizedBox(height: 16),

                        // Voir tous
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                'Voir tous les prestataires',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ─── Paiement sécurisé ───
                        const PaymentSecurityCard(),
                        const SizedBox(height: 32),

                        // ─── Pour qui ? ───
                        _sectionHeader('Inkern, pour qui ?'),
                        const SizedBox(height: 6),
                        Text(
                          'Découvrez comment Inkern peut vous aider',
                          style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 16),
                        const FeaturesSection(),
                        const SizedBox(height: 32),

                        // ─── Stats ───
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
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

                        const SizedBox(height: 8),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Barre fixe en bas ───
            const _BottomAuthBar(),
          ],
        ),
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  static Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Section hero ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'La Cigale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ─── Titre principal ───
          const Text(
            'Trouvez le prestataire\nqu\'il vous faut',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ménage, jardinage, bricolage et bien plus encore.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // ─── Indicateurs de confiance ───
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.rating,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                '4.8/5',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'note moyenne',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 14, color: AppColors.border),
              const SizedBox(width: 12),
              Text(
                '10K+',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'prestataires',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Google Sign-In ───
              GoogleSignInButton(
                isLoading: auth.isLoading,
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final err = await context.read<AuthProvider>().signInWithGoogle();
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(height: 12),
              // ─── divider "ou" ───
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 12),
              // ─── Créer un compte / Se connecter ───
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterFlow(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
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
