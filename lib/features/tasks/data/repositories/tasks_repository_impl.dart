import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  Box<TaskModel> get _box => Hive.box<TaskModel>(HiveBoxes.tasks);

  @override
  List<TaskModel> getAll() {
    final tasks = _box.values.toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  TaskModel create(TaskModel task) {
    _box.put(task.id, task);
    return task;
  }

  @override
  void delete(String id) {
    _box.delete(id);
  }

  @override
  TaskModel update(TaskModel task) {
    _box.put(task.id, task);
    return task;
  }
}
