// features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kernel/features/workouts/workout_template_page.dart';
import '../../services/workout_service.dart';
import '../../core/models/workout_template.dart';

final templatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) {
  return ref.read(workoutServiceProvider).getTemplates();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Kernel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QUICK START
            _sectionTitle("Quick Start"),
            const SizedBox(height: 12),
            _quickStartCard(context),

            const SizedBox(height: 32),

            // ROUTINES
            Row(
              children: [
                _sectionTitle("Routines"),
                const Spacer(),
                _iconButton(Icons.add, () => context.push('/workout/template')),
              ],
            ),
            const SizedBox(height: 24),

            // MY ROUTINES — NOW SHOWS TEMPLATES
            _myRoutinesSection(context, templatesAsync),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _quickStartCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/workout/session'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white70, size: 28),
            SizedBox(width: 12),
            Text(
              "Start Empty",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _myRoutinesSection(
    BuildContext context,
    AsyncValue<List<WorkoutTemplate>> templatesAsync,
  ) {
    return ExpansionTile(
      backgroundColor: const Color(0xFF1E1E1E),
      collapsedBackgroundColor: const Color(0xFF1E1E1E),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text(
        "My Routines",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      children: [
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => context.push('/workouts'),
                    icon: const Icon(Icons.add, color: Colors.blue),
                    label: const Text(
                      "Create your first routine",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children:
                  templates.map((t) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          t.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${t.exercises.length} exercises",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push('/workout/session', extra: t);
                        },
                      ),
                    );
                  }).toList(),
            );
          },
          loading:
              () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          error:
              (_, __) => const Text(
                "Failed to load",
                style: TextStyle(color: Colors.red),
              ),
        ),
      ],
    );
  }
}
