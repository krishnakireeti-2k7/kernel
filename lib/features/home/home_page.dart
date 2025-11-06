// features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kernel/features/workouts/workout_template_page.dart';
import '../../services/workout_service.dart';
import '../../core/models/workout_template.dart';

final routinesProvider =
    FutureProvider.autoDispose<Map<String, List<WorkoutTemplate>>>((ref) {
      return ref.read(workoutServiceProvider).getRoutinesWithTemplates();
    });

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            _sectionTitle("Quick Start"),
            const SizedBox(height: 12),
            _quickStartCard(context),
            const SizedBox(height: 32),
            Row(
              children: [
                _sectionTitle("Routines"),
                const Spacer(),
                _iconButton(
                  Icons.create_new_folder,
                  () => _showCreateRoutineDialog(context),
                ),
                const SizedBox(width: 8),
                _iconButton(Icons.add, () => context.push('/workout/template')),
              ],
            ),
            const SizedBox(height: 24),
            _myRoutinesSection(context, routinesAsync),
          ],
        ),
      ),
    );
  }

  void _showCreateRoutineDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "New Routine",
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Name",
                hintStyle: TextStyle(color: Colors.grey),
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
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    await ref.read(workoutServiceProvider).createRoutine(name);
                    ref.invalidate(routinesProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Create",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
  Widget _quickStartCard(BuildContext context) => GestureDetector(
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
  Widget _iconButton(IconData icon, VoidCallback onTap) => GestureDetector(
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

  Widget _myRoutinesSection(
    BuildContext context,
    AsyncValue<Map<String, List<WorkoutTemplate>>> routinesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  "My Routines",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child:
              _isExpanded
                  ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildRoutineList(routinesAsync, context),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRoutineList(
    AsyncValue<Map<String, List<WorkoutTemplate>>> routinesAsync,
    BuildContext context,
  ) {
    return routinesAsync.when(
      data: (grouped) {
        if (grouped.isEmpty) {
          return Center(
            child: TextButton.icon(
              onPressed: () => _showCreateRoutineDialog(context),
              icon: const Icon(Icons.create_new_folder, color: Colors.blue),
              label: const Text(
                "Create first routine",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          );
        }

        final keys = grouped.keys.toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: keys.length,
          itemBuilder: (_, i) {
            final routineName = keys[i];
            final templates = grouped[routineName]!;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: Text(
                  routineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children:
                    templates
                        .map(
                          (t) => ListTile(
                            leading: const Icon(
                              Icons.fitness_center,
                              color: Colors.grey,
                            ),
                            title: Text(
                              " ${t.name}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            subtitle: Text(
                              "${t.exercises.length} exercises",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onTap:
                                () =>
                                    context.push('/workout/session', extra: t),
                          ),
                        )
                        .toList(),
              ),
            );
          },
        );
      },
      loading:
          () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error:
          (_, __) => const Text("Failed", style: TextStyle(color: Colors.red)),
    );
  }

  void _deleteRoutine(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Delete Folder?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "All templates will move to Uncategorized.",
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

    if (confirm == true) {
      final service = ref.read(workoutServiceProvider);
      final routines = await service.getRoutines();
      final routine = routines.firstWhere((r) => r.id == id);
      final uncatId = await service.ensureUncategorized();

      for (final t in routine.templates) {
        await service.saveTemplate(t.copyWith(routineId: uncatId), uncatId);
      }

      await service.deleteRoutine(id);
      ref.invalidate(routinesProvider);
    }
  }
}
