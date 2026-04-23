abstract class ProjectEntity {
  String get id;
  String get name;
  String get description;
  String get ownerId;
  List<String> get memberIds;
  String get colorHex;
  String get icon;
  DateTime get createdAt;
}
