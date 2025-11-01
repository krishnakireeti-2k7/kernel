// lib/features/workouts/workout_session_page.dart
import 'package:flutter/material.dart';
import 'package:kernel/core/models/workout_template.dart';

class WorkoutSessionPage extends StatelessWidget {
  const WorkoutSessionPage({super.key, WorkoutTemplate? template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Session')),
      body: const Center(child: Text('Session UI coming in Day 3')),
    );
  }
}
