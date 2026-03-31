import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../theme/design_tokens.dart';

import '../../features/auth/presentation/pages/register/google_onboarding_flow.dart';
import 'guest_nav.dart';
import 'client_nav.dart';
import 'provider_nav.dart';

class RootNav extends StatelessWidget {
  const RootNav({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.needsRoleSelection) {
      return const GoogleOnboardingFlow();
    }

    if (!auth.isLogged) {
      return const GuestNav();
    }

    // _ModeSwitchSplash is only for role-switching (pendingRole set).
    // During login/logout, isLoading can be true but pendingRole is null — skip the splash.
    if (auth.isLoading && auth.pendingRole != null) {
      return _ModeSwitchSplash(targetRole: auth.pendingRole!);
    }

    switch (auth.currentRole) {
      case UserRole.client:
        return const ClientNav();
      case UserRole.provider:
        return const ProviderNav();
      case UserRole.guest:
      default:
        return const GuestNav();
    }
  }
}

// ─── Splash de transition ─────────────────────────────────────────────────────

class _ModeSwitchSplash extends StatefulWidget {
  final UserRole targetRole;
  const _ModeSwitchSplash({required this.targetRole});

  @override
  State<_ModeSwitchSplash> createState() => _ModeSwitchSplashState();
}

class _ModeSwitchSplashState extends State<_ModeSwitchSplash>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _progressCtrl;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _glow;
  late Animation<double> _progress;

  bool get _isClient => widget.targetRole == UserRole.client;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..forward();

    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _glow  = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClient    = _isClient;
    final modeLabel   = isClient ? 'Mode Client'      : 'Mode Prestataire';
    final modeIcon    = isClient ? Icons.person_rounded : Icons.handyman_rounded;
    final modeTagline = isClient
        ? 'Trouvez le bon prestataire\npour chaque besoin'
        : 'Développez votre activité\net gérez vos missions';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Stack(
        children: [
          // ── Cercles décoratifs arrière-plan ───────────────────────────
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.2,
            child: _DecorCircle(size: size.width * 0.75, opacity: 0.07),
          ),
          Positioned(
            bottom: size.height * 0.12,
            left: -size.width * 0.3,
            child: _DecorCircle(size: size.width * 0.65, opacity: 0.05),
          ),
          Positioned(
            top: size.height * 0.38,
            right: -size.width * 0.1,
            child: _DecorCircle(size: size.width * 0.28, opacity: 0.08),
          ),

          // ── Contenu principal ────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Logo ────────────────────────────────────────────
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.eco_rounded, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Inkern',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white),
                      ),
                    ]),

                    const Spacer(flex: 1),

                    // ── Icône mode avec halo animé ──────────────────────
                    AnimatedBuilder(
                      animation: _glow,
                      builder: (_, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Halo externe
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(_glow.value * 0.12),
                            ),
                          ),
                          // Halo intermédiaire
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(_glow.value * 0.18),
                            ),
                          ),
                          child!,
                        ],
                      ),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 28, spreadRadius: 2, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Icon(modeIcon, size: 46, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Label de transition ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Activation en cours',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7), letterSpacing: 0.5),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 18),

                    // ── Titre mode ──────────────────────────────────────
                    Text(
                      modeLabel,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modeTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.55), height: 1.6),
                    ),

                    const Spacer(flex: 2),

                    // ── Barre de progression ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(children: [
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Préparation de votre espace...',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35), letterSpacing: 0.3),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(opacity),
      ),
    );
  }
}

