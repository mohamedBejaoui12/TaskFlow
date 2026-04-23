import 'package:hive/hive.dart';

import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

@HiveType(typeId: 1)
class ProjectModel implements ProjectEntity {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.colorHex,
    required this.icon,
    required this.createdAt,
  });

  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String description;

  @HiveField(3)
  @override
  final String ownerId;

  @HiveField(4)
  @override
  final List<String> memberIds;

  @HiveField(5)
  @override
  final String colorHex;

  @HiveField(6)
  @override
  final String icon;

  @HiveField(7)
  @override
  final DateTime createdAt;

  ProjectModel copyWith({
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    String? colorHex,
    String? icon,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}
