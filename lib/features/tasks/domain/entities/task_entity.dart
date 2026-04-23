abstract class TaskEntity {
  String get id;
  String get title;
  String get description;
  String get projectId;
  String get creatorId;
  String? get assigneeId;
  String get status;
  String get priority;
  List<String> get tags;
  List<String> get comments;
  DateTime get createdAt;
  DateTime? get dueDate;
}
