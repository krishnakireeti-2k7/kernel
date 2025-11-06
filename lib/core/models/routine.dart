// core/models/routine.dart
import 'package:hive/hive.dart';
import 'workout_template.dart';

part 'routine.g.dart';

@HiveType(typeId: 2)
class Routine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<WorkoutTemplate> templates;

  Routine({required this.id, required this.name, this.templates = const []});
}
