class TaskFilter {
  const TaskFilter({
    this.status,
    this.priority,
    this.projectId,
  });

  final String? status;
  final String? priority;
  final String? projectId;

  TaskFilter copyWith({
    String? status,
    String? priority,
    String? projectId,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearProject = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      projectId: clearProject ? null : (projectId ?? this.projectId),
    );
  }
}
