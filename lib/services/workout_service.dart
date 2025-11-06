// services/workout_service.dart
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/models/workout_template.dart';
import '../core/models/routine.dart';

class WorkoutService {
  late final Box<WorkoutTemplate> _templateBox;
  late final Box<Routine> _routineBox;

  // FIXED UUID FOR UNCATEGORIZED
  static const String _uncategorizedId = '00000000-0000-0000-0000-000000000001';

  WorkoutService._() {
    _templateBox = Hive.box<WorkoutTemplate>('templates');
    _routineBox = Hive.box<Routine>('routines');
  }

  static final WorkoutService _instance = WorkoutService._();
  factory WorkoutService() => _instance;

  // GET GROUPED ROUTINES — USE TEMPLATES' routineId
  Future<Map<String, List<WorkoutTemplate>>> getRoutinesWithTemplates() async {
    await ensureUncategorized();

    final routines = _routineBox.values.toList();
    final Map<String, List<WorkoutTemplate>> grouped = {};

    // Initialize all routine names
    for (final r in routines) {
      grouped[r.name] = [];
    }

    // Group templates by routineId
    for (final t in _templateBox.values) {
      final routine = routines.firstWhere(
        (r) => r.id == t.routineId,
        orElse: () => routines.firstWhere((r) => r.id == _uncategorizedId),
      );
      grouped[routine.name]!.add(t);
    }

    return grouped;
  }

  // ENSURE UNCATEGORIZED — FIXED UUID
  Future<String> ensureUncategorized() async {
    final routine = Routine(
      id: _uncategorizedId,
      name: 'Uncategorized',
      templates: const [],
    );

    if (!_routineBox.containsKey(_uncategorizedId)) {
      await _routineBox.put(_uncategorizedId, routine);
    }
    await _syncSingleRoutine(routine);
    return _uncategorizedId;
  }

  // SAVE TEMPLATE — SAFE routineId
  Future<void> saveTemplate(WorkoutTemplate template, String routineId) async {
    final String safeRoutineId =
        routineId.isEmpty || routineId == 'null' || routineId == 'uncategorized'
            ? _uncategorizedId
            : routineId;

    final updatedTemplate = template.copyWith(routineId: safeRoutineId);
    await _templateBox.put(updatedTemplate.id, updatedTemplate);

    final routine = _routineBox.get(safeRoutineId);
    if (routine != null) {
      final updated =
          routine.templates
            ..removeWhere((t) => t.id == template.id)
            ..add(updatedTemplate);
      await _routineBox.put(
        safeRoutineId,
        Routine(id: routine.id, name: routine.name, templates: updated),
      );
    }

    await _syncSingleTemplate(updatedTemplate);
  }

  // DELETE TEMPLATE
  Future<void> deleteTemplate(String id) async {
    final template = _templateBox.get(id);
    if (template == null) return;

    await _templateBox.delete(id);

    final routine = _routineBox.get(template.routineId);
    if (routine != null) {
      final updated = routine.templates..removeWhere((t) => t.id == id);
      await _routineBox.put(
        template.routineId,
        Routine(id: routine.id, name: routine.name, templates: updated),
      );
    }

    await _deleteTemplateFromCloud(id);
  }

  // GET ROUTINES
  Future<List<Routine>> getRoutines() async {
    await ensureUncategorized();

    final routines = _routineBox.values.toList();

    for (final routine in routines) {
      final templates =
          _templateBox.values.where((t) => t.routineId == routine.id).toList();
      if (templates.length != routine.templates.length ||
          !templates.every(
            (t) => routine.templates.any((rt) => rt.id == t.id),
          )) {
        await _routineBox.put(
          routine.id,
          Routine(id: routine.id, name: routine.name, templates: templates),
        );
      }
    }

    return _routineBox.values.toList();
  }

