import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/repositories/projects_repository.dart';
import '../models/project_model.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  Box<ProjectModel> get _box => Hive.box<ProjectModel>(HiveBoxes.projects);

  @override
  List<ProjectModel> getAll() {
    final projects = _box.values.toList();
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  @override
  ProjectModel create(ProjectModel project) {
    _box.put(project.id, project);
    return project;
  }

  @override
  void delete(String id) {
    _box.delete(id);
  }

  @override
  ProjectModel update(ProjectModel project) {
    _box.put(project.id, project);
    return project;
  }
}
