import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_providers.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../notifiers/session_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(const Uuid());
});

final sessionProvider = StateNotifierProvider<SessionNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return SessionNotifier(repo, prefs);
});

final allUsersProvider = Provider<List<UserModel>>((ref) {
  ref.watch(sessionProvider);
  return ref.watch(authRepositoryProvider).getAllUsers();
});
