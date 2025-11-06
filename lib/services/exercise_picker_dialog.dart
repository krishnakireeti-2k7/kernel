// features/exercises/exercise_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/exercise_catalog_service.dart';

final exerciseCatalogProvider = Provider((ref) => ExerciseCatalogService());

class ExercisePick {
  final String id;
  final String name;
  ExercisePick({required this.id, required this.name});
}

class ExercisePickerDialog extends ConsumerStatefulWidget {
  final Function(ExercisePick) onSelected;
  const ExercisePickerDialog({required this.onSelected, super.key});

  @override
  ConsumerState<ExercisePickerDialog> createState() =>
      _ExercisePickerDialogState();
}

class _ExercisePickerDialogState extends ConsumerState<ExercisePickerDialog> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_search);
  }

  void _search() async {
    final query = _controller.text;
    if (query.length < 2) {
      if (mounted) setState(() => _results = []);
      return;
    }
    if (mounted) setState(() => _loading = true);
    final results = await ref.read(exerciseCatalogProvider).search(query);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Add Exercise", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search exercises...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final ex = _results[i];
                      return ListTile(
                        title: Text(
                          ex['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${ex['category'] ?? ''} • ${ex['muscles']?.join(', ') ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          widget.onSelected(
                            ExercisePick(id: ex['id'], name: ex['name']),
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_search);
    _controller.dispose();
    super.dispose();
  }
}

// CRITICAL: RETURNS ExercisePick?
Future<ExercisePick?> showExercisePicker(BuildContext context) async {
  return showDialog<ExercisePick>(
    context: context,
    builder:
        (_) => ExercisePickerDialog(
          onSelected: (pick) => Navigator.pop(context, pick),
        ),
  );
}
