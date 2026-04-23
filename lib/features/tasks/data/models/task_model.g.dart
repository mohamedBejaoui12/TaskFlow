// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 2;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      projectId: fields[3] as String,
      creatorId: fields[4] as String,
      assigneeId: fields[5] as String?,
      status: fields[6] as String,
      priority: fields[7] as String,
      tags: (fields[8] as List).cast<String>(),
      comments: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
      dueDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.projectId)
      ..writeByte(4)
      ..write(obj.creatorId)
      ..writeByte(5)
      ..write(obj.assigneeId)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.comments)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
