// features/workouts/workout_template_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kernel/services/exercise_picker_dialog.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/workout_template.dart';
import '../../services/workout_service.dart';

final workoutServiceProvider = Provider((ref) => WorkoutService());

class WorkoutTemplatePage extends ConsumerStatefulWidget {
  final WorkoutTemplate? template;
  const WorkoutTemplatePage({this.template, super.key});

  @override
  ConsumerState<WorkoutTemplatePage> createState() =>
      _WorkoutTemplatePageState();
}

class _WorkoutTemplatePageState extends ConsumerState<WorkoutTemplatePage> {
  late TextEditingController _nameController;
  late List<ExerciseTemplate> _exercises;
  late String _id;

  @override
  void initState() {
    super.initState();
    _id = widget.template?.id ?? 'local-${const Uuid().v4()}';
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _exercises = List.from(widget.template?.exercises ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.template == null ? "New Routine" : "Edit Routine"),
        actions: [
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
                hintText: "Routine name",
                hintStyle: TextStyle(color: Colors.grey),
                border: UnderlineInputBorder(),
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
                        itemBuilder: (ctx, i) {
                          final ex = _exercises[i];
                          return ListTile(
                            title: Text(
                              "Exercise ${i + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${ex.sets}×${ex.reps} @ ${ex.weight}kg",
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
            ),
          ],
        ),
      ),
    );
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder:
          (_) => ExercisePickerDialog(
            onSelected: (id, name) {
              setState(() {
                _exercises.add(
                  ExerciseTemplate(
                    exerciseId: id,
                    sets: 3,
                    reps: 10,
                    weight: 0,
                  ),
                );
              });
            },
          ),
    );
  }

  void _save() async {
    final template = WorkoutTemplate(
      id: _id,
      name: _nameController.text,
      exercises: _exercises,
    );
    await ref.read(workoutServiceProvider).saveTemplate(template);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
