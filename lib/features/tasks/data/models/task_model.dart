import 'package:hive/hive.dart';

import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskModel implements TaskEntity {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.creatorId,
    required this.assigneeId,
    required this.status,
    required this.priority,
    required this.tags,
    required this.comments,
    required this.createdAt,
    required this.dueDate,
  });

  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String description;

  @HiveField(3)
  @override
  final String projectId;

  @HiveField(4)
  @override
  final String creatorId;

  @HiveField(5)
  @override
  final String? assigneeId;

  @HiveField(6)
  @override
  final String status;

  @HiveField(7)
  @override
  final String priority;

  @HiveField(8)
  @override
  final List<String> tags;

  @HiveField(9)
  @override
  final List<String> comments;

  @HiveField(10)
  @override
  final DateTime createdAt;

  @HiveField(11)
  @override
  final DateTime? dueDate;

  TaskModel copyWith({
    String? title,
    String? description,
    String? projectId,
    String? creatorId,
    String? assigneeId,
    String? status,
    String? priority,
    List<String>? tags,
    List<String>? comments,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      creatorId: creatorId ?? this.creatorId,
      assigneeId: assigneeId ?? this.assigneeId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