  // CREATE ROUTINE
  Future<String> createRoutine(String name) async {
    if (name.trim().isEmpty)
      throw ArgumentError('Routine name cannot be empty');
    final id = const Uuid().v4();
    final routine = Routine(id: id, name: name.trim(), templates: const []);
    await _routineBox.put(id, routine);
    await _syncSingleRoutine(routine);
    return id;
  }

  // DELETE ROUTINE
  Future<void> deleteRoutine(String id) async {
    final routine = _routineBox.get(id);
    if (routine == null || routine.id == _uncategorizedId) return;

    final uncatId = await ensureUncategorized();
    for (final t in routine.templates) {
      await saveTemplate(t.copyWith(routineId: uncatId), uncatId);
    }
    await _routineBox.delete(id);
    await _deleteRoutineFromCloud(id);
  }

  // PULL FROM SUPABASE → LOCAL (NULL SAFE)
  Future<void> syncFromSupabase() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final templateRes = await supabase
          .from('workout_templates')
          .select()
          .eq('user_id', userId);
      final routineRes = await supabase
          .from('routines')
          .select()
          .eq('user_id', userId);

      await _templateBox.clear();
      await _routineBox.clear();

      // Load templates — NULL → FIXED UUID
      for (final t in templateRes as List) {
        final exercises =
            (t['exercises'] as List)
                .map(
                  (e) => ExerciseTemplate(
                    exerciseId: e['exercise_id'],
                    sets: e['sets'],
                    reps: e['reps'],
                    weight: (e['weight'] as num).toDouble(),
                  ),
                )
                .toList();

        final String routineId =
            t['routine_id'] == null || t['routine_id'] == 'uncategorized'
                ? _uncategorizedId
                : t['routine_id'];

        final template = WorkoutTemplate(
          id: t['id'],
          name: t['name'],
          exercises: exercises,
          routineId: routineId,
        );
        await _templateBox.put(template.id, template);
      }

      // Load routines — NULL SAFE
      for (final r in routineRes as List) {
        final rawIds = r['template_ids'] as List<dynamic>?;
        final templateIds = rawIds?.cast<String>() ?? <String>[];
        final templates =
            templateIds
                .map((id) => _templateBox.get(id))
                .whereType<WorkoutTemplate>()
                .toList();

        final routine = Routine(
          id: r['id'],
          name: r['name'],
          templates: templates,
        );
        await _routineBox.put(routine.id, routine);
      }
    } catch (e) {
      print('Sync from Supabase failed: $e');
    }
  }

  // FULL SYNC TO SUPABASE
  Future<void> syncToSupabase() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      for (final template in _templateBox.values) {
        await _syncSingleTemplate(template);
      }
      for (final routine in _routineBox.values) {
        await _syncSingleRoutine(routine);
      }
    } catch (e) {
      print('Full sync to Supabase failed: $e');
    }
  }

  // PRIVATE: SYNC SINGLE TEMPLATE
  Future<void> _syncSingleTemplate(WorkoutTemplate template) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('workout_templates').upsert({
      'id': template.id,
      'user_id': userId,
      'name': template.name,
      'routine_id': template.routineId,
      'exercises':
          template.exercises
              .map(
                (e) => {
                  'exercise_id': e.exerciseId,
                  'sets': e.sets,
                  'reps': e.reps,
                  'weight': e.weight,
                },
              )
              .toList(),
    }, onConflict: 'id');
  }

  // PRIVATE: SYNC SINGLE ROUTINE
  Future<void> _syncSingleRoutine(Routine routine) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('routines').upsert({
      'id': routine.id,
      'user_id': userId,
      'name': routine.name,
      'template_ids': routine.templates.map((t) => t.id).toList(),
      'parent_id': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  // DELETE FROM CLOUD
  Future<void> _deleteTemplateFromCloud(String id) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase
        .from('workout_templates')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> _deleteRoutineFromCloud(String id) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('routines').delete().eq('id', id).eq('user_id', userId);
  }
}
