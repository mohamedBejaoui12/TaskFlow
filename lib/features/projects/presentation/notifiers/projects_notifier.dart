import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/project_model.dart';
import '../../domain/repositories/projects_repository.dart';

class ProjectsNotifier extends StateNotifier<List<ProjectModel>> {
  ProjectsNotifier(this._repository, this._uuid) : super(const []) {
    load();
  }

  final ProjectsRepository _repository;
  final Uuid _uuid;

  void load() {
    state = _repository.getAll();
  }

  void create({
    required String name,
    required String description,
    required String ownerId,
    required List<String> memberIds,
    required String colorHex,
    required String icon,
  }) {
    _repository.create(
      ProjectModel(
        id: _uuid.v4(),
        name: name,
        description: description,
        ownerId: ownerId,
        memberIds: memberIds,
        colorHex: colorHex,
        icon: icon,
        createdAt: DateTime.now(),
      ),
    );
    load();
  }

  void update(ProjectModel project) {
    _repository.update(project);
    load();
  }

  void delete(String id) {
    _repository.delete(id);
    load();
  }
}
