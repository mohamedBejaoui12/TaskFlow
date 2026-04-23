import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/shared_prefs_keys.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class SessionNotifier extends StateNotifier<UserModel?> {
  SessionNotifier(this._repository, this._prefs) : super(null) {
    _restoreSession();
  }

  final AuthRepository _repository;
  final SharedPreferences _prefs;

  void _restoreSession() {
    final userId = _prefs.getString(SharedPrefsKeys.sessionUserId);
    if (userId == null) return;
    state = _repository.findUserById(userId);
  }

  UserModel? login(String email, String password) {
    final user = _repository.login(email, password);
    if (user == null) return null;
    state = user;
    _prefs.setString(SharedPrefsKeys.sessionUserId, user.id);
    return user;
  }

  UserModel register({
    required String name,
    required String email,
    required String password,
    required String avatarColor,
  }) {
    final user = _repository.register(
      name: name,
      email: email,
      password: password,
      avatarColor: avatarColor,
    );
    state = user;
    _prefs.setString(SharedPrefsKeys.sessionUserId, user.id);
    return user;
  }

  UserModel updateProfile({
    required String name,
    required String email,
    required String avatarColor,
  }) {
    final current = state;
    if (current == null) {
      throw Exception('No active session');
    }

    final updated = _repository.update(
      current.copyWith(
        name: name.trim(),
        email: email.trim(),
        avatarColor: avatarColor,
      ),
    );
    state = updated;
    return updated;
  }

  Future<void> logout() async {
    state = null;
    await _prefs.remove(SharedPrefsKeys.sessionUserId);
  }
}
