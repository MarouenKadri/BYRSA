import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/freelancer_public_profile.dart';
import '../../domain/repositories/freelancer_public_profile_repository.dart';
import '../../../reviews/data/repositories/supabase_review_repository.dart';

class SupabaseFreelancerPublicProfileRepository
    implements FreelancerPublicProfileRepository {
  final SupabaseClient _supabase;
  final SupabaseReviewRepository _reviewRepository;

  SupabaseFreelancerPublicProfileRepository({
    SupabaseClient? supabase,
    SupabaseReviewRepository? reviewRepository,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _reviewRepository = reviewRepository ?? SupabaseReviewRepository();

  @override
  Future<FreelancerPublicProfile?> getById(String freelancerId) async {
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', freelancerId)
          .maybeSingle();

      if (row == null) return null;

      final reviews = await _reviewRepository.getReceivedReviews(freelancerId);
      final reviewsCount = _readInt(row['reviews_count']) ?? reviews.length;
      final rating = reviews.isEmpty
          ? (_readDouble(row['rating']) ?? 0)
          : reviews
                  .fold<double>(
                    0,
                    (sum, review) => sum + review.satisfaction.toInt().toDouble(),
                  ) /
              reviews.length;
      final missionsCount = _readInt(row['completed_missions']) ??
          await _countFinishedMissions(freelancerId);
      final cancellationRate = await _computeCancellationRate(freelancerId);

      return FreelancerPublicProfile(
        id: row['id'] as String? ?? freelancerId,
        firstName: row['first_name'] as String? ?? '',
        lastName: row['last_name'] as String? ?? '',
        avatarUrl: row['avatar_url'] as String?,
        bio: row['bio'] as String?,
        address: row['address'] as String?,
        hourlyRate: _readDouble(row['hourly_rate']),
        isVerified: row['is_verified'] as bool? ?? false,
        serviceCategories: _readStringList(row['service_categories']),
        rating: rating,
        reviewsCount: reviewsCount,
        missionsCount: missionsCount,
        createdAt: _readDateTime(row['created_at']),
        responseTime: row['response_time'] as String?,
        latitude: _readDouble(row['latitude']),
        longitude: _readDouble(row['longitude']),
        zoneRadius: _readDouble(row['zone_radius']),
        cancellationRate: cancellationRate,
      );
    } catch (e, st) {
      debugPrint('getById freelancer profile error: $e\n$st');
      return null;
    }
  }

  Future<int> _countFinishedMissions(String freelancerId) async {
    try {
      final rows = await _supabase
          .from('missions')
          .select('status')
          .eq('assigned_presta_id', freelancerId)
          .inFilter('status', ['completed', 'waiting_payment', 'closed']);
      return (rows as List).length;
    } catch (e) {
      debugPrint('count finished missions error: $e');
      return 0;
    }
  }

  Future<double?> _computeCancellationRate(String freelancerId) async {
    try {
      final rows = await _supabase
          .from('missions')
          .select('status')
          .eq('assigned_presta_id', freelancerId);
      final list = rows as List;
      if (list.isEmpty) return null;

      final cancelled = list.where((row) {
        final status = (row as Map<String, dynamic>)['status'] as String?;
        return status == 'cancelled';
      }).length;

      return cancelled / list.length;
    } catch (e) {
      debugPrint('compute cancellation rate error: $e');
      return null;
    }
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => '$item').where((item) => item.isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
