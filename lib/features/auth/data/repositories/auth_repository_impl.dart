import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._uuid);

  final Uuid _uuid;

  Box<UserModel> get _box => Hive.box<UserModel>(HiveBoxes.users);

  @override
  List<UserModel> getAllUsers() => _box.values.toList(growable: false);

  @override
  UserModel? findUserById(String id) {
    try {
      return _box.values.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  UserModel? login(String email, String password) {
    try {
      return _box.values.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase().trim() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  UserModel update(UserModel user) {
    final normalizedEmail = user.email.toLowerCase().trim();
    final existing = _box.values.where(
      (u) => u.id != user.id && u.email.toLowerCase().trim() == normalizedEmail,
    );
    if (existing.isNotEmpty) {
      throw Exception('Email already exists');
    }

    _box.put(user.id, user);
    return user;
  }

  @override
  UserModel register({
    required String name,
    required String email,
    required String password,
    required String avatarColor,
  }) {
    final existing = _box.values
        .where((u) => u.email.toLowerCase() == email.toLowerCase().trim());
    if (existing.isNotEmpty) {
      throw Exception('Email already exists');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      password: password,
      avatarColor: avatarColor,
    );
    _box.put(user.id, user);
    return user;
  }
}
