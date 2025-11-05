// features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kernel/features/workouts/workout_template_page.dart';
import '../../core/models/workout_template.dart';

// NEW PROVIDER: GROUPED ROUTINES
final routinesProvider = FutureProvider<Map<String, List<WorkoutTemplate>>>((
  ref,
) {
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

            // MY ROUTINES — SMOOTH + GROUPED
            _myRoutinesSection(context, routinesAsync),
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

  // MY ROUTINES — SMOOTH VERTICAL COLLAPSE
  Widget _myRoutinesSection(
    BuildContext context,
    AsyncValue<Map<String, List<WorkoutTemplate>>> routinesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
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

        // CONTENT — SMOOTH VERTICAL
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? null : 0,
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

  // BUILD GROUPED LIST
  Widget _buildRoutineList(
    AsyncValue<Map<String, List<WorkoutTemplate>>> routinesAsync,
    BuildContext context,
  ) {
    return routinesAsync.when(
      data: (grouped) {
        if (grouped.isEmpty) {
          return Center(
            child: TextButton.icon(
              onPressed: () => context.push('/workouts'),
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text(
                "Create your first routine",
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
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(left: 8),
                title: Text(
                  routineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children:
                    templates
                        .map(
                          (t) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "  ${t.name}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              "${t.exercises.length} ex",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
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
          (_, __) =>
              const Text("Failed to load", style: TextStyle(color: Colors.red)),
    );
  }
}
