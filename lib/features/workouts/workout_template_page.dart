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
        title: Text(
          widget.template == null ? "New Routine" : "Edit Routine",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            // NAME
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Routine name",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // EXERCISES
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
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Exercise ${i + 1}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Text(
                                  "${ex.sets}×${ex.reps} @ ${ex.weight}kg",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => _exercises.removeAt(i),
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            // ADD BUTTON
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Exercise",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a routine name")));
      return;
    }

    final localTemplate = WorkoutTemplate(
      id: _id,
      name: _nameController.text.trim(),
      exercises: _exercises,
    );

    try {
      await ref.read(workoutServiceProvider).saveTemplate(localTemplate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Save failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
