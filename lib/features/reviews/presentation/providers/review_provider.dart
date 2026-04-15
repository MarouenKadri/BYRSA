import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_review_repository.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_given_reviews.dart';
import '../../domain/usecases/get_received_reviews.dart';

class ReviewProvider extends ChangeNotifier {
  final GetReceivedReviews _getReceivedReviews;
  final GetGivenReviews _getGivenReviews;
  final _supabase = Supabase.instance.client;

  List<Review> _receivedReviews = [];
  List<Review> _givenReviews = [];
  bool isLoading = false;
  String? error;

  /// [autoLoad] = false pour les providers isolés créés par les vues profil.
  ReviewProvider({
    GetReceivedReviews? getReceivedReviews,
    GetGivenReviews? getGivenReviews,
    bool autoLoad = true,
  })  : _getReceivedReviews = getReceivedReviews ??
            GetReceivedReviews(SupabaseReviewRepository()),
        _getGivenReviews =
            getGivenReviews ?? GetGivenReviews(SupabaseReviewRepository()) {
    if (autoLoad) {
      _supabase.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn) {
          loadReviews();
        } else if (data.event == AuthChangeEvent.signedOut) {
          _reset();
        }
      });
      if (_supabase.auth.currentUser != null) loadReviews();
    }
  }

  List<Review> get receivedReviews => List.unmodifiable(_receivedReviews);
  List<Review> get givenReviews => List.unmodifiable(_givenReviews);

  String? get _userId => _supabase.auth.currentUser?.id;

  void _reset() {
    _receivedReviews = [];
    _givenReviews = [];
    isLoading = false;
    error = null;
    notifyListeners();
  }

  /// Charge les avis reçus ET donnés de l'utilisateur connecté.
  Future<void> loadReviews() async {
    final userId = _userId;
    if (userId == null) { _reset(); return; }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _getReceivedReviews(userId),
        _getGivenReviews(userId),
      ]);
      _receivedReviews = results[0];
      _givenReviews = results[1];
    } catch (e) {
      debugPrint('ReviewProvider loadReviews error: $e');
      error = 'Impossible de charger les avis';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Charge uniquement les avis reçus d'un utilisateur public (vue profil).
  /// N'affecte pas [givenReviews].
  Future<void> loadReceivedFor(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _receivedReviews = await _getReceivedReviews(userId);
    } catch (e) {
      debugPrint('ReviewProvider loadReceivedFor error: $e');
      error = 'Impossible de charger les avis';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
