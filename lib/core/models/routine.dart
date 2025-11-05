// lib/core/models/routine.dart
import 'package:hive/hive.dart';
import 'workout_template.dart';

part 'routine.g.dart';

@HiveType(typeId: 2)
class Routine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<WorkoutTemplate> templates; // FIXED

  Routine({required this.id, required this.name, this.templates = const []});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'templates': templates.map((t) => t.toJson()).toList(),
  };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'],
    name: json['name'],
    templates:
        (json['templates'] as List)
            .map((t) => WorkoutTemplate.fromJson(t))
            .toList(),
  );
}
