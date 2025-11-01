// lib/core/models/workout_template.dart
import 'package:hive/hive.dart';

part 'workout_template.g.dart'; // THIS LINE IS CRITICAL

@HiveType(typeId: 0)
class WorkoutTemplate extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<ExerciseTemplate> exercises;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplate(
        id: json['id'],
        name: json['name'],
        exercises:
            (json['exercises'] as List)
                .map((e) => ExerciseTemplate.fromJson(e))
                .toList(),
      );
}

@HiveType(typeId: 1)
class ExerciseTemplate extends HiveObject {
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

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'sets': sets,
    'reps': reps,
    'weight': weight,
  };

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) =>
      ExerciseTemplate(
        exerciseId: json['exercise_id'],
        sets: json['sets'],
        reps: json['reps'],
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      );
}
