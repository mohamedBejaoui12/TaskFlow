import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_backdrop.dart';
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AppBackdrop(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withValues(alpha: 0.18),
                              scheme.tertiary.withValues(alpha: 0.16),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.folder_copy_outlined,
                            color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.projects,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${projects.length} projects, ${tasks.length} tasks, ${users.length} people',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: projects.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.folder_copy_outlined,
                      title: 'No projects yet',
                      subtitle:
                          'Create your first project to start planning work.',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final projectTasks = tasks
                            .where((t) => t.projectId == project.id)
                            .toList();
                        final done = projectTasks
                            .where((t) => t.status == 'done')
                            .length;
                        final progress = projectTasks.isEmpty
                            ? 0.0
                            : done / projectTasks.length;
                        final members = users
                            .where((u) => project.memberIds.contains(u.id))
                            .toList();

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
                            onDismissed: (_) => ref
                                .read(projectsProvider.notifier)
                                .delete(project.id),
                            child: ProjectCard(
                              project: project,
                              progress: progress,
                              members: members,
                              onTap: () =>
                                  context.go('/projects/${project.id}'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/form'),
        icon: const Icon(Icons.add),
        label: Text(l10n.createProject),
      ),
    );
  }
}
