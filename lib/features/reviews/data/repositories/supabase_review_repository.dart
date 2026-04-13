import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Review>> getReceivedReviews(String userId) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select()
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => Review.fromJson(r as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('getReceivedReviews error: $e');
      return [];
    }
  }

  @override
  Future<List<Review>> getGivenReviews(String userId) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select()
          .eq('reviewer_id', userId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => Review.fromJson(r as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('getGivenReviews error: $e');
      return [];
    }
  }

  @override
  Future<String?> addReview({
    required String revieweeId,
    required String reviewerId,
    required String reviewerName,
    required String? reviewerAvatar,
    required int rating,
    required String comment,
    required String missionId,
    required String missionTitle,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'reviewee_id': revieweeId,
        'reviewer_id': reviewerId,
        'reviewer_name': reviewerName,
        'reviewer_avatar': reviewerAvatar ?? '',
        'rating': rating,
        'comment': comment,
        'mission_id': missionId,
        'mission_title': missionTitle,
      });
      return null;
    } catch (e) {
      debugPrint('addReview error: $e');
      return 'Erreur lors de l\'envoi de l\'avis';
    }
  }

  @override
  Future<double> getAverageRating(String userId) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select('rating')
          .eq('reviewee_id', userId);
      final list = rows as List;
      if (list.isEmpty) return 0.0;
      final sum = list.fold<int>(0, (acc, r) => acc + ((r as Map<String, dynamic>)['rating'] as num).toInt());
      return sum / list.length;
    } catch (e) {
      debugPrint('getAverageRating error: $e');
      return 0.0;
    }
  }
}
