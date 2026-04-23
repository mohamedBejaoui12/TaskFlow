import '../../data/models/project_model.dart';

abstract class ProjectsRepository {
  List<ProjectModel> getAll();
  ProjectModel create(ProjectModel project);
  ProjectModel update(ProjectModel project);
  void delete(String id);
}
