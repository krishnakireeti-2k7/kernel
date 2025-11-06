// core/models/workout_template.dart
import 'package:hive/hive.dart';

part 'workout_template.g.dart';

@HiveType(typeId: 10) // CHANGED FROM 0
class WorkoutTemplate {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<ExerciseTemplate> exercises;

  @HiveField(3)
  final String routineId;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exercises,
    required this.routineId,
  });

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    List<ExerciseTemplate>? exercises,
    String? routineId,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      routineId: routineId ?? this.routineId,
    );
  }
}

@HiveType(typeId: 11) // CHANGED FROM 1
class ExerciseTemplate {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final int sets;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final double weight;

  ExerciseTemplate({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}
