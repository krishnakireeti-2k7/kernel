// services/workout_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/workout_template.dart';

class WorkoutService {
  final _supabase = Supabase.instance.client;
  final _box = Hive.box<WorkoutTemplate>('templates');

  Future<List<WorkoutTemplate>> getTemplates() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('workout_templates')
        .select()
        .eq('user_id', userId);

    final templates =
        (response as List)
            .map((json) => WorkoutTemplate.fromJson(json))
            .toList();

    await _box.clear();
    for (var t in templates) {
      await _box.put(t.id, t);
    }

    return templates;
  }

  Future<void> saveTemplate(WorkoutTemplate template) async {
    final userId = _supabase.auth.currentUser!.id;
    final data = template.toJson()..['user_id'] = userId;

    if (template.id.startsWith('local-')) {
      final response =
          await _supabase
              .from('workout_templates')
              .insert(data)
              .select()
              .single();
      final saved = WorkoutTemplate.fromJson(response);
      await _box.put(saved.id, saved);
    } else {
      await _supabase
          .from('workout_templates')
          .update(data)
          .eq('id', template.id);
      await _box.put(template.id, template);
    }
  }

  Future<void> deleteTemplate(String id) async {
    await _supabase.from('workout_templates').delete().eq('id', id);
    await _box.delete(id);
  }
}
