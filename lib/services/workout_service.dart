// services/workout_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/models/workout_template.dart';

class WorkoutService {
  final _supabase = Supabase.instance.client;
  final _box = Hive.box<WorkoutTemplate>('templates');
  final _uuid = const Uuid();

  // GET ALL TEMPLATES + GROUP BY ROUTINE NAME
  Future<Map<String, List<WorkoutTemplate>>> getRoutinesWithTemplates() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final response = await _supabase
          .from('workout_templates')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final templates =
          (response as List)
              .map(
                (json) => WorkoutTemplate.fromJson({
                  ...json,
                  'id': json['id'].toString(),
                }),
              )
              .toList();

      // Group by routineName
      final Map<String, List<WorkoutTemplate>> grouped = {};
      for (var t in templates) {
        final key = t.routineName ?? 'Ungrouped';
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(t);
      }

      // Sync to Hive
      await _box.clear();
      for (var t in templates) {
        await _box.put(t.id, t);
      }

      return grouped;
    } catch (e) {
      print("getRoutinesWithTemplates error: $e");
      return {};
    }
  }

  // SAVE TEMPLATE WITH ROUTINE NAME
  Future<void> saveTemplate(
    WorkoutTemplate template,
    String? routineName,
  ) async {
    final userId = _supabase.auth.currentUser!.id;
    final isNew = template.id.startsWith('local-');

    final data = {
      'user_id': userId,
      'name': template.name,
      'exercises': template.exercises.map((e) => e.toJson()).toList(),
      'routine_name': routineName,
    };

    String savedId;
    if (isNew) {
      final response =
          await _supabase
              .from('workout_templates')
              .insert(data)
              .select()
              .single();
      savedId = response['id'].toString();
    } else {
      savedId = template.id;
      await _supabase
          .from('workout_templates')
          .update(data)
          .eq('id', savedId)
          .eq('user_id', userId);
    }

    final savedTemplate = WorkoutTemplate(
      id: savedId,
      name: template.name,
      exercises: template.exercises,
      routineName: routineName,
    );
    await _box.put(savedId, savedTemplate);
  }

  Future<void> deleteTemplate(String id) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('workout_templates')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
    await _box.delete(id);
  }
}
