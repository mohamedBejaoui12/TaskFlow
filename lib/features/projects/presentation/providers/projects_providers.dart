import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/project_model.dart';
import '../../data/repositories/projects_repository_impl.dart';
import '../../domain/repositories/projects_repository.dart';
import '../notifiers/projects_notifier.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepositoryImpl();
});

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<ProjectModel>>((ref) {
  final repo = ref.watch(projectsRepositoryProvider);
  return ProjectsNotifier(repo, const Uuid());
});

final selectedProjectProvider = StateProvider<ProjectModel?>((ref) => null);
