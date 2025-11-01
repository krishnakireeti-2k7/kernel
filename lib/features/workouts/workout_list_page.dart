// features/workouts/workout_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/workout_service.dart';
import 'workout_template_page.dart';

final templatesProvider = FutureProvider.autoDispose((ref) {
  return ref.read(workoutServiceProvider).getTemplates();
});

class WorkoutListPage extends ConsumerWidget {
  const WorkoutListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("My Routines")),
      body: templatesAsync.when(
        data:
            (templates) =>
                templates.isEmpty
                    ? const Center(
                      child: Text(
                        "No routines",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: templates.length,
                      itemBuilder: (ctx, i) {
                        final t = templates[i];
                        return ListTile(
                          title: Text(
                            t.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text("${t.exercises.length} exercises"),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => WorkoutTemplatePage(template: t),
                                ),
                              ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ref
                                  .read(workoutServiceProvider)
                                  .deleteTemplate(t.id);
                              ref.invalidate(templatesProvider);
                            },
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(
              child: Text("Error", style: TextStyle(color: Colors.red)),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutTemplatePage()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
