import 'package:supabase_flutter/supabase_flutter.dart';

import 'freelancer_catalog_repository.dart';

class SupabaseFreelancerCatalogRepository implements FreelancerCatalogRepository {
  final SupabaseClient _supabase;

  SupabaseFreelancerCatalogRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> fetchFreelancers({
    required bool includeServiceCategories,
  }) async {
    final selectColumns = includeServiceCategories
        ? 'id, first_name, last_name, avatar_url, bio, address, hourly_rate, is_verified, user_type, service_categories'
        : 'id, first_name, last_name, avatar_url, bio, address, hourly_rate, is_verified, user_type';

    final rows = await _supabase
        .from('profiles')
        .select(selectColumns)
        .eq('user_type', 'freelancer')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }
}

