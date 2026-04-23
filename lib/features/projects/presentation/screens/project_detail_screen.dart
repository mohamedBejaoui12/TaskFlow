import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/icon_utils.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../../../shared/widgets/app_backdrop.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../providers/projects_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project =
        ref.watch(projectsProvider).firstWhere((p) => p.id == projectId);
    final tasks = ref
        .watch(tasksProvider)
        .where((t) => t.projectId == project.id)
        .toList();
    final users = ref.watch(allUsersProvider);
    final scheme = Theme.of(context).colorScheme;

    final done = tasks.where((t) => t.status == 'done').length;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
    final members =
        users.where((u) => project.memberIds.contains(u.id)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: 'project-${project.id}',
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(IconUtils.fromKey(project.icon)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(project.name)),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go('/projects/form/${project.id}'),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Tasks'), Tab(text: 'Team')]),
        ),
        body: TabBarView(
          children: [
            AppBackdrop(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
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
                                child: Icon(Icons.timeline_rounded,
                                    color: scheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$done of ${tasks.length} tasks completed',
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
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              color: scheme.primary,
                              backgroundColor: scheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _DetailStat(
                                  label: 'Tasks', value: '${tasks.length}'),
                              const SizedBox(width: 12),
                              _DetailStat(label: 'Done', value: '$done'),
                              const SizedBox(width: 12),
                              _DetailStat(
                                  label: 'Members', value: '${members.length}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: tasks.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.task_outlined,
                            title: 'No tasks yet',
                            subtitle: 'Create a task for this project.',
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final assignee = users
                                  .where((u) => u.id == task.assigneeId)
                                  .firstOrNull;
                              return TaskCard(
                                task: task,
                                assignee: assignee,
                                onStatusTap: () => ref
                                    .read(tasksProvider.notifier)
                                    .cycleStatus(task),
                                onTap: () =>
                                    context.go('/tasks/form/${task.id}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            AppBackdrop(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: Container(
                        height: 48,
                        width: 48,
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
                        child:
                            Icon(Icons.groups_rounded, color: scheme.primary),
                      ),
                      title: Text('Team'),
                      subtitle: Text(
                          '${members.length} people assigned to this project'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: members.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.group_off_outlined,
                            title: 'No members',
                            subtitle: 'Edit project and add team members.',
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final user = members[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: UserAvatar(user: user),
                                  title: Text(user.name),
                                  subtitle: Text(user.email),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
