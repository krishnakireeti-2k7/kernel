// features/workouts/workout_template_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kernel/features/home/home_page.dart';
import 'package:kernel/services/exercise_picker_dialog.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/workout_template.dart';
import '../../services/workout_service.dart';

final workoutServiceProvider = Provider((ref) => WorkoutService());

class WorkoutTemplatePage extends ConsumerStatefulWidget {
  final WorkoutTemplate? template;
  final String? initialRoutineId;
  const WorkoutTemplatePage({this.template, this.initialRoutineId, super.key});

  @override
  ConsumerState<WorkoutTemplatePage> createState() =>
      _WorkoutTemplatePageState();
}

class _WorkoutTemplatePageState extends ConsumerState<WorkoutTemplatePage> {
  late TextEditingController _nameController;
  late List<ExerciseTemplate> _exercises;
  late String _id;
  String? _routineId;

  @override
  void initState() {
    super.initState();
    _id = widget.template?.id ?? 'local-${const Uuid().v4()}';
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _exercises = List.from(widget.template?.exercises ?? []);
    _routineId = widget.template?.routineId ?? widget.initialRoutineId;
    // DO NOT USE GoRouterState.of(context) HERE
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // NOW SAFE: Context is ready
    final extra = GoRouterState.of(context).extra;
    if (extra is String && _routineId == null) {
      _routineId = extra;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.template == null ? "New Template" : "Edit Template",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.template != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTemplate,
            ),
          TextButton(
            onPressed: _save,
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Name",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            if (_routineId != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "In: ${_routineId == 'uncategorized' ? 'Uncategorized' : 'Custom Folder'}",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            if (_routineId == null)
              TextButton.icon(
                onPressed: _pickRoutine,
                icon: const Icon(Icons.folder_open, color: Colors.blue),
                label: const Text(
                  "Pick Folder",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _exercises.isEmpty
                      ? const Center(
                        child: Text(
                          "No exercises",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (_, i) {
                          final ex = _exercises[i];
                          return ListTile(
                            title: Text(
                              "Exercise ${i + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${ex.sets}x${ex.reps} @ ${ex.weight}kg",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => setState(() => _exercises.removeAt(i)),
                            ),
                          );
                        },
                      ),
            ),
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // In _addExercise() — ADD mounted CHECK
  Future<void> _addExercise() async {
    final selected = await showExercisePicker(context);
    if (selected != null && mounted) {
      setState(() {
        _exercises.add(
          ExerciseTemplate(
            exerciseId: selected.id,
            sets: 3,
            reps: 10,
            weight: 0,
          ),
        );
      });
    }
  }

  Future<void> _pickRoutine() async {
    final service = ref.read(workoutServiceProvider);
    final routines = await service.getRoutines();
    if (!mounted) return;

    final picked = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Pick Folder",
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: routines.length,
                itemBuilder: (_, i) {
                  final r = routines[i];
                  return ListTile(
                    leading: const Icon(Icons.folder, color: Colors.blue),
                    title: Text(
                      r.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, r.id),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
    );

    if (picked != null) setState(() => _routineId = picked);
  }

  // In _save() — ADD SUPABASE SYNC
 void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    _routineId ??= await ref.read(workoutServiceProvider).ensureUncategorized();

    final template = WorkoutTemplate(
      id: _id,
      name: _nameController.text.trim(),
      exercises: _exercises,
      routineId: _routineId!,
    );

    // SAVE LOCALLY
    await ref.read(workoutServiceProvider).saveTemplate(template, _routineId!);

    // FULL SYNC TO SUPABASE
    await ref.read(workoutServiceProvider).syncToSupabase();

    // REFRESH HOME
    ref.invalidate(routinesProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Template saved to Supabase!")),
      );
      context.pop();
    }
  }

  void _deleteTemplate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Delete Template?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "This cannot be undone.",
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(workoutServiceProvider).deleteTemplate(_id);
      ref.invalidate(routinesProvider);
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
