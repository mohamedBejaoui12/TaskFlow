import 'package:hive/hive.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel implements UserEntity {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatarColor,
  });

  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String email;

  @HiveField(3)
  @override
  final String password;

  @HiveField(4)
  @override
  final String avatarColor;
}
