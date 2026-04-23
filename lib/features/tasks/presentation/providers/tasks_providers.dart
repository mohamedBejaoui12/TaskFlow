import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository_impl.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../notifiers/task_filter.dart';
import '../notifiers/tasks_notifier.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo, const Uuid());
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasks.where((task) {
    final statusOk = filter.status == null || task.status == filter.status;
    final priorityOk = filter.priority == null || task.priority == filter.priority;
    final projectOk = filter.projectId == null || task.projectId == filter.projectId;
    return statusOk && priorityOk && projectOk;
  }).toList(growable: false);
});
