import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserProfile? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  List<Map<String, dynamic>> freelancers = [];
  bool isLoadingFreelancers = false;

  String? get currentUserId => _supabase.auth.currentUser?.id;
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  ProfileProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        loadProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        clear();
      }
    });
    if (_supabase.auth.currentUser != null) loadProfile();
  }

  Future<void> loadProfile() async {
    final userId = currentUserId;
    if (userId == null) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      final metadata = _supabase.auth.currentUser?.userMetadata ?? {};
      final mergedRow = <String, dynamic>{
        ...row,
        'email': currentUserEmail,
        'birth_date': (row['birth_date'] as String?)?.isNotEmpty == true
            ? row['birth_date']
            : metadata['birth_date'],
        'gender': (row['gender'] as String?)?.isNotEmpty == true
            ? row['gender']
            : metadata['gender'],
      };

      profile = UserProfile.fromJson(mergedRow);

      final needsBirthDateBackfill =
          (row['birth_date'] as String?)?.isNotEmpty != true &&
          mergedRow['birth_date'] != null;
      final needsGenderBackfill =
          (row['gender'] as String?)?.isNotEmpty != true &&
          mergedRow['gender'] != null;

      if (needsBirthDateBackfill || needsGenderBackfill) {
        final patch = <String, dynamic>{};
        if (needsBirthDateBackfill) {
          patch['birth_date'] = mergedRow['birth_date'];
        }
        if (needsGenderBackfill) {
          patch['gender'] = mergedRow['gender'];
        }
        unawaited(
          _supabase.from('profiles').update(patch).eq('id', userId),
        );
      }
    } catch (e) {
      debugPrint('loadProfile error: $e');
      error = 'Impossible de charger le profil';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProfile(UserProfile updated) async {
    final userId = currentUserId;
    if (userId == null) return 'Non connecté';
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await _supabase
          .from('profiles')
          .update(updated.toUpdateJson())
          .eq('id', userId);
      profile = updated;
      return null;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      error = 'Erreur lors de la sauvegarde';
      return error;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> loadFreelancers({String? search, String? category}) async {
    isLoadingFreelancers = true;
    notifyListeners();
    try {
      var query = _supabase
          .from('profiles')
          .select('id, first_name, last_name, avatar_url, bio, address, hourly_rate, is_verified, user_type')
          .eq('user_type', 'freelancer');

      final rows = await query.order('created_at', ascending: false);
      var results = (rows as List).cast<Map<String, dynamic>>();

      // Filtrage local (search par nom)
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        results = results.where((f) {
          final name = '${f['first_name'] ?? ''} ${f['last_name'] ?? ''}'.toLowerCase();
          return name.contains(q);
        }).toList();
      }

      freelancers = results;
    } catch (e) {
      debugPrint('loadFreelancers error: $e');
      freelancers = [];
    } finally {
      isLoadingFreelancers = false;
      notifyListeners();
    }
  }

  Future<UserProfile?> fetchProfileById(String userId) async {
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(row);
    } catch (e) {
      debugPrint('fetchProfileById error: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final userId = currentUserId;
    if (userId == null) return 'Non connecté';
    isSaving = true;
    notifyListeners();
    try {
      final bytes = await imageFile.readAsBytes();
      final path = '$userId/avatar.jpg';
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      final url = _supabase.storage.from('avatars').getPublicUrl(path);
      // Éviter que Flutter serve l'ancienne image depuis son cache mémoire
      if (profile?.avatarUrl != null) {
        NetworkImage(profile!.avatarUrl!).evict();
      }
      // Cache-buster stocké en DB — loadProfile() récupère aussi la bonne version
      final cacheBustedUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      await _supabase.from('profiles').update({'avatar_url': cacheBustedUrl}).eq('id', userId);
      profile = profile?.copyWith(avatarUrl: cacheBustedUrl);
      return null;
    } catch (e) {
      debugPrint('uploadAvatar error: $e');
      return 'Erreur lors du téléchargement';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clear() {
    profile = null;
    error = null;
    notifyListeners();
  }
}
