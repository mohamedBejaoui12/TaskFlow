import '../../data/models/task_model.dart';

abstract class TasksRepository {
  List<TaskModel> getAll();
  TaskModel create(TaskModel task);
  TaskModel update(TaskModel task);
  void delete(String id);
}
