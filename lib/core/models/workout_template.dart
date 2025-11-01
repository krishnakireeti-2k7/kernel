// core/models/workout_template.dart
class ExerciseTemplate {
  final String exerciseId;
  final int sets;
  final int reps;
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
        weight: json['weight']?.toDouble() ?? 0.0,
      );
}

class WorkoutTemplate {
  final String id;
  final String name;
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
