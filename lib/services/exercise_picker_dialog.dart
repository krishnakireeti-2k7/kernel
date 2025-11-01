// features/exercises/exercise_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/exercise_catalog_service.dart';

final exerciseCatalogProvider = Provider((ref) => ExerciseCatalogService());

class ExercisePickerDialog extends ConsumerStatefulWidget {
  final Function(String id, String name) onSelected;
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
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final results = await ref.read(exerciseCatalogProvider).search(query);
    setState(() {
      _results = results;
      _loading = false;
    });
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
                          widget.onSelected(ex['id'], ex['name']);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
