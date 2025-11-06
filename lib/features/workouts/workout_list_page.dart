// features/workouts/workout_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/workout_service.dart';
import '../../core/models/routine.dart';
import 'workout_template_page.dart';

final routinesProvider = FutureProvider.autoDispose<List<Routine>>((ref) {
  return ref.read(workoutServiceProvider).getRoutines();
});

class WorkoutListPage extends ConsumerWidget {
  const WorkoutListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Routines", style: TextStyle(color: Colors.white)),
      ),
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return const Center(
              child: Text(
                "No routines yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (_, i) {
              final r = routines[i];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...r.templates.map(
                      (t) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            Text(
                              "${t.exercises.length} ex",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await ref
                                    .read(workoutServiceProvider)
                                    .deleteTemplate(t.id);
                                ref.invalidate(routinesProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(
              child: Text("Error", style: TextStyle(color: Colors.red)),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E1E1E),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutTemplatePage()),
            ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
