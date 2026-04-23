import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/icon_utils.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../providers/projects_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectsProvider).firstWhere((p) => p.id == projectId);
    final tasks = ref.watch(tasksProvider).where((t) => t.projectId == project.id).toList();
    final users = ref.watch(allUsersProvider);

    final done = tasks.where((t) => t.status == 'done').length;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
    final members = users.where((u) => project.memberIds.contains(u.id)).toList();

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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: progress, minHeight: 10),
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.task_outlined,
                          title: 'No tasks yet',
                          subtitle: 'Create a task for this project.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final assignee = users.where((u) => u.id == task.assigneeId).firstOrNull;
                            return TaskCard(
                              task: task,
                              assignee: assignee,
                              onStatusTap: () => ref.read(tasksProvider.notifier).cycleStatus(task),
                              onTap: () => context.go('/tasks/form/${task.id}'),
                            );
                          },
                        ),
                ),
              ],
            ),
            members.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.group_off_outlined,
                    title: 'No members',
                    subtitle: 'Edit project and add team members.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final user = members[index];
                      return ListTile(
                        leading: UserAvatar(user: user),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
