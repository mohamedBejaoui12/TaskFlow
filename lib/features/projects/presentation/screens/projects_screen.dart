import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/project_card.dart';
import '../providers/projects_providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectsProvider);
    final tasks = ref.watch(tasksProvider);
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projects)),
      body: projects.isEmpty
          ? EmptyStateWidget(
              icon: Icons.folder_copy_outlined,
              title: l10n.noData,
              subtitle: 'Create your first project to start planning work.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
                final done = projectTasks.where((t) => t.status == 'done').length;
                final progress = projectTasks.isEmpty ? 0.0 : done / projectTasks.length;
                final members = users.where((u) => project.memberIds.contains(u.id)).toList();

                return FadeInUp(
                  delay: Duration(milliseconds: 60 * index),
                  child: Dismissible(
                    key: ValueKey(project.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => ref.read(projectsProvider.notifier).delete(project.id),
                    child: ProjectCard(
                      project: project,
                      progress: progress,
                      members: members,
                      onTap: () => context.go('/projects/${project.id}'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/form'),
        icon: const Icon(Icons.add),
        label: Text(l10n.createProject),
      ),
    );
  }
}
