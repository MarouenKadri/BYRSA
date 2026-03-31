import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/navigation/root_nav.dart';
import 'app/navigation/guest_nav.dart';
import 'app/auth_provider.dart';
import 'app/config.dart';
import 'app/theme/design_tokens.dart';
import 'features/messaging/messaging_provider.dart';
import 'features/mission/mission_provider.dart';
import 'features/notifications/notifications.dart';
import 'features/post/post_provider.dart';
import 'features/profile/profile_provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          // ── Typographie globale ──────────────────────────────────────
          textTheme: base.copyWith(
            displayLarge:  base.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.0, color: AppColors.textPrimary),
            displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textPrimary),
            headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textPrimary),
            headlineMedium:base.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            titleLarge:    base.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            titleMedium:   base.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            bodyLarge:     base.bodyLarge?.copyWith(color: AppColors.textPrimary, height: 1.6),
            bodyMedium:    base.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
            labelLarge:    base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
          ),
          // ── AppBar ───────────────────────────────────────────────────
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          // ── Boutons ──────────────────────────────────────────────────
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          // ── Input ────────────────────────────────────────────────────
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            hintStyle: const TextStyle(color: AppColors.textHint),
          ),
          // ── Divider ──────────────────────────────────────────────────
          dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
          // ── Chip ─────────────────────────────────────────────────────
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.surfaceAlt,
            selectedColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        home: const RootNav(),
      ),
    );
  }
}
