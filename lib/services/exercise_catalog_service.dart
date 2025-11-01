// services/exercise_catalog_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseCatalogService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().isEmpty) return [];

    return await _supabase
        .from('exercise_catalog')
        .select()
        .or('name.ilike.%$query%, muscles.cs.{$query}')
        .order('name')
        .limit(20);
  }
}
