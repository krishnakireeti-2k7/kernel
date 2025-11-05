// services/workout_service.dart (FULL FILE)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/models/workout_template.dart';

class WorkoutService {
  final _supabase = Supabase.instance.client;
  final _box = Hive.box<WorkoutTemplate>('templates');
  final _uuid = const Uuid();

  Future<List<WorkoutTemplate>> getTemplates() async {
    final userId = _supabase.auth.currentUser!.id;
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
                'id': json['id'].toString(), // Ensure string
              }),
            )
            .toList();

    // Sync to Hive
    await _box.clear();
    for (var t in templates) {
      await _box.put(t.id, t);
    }

    return templates;
  }

  Future<void> saveTemplate(WorkoutTemplate template) async {
    final userId = _supabase.auth.currentUser!.id;
    final isNew = template.id.startsWith('local-');

    final data = {
      'user_id': userId,
      'name': template.name,
      'exercises': template.exercises.map((e) => e.toJson()).toList(),
    };

    String savedId;
    if (isNew) {
      // Insert — let Supabase generate UUID
      final response =
          await _supabase
              .from('workout_templates')
              .insert(data)
              .select()
              .single();
      savedId = response['id'].toString();
    } else {
      // Update
      savedId = template.id;
      await _supabase
          .from('workout_templates')
          .update(data)
          .eq('id', savedId)
          .eq('user_id', userId);
    }

    // Update with real ID + sync Hive
    final savedTemplate = WorkoutTemplate(
      id: savedId,
      name: template.name,
      exercises: template.exercises,
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
