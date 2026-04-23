import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/notification_service.dart';
import '../../data/models/task_model.dart';
import '../../domain/repositories/tasks_repository.dart';

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier(this._repository, this._uuid) : super(const []) {
    load();
  }

  final TasksRepository _repository;
  final Uuid _uuid;

  void load() {
    state = _repository.getAll();
  }

  Future<void> create({
    required String title,
    required String description,
    required String projectId,
    required String creatorId,
    required String? assigneeId,
    required String status,
    required String priority,
    required List<String> tags,
    required List<String> comments,
    required DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      projectId: projectId,
      creatorId: creatorId,
      assigneeId: assigneeId,
      status: status,
      priority: priority,
      tags: tags,
      comments: comments,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _repository.create(task);
    if (dueDate != null) {
      await NotificationService.instance.notifyDueSoon(title, dueDate);
    }
    load();
  }

  Future<void> update(TaskModel task) async {
    _repository.update(task);
    if (task.status == 'done') {
      await NotificationService.instance.notifyTaskCompleted(task.title);
    }
    load();
  }

  void delete(String id) {
    _repository.delete(id);
    load();
  }

  Future<void> cycleStatus(TaskModel task) async {
    const order = ['todo', 'inProgress', 'done'];
    final index = order.indexOf(task.status);
    final nextStatus = order[(index + 1) % order.length];
    await update(task.copyWith(status: nextStatus));
  }

  Future<void> markDone(TaskModel task) async {
    await update(task.copyWith(status: 'done'));
  }
}
