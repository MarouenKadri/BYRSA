import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enum/user_role.dart';
import '../features/auth/data/models/registration_data.dart';
import '../features/auth/data/models/user_type.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserRole currentRole = UserRole.guest;
  UserRole? pendingRole;
  bool isLogged = false;
  bool isLoading = false;
  bool needsRoleSelection = false;
  String? error;
  int _switchToken = 0;

  bool get isGoogleUser {
    final identities = _supabase.auth.currentUser?.identities ?? [];
    return identities.any((i) => i.provider == 'google');
  }

  bool _isRegistering = false; // skip _loadProfile() during registration
  bool _isLoadingProfile = false; // guard against concurrent _loadProfile calls

  AuthProvider() {
    _init();
  }

  void _init() {
    // Do NOT call _loadProfile synchronously here.
    // The initialSession event fires immediately for existing sessions and covers app restart.
    // Calling it here too would cause a double-load race condition.
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        currentRole = UserRole.guest;
        isLogged = false;
        notifyListeners();
      } else if (data.event == AuthChangeEvent.signedIn &&
          data.session != null) {
        // Blocked during login() and register() which call _loadProfile directly.
        if (!_isRegistering) _loadProfile(data.session!.user.id);
      } else if (data.event == AuthChangeEvent.initialSession &&
          data.session != null) {
        // Fires on app restart when a valid session is found in local storage.
        _loadProfile(data.session!.user.id);
      } else if (data.event == AuthChangeEvent.tokenRefreshed &&
          data.session != null) {
        if (!isLogged) _loadProfile(data.session!.user.id);
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    // Prevent concurrent executions (e.g. initialSession + signedIn firing together).
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    try {
      final List data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId);

      String? userType;

      if (data.isEmpty || (data.first['user_type'] as String?) == null) {
        // Fallback: read user_type from Supabase Auth metadata (set during signUp)
        userType =
            _supabase.auth.currentUser?.userMetadata?['user_type'] as String?;
        if (userType == null) {
          needsRoleSelection = true;
          isLogged = false;
          notifyListeners();
          return;
        }
      } else {
        userType = data.first['user_type'] as String;
      }

      final baseRole = userType == 'freelancer'
          ? UserRole.provider
          : UserRole.client;

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('role_$userId');
      currentRole = saved != null
          ? (saved == 'provider' ? UserRole.provider : UserRole.client)
          : baseRole;

      needsRoleSelection = false;
      isLogged = true;
    } catch (e) {
      debugPrint('_loadProfile error: $e');
      isLogged = true;
      currentRole = UserRole.client;
    } finally {
      _isLoadingProfile = false;
    }
    notifyListeners();
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<String?> signInWithGoogle() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      if (serverClientId == null ||
          serverClientId.isEmpty ||
          serverClientId == 'your-web-client-id-here') {
        return 'GOOGLE_WEB_CLIENT_ID manquant ou invalide dans .env';
      }

      final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return null; // user cancelled
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        isLoading = false;
        notifyListeners();
        return 'Erreur Google Sign-In';
      }
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('signInWithGoogle error: $e');
      error = 'Erreur lors de la connexion Google';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> completeGoogleSetup({
    required UserType userType,
    DateTime? birthDate,
    Gender? gender,
    String? phone,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'Erreur';
      await _supabase.from('profiles').upsert({
        'id': userId,
        'user_type': userType.name,
        if (birthDate != null)
          'birth_date': birthDate.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender.name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      currentRole = userType == UserType.freelancer
          ? UserRole.provider
          : UserRole.client;
      needsRoleSelection = false;
      isLogged = true;
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('completeGoogleSetup error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<String?> login(String email, String password) async {
    isLoading = true;
    _isRegistering =
        true; // prevent the signedIn listener from calling _loadProfile
    error = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) await _loadProfile(res.user!.id);
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('login error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Login téléphone OTP ─────────────────────────────────────────────────

  Future<String?> sendPhoneLoginOtp(String phone) async {
    try {
      debugPrint('sendPhoneLoginOtp: phone=$phone');
      await _supabase.auth.signInWithOtp(phone: phone);
      return null;
    } on AuthException catch (e) {
      debugPrint('sendPhoneLoginOtp AuthException: ${e.message} (status=${e.statusCode})');
      return _friendlyError(e.message);
    } catch (e) {
      debugPrint('sendPhoneLoginOtp error: $e');
      return 'Une erreur est survenue';
    }
  }

  Future<String?> verifyPhoneLoginOtp(String phone, String token) async {
    isLoading = true;
    _isRegistering = true;
    notifyListeners();
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      if (res.user != null) await _loadProfile(res.user!.id);
      return null;
    } on AuthException catch (e) {
      return _friendlyError(e.message);
    } catch (e) {
      debugPrint('verifyPhoneLoginOtp error: $e');
      return 'Une erreur est survenue';
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Inscription ──────────────────────────────────────────────────────────

  Future<String?> register(RegistrationData data) async {
    isLoading = true;
    _isRegistering = true;
    error = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signUp(
        email: data.email!,
        password: data.password!,
        data: {
          'first_name': data.firstName,
          'last_name': data.lastName,
          'phone': data.phone,
          'birth_date': data.birthDate?.toIso8601String().split('T').first,
          'gender': data.gender?.name,
          'user_type': data.userType?.name,
        },
      );
      if (res.user != null) {
        // Insert profile row — non-blocking (fails gracefully if RLS not set up yet)
        try {
          // 1. Upload photo si fournie
          String? avatarUrl;
          if (data.photo != null) {
            try {
              final bytes = await data.photo!.readAsBytes();
              final path = '${res.user!.id}/avatar.jpg';
              await _supabase.storage
                  .from('avatars')
                  .uploadBinary(
                    path,
                    bytes,
                    fileOptions: const FileOptions(
                      contentType: 'image/jpeg',
                      upsert: true,
                    ),
                  );
              avatarUrl = _supabase.storage.from('avatars').getPublicUrl(path);
            } catch (e) {
              debugPrint('avatar upload warning (non-blocking): $e');
            }
          }

          // 2. Insérer le profil (email obligatoire — NOT NULL dans profiles)
          await _supabase.from('profiles').upsert({
            'id': res.user!.id,
            'email': data.email,
            'first_name': data.firstName,
            'last_name': data.lastName,
            'phone': data.phone,
            'user_type': data.userType?.name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          });
        } catch (e) {
          debugPrint('profiles upsert warning (non-blocking): $e');
        }
        currentRole = data.userType == UserType.freelancer
            ? UserRole.provider
            : UserRole.client;
        needsRoleSelection = false;
        isLogged = true;
      }
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('register error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Switch de rôle ───────────────────────────────────────────────────────

  Future<void> switchRole(UserRole newRole) async {
    if (!isLogged || newRole == UserRole.guest || newRole == currentRole)
      return;
    final token = ++_switchToken;
    pendingRole = newRole;
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (token != _switchToken || !isLogged) return;
    currentRole = newRole;
    pendingRole = null;
    isLoading = false;

    // Persist the chosen role so it survives app restarts
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role_$userId', newRole.name);
    }

    notifyListeners();
  }

  // ─── Reset Password OTP ───────────────────────────────────────────────────

  Future<String?> sendPasswordResetOtp(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyPasswordResetOtp(String email, String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateEmail(String newEmail) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Suppression de compte ────────────────────────────────────────────────

  /// Vérifie le mot de passe puis supprime définitivement le compte.
  /// Retourne null si succès, ou un message d'erreur.
  Future<String?> deleteAccount(String password) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Utilisateur non connecté';

    // 1. Re-authentifier — ignoré pour les comptes Google (pas de mot de passe)
    if (!isGoogleUser) {
      final email = user.email;
      if (email == null) return 'Email introuvable';
      _isRegistering = true;
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException {
        _isRegistering = false;
        return 'Mot de passe incorrect';
      } catch (_) {
        _isRegistering = false;
        return 'Mot de passe incorrect';
      }
      _isRegistering = false;
    }

    final userId = user.id;

    // 2. Supprimer les données via RPC (recommandé — gère aussi auth.users côté serveur)
    //    Si la RPC n'existe pas, fallback manuel avec le bon ordre FK.
    bool rpcOk = false;
    try {
      await _supabase.rpc('delete_my_account');
      rpcOk = true;
    } catch (rpcError) {
      debugPrint('delete_my_account RPC unavailable, falling back: $rpcError');
    }

    if (!rpcOk) {
      try {
        // 1. Candidatures du freelancer
        await _supabase.from('candidates').delete().eq('freelancer_id', userId);

        // 2. IDs de mes missions (client)
        final myMissionsRaw = await _supabase
            .from('missions')
            .select('id')
            .eq('client_id', userId);
        final myMissionIds = (myMissionsRaw as List)
            .map((r) => r['id'] as String)
            .toList();

        if (myMissionIds.isNotEmpty) {
          // 3. Candidatures sur mes missions
          await _supabase
              .from('candidates')
              .delete()
              .inFilter('mission_id', myMissionIds);
          // 4. Avis liés à mes missions
          await _supabase
              .from('reviews')
              .delete()
              .inFilter('mission_id', myMissionIds);
          // 5. Transactions liées à mes missions
          await _supabase
              .from('transactions')
              .delete()
              .inFilter('mission_id', myMissionIds);
        }

        // 6. Avis où je suis reviewer ou reviewee
        await _supabase.from('reviews').delete().eq('reviewer_id', userId);
        await _supabase.from('reviews').delete().eq('reviewee_id', userId);

        // 7. Transactions de l'utilisateur
        await _supabase.from('transactions').delete().eq('user_id', userId);

        // 8. Messages & conversations
        final convRaw = await _supabase
            .from('conversations')
            .select('id')
            .or('client_id.eq.$userId,freelancer_id.eq.$userId');
        final myConvIds = (convRaw as List)
            .map((r) => r['id'] as String)
            .toList();
        if (myConvIds.isNotEmpty) {
          await _supabase
              .from('messages')
              .delete()
              .inFilter('conversation_id', myConvIds);
        }
        await _supabase.from('messages').delete().eq('sender_id', userId);
        await _supabase.from('conversations').delete().eq('client_id', userId);
        await _supabase
            .from('conversations')
            .delete()
            .eq('freelancer_id', userId);

        // 9. Notifications
        await _supabase.from('notifications').delete().eq('user_id', userId);

        // 10. Compétences (freelancer)
        await _supabase.from('skills').delete().eq('freelancer_id', userId);

        // 11. Votes sur mes publications + mes votes
        final myPostsRaw = await _supabase
            .from('posts')
            .select('id')
            .eq('author_id', userId);
        final myPostIds = (myPostsRaw as List)
            .map((r) => r['id'] as String)
            .toList();
        if (myPostIds.isNotEmpty) {
          await _supabase
              .from('post_votes')
              .delete()
              .inFilter('post_id', myPostIds);
        }
        await _supabase.from('post_votes').delete().eq('user_id', userId);

        // 12. Publications (colonne author_id, pas user_id)
        await _supabase.from('posts').delete().eq('author_id', userId);

        // 13. Missions
        await _supabase.from('missions').delete().eq('client_id', userId);

        // 14. Profil
        await _supabase.from('profiles').delete().eq('id', userId);

        debugPrint('[DELETE] fallback complet');
      } catch (e, st) {
        debugPrint('[DELETE] FAILED: $e\n$st');
        return 'Erreur lors de la suppression des données';
      }
    }

    // 3. Déconnexion + nettoyage local
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role_$userId');
    _switchToken++;
    pendingRole = null;
    currentRole = UserRole.guest;
    isLogged = false;
    isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Clear the persisted role for this user
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('role_$userId');
    }
    _switchToken++;
    pendingRole = null;
    await _supabase.auth.signOut();
    currentRole = UserRole.guest;
    isLogged = false;
    isLoading = false;
    notifyListeners();
  }

  // ─── Erreurs lisibles ─────────────────────────────────────────────────────

  String _friendlyError(String message) {
    if (message.contains('Invalid login credentials'))
      return 'Email ou mot de passe incorrect';
    if (message.contains('Email not confirmed'))
      return 'Confirmez votre email avant de vous connecter';
    if (message.contains('User already registered'))
      return 'Cet email est déjà utilisé';
    if (message.contains('Password should be'))
      return 'Mot de passe trop court (minimum 8 caractères)';
    return 'Une erreur est survenue';
  }
}
