import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/projects/presentation/providers/projects_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/task_card.dart';
import '../notifiers/task_filter.dart';
import '../providers/tasks_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tasks = ref.watch(filteredTasksProvider);
    final users = ref.watch(allUsersProvider);
    final projects = ref.watch(projectsProvider);
    final filter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tasks)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _DropdownFilter(
                  label: 'Status',
                  value: filter.status,
                  values: const ['todo', 'inProgress', 'done'],
                  onChanged: (v) => ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(status: v, clearStatus: v == null),
                ),
                _DropdownFilter(
                  label: 'Priority',
                  value: filter.priority,
                  values: const ['low', 'medium', 'high'],
                  onChanged: (v) => ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(priority: v, clearPriority: v == null),
                ),
                _DropdownFilter(
                  label: 'Project',
                  value: filter.projectId,
                  values: projects.map((p) => p.id).toList(),
                  valueText: (id) => projects.firstWhere((p) => p.id == id).name,
                  onChanged: (v) => ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(projectId: v, clearProject: v == null),
                ),
                TextButton(
                  onPressed: () => ref.read(taskFilterProvider.notifier).state = const TaskFilter(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.task_alt_outlined,
                    title: l10n.noData,
                    subtitle: 'Create tasks and assign them to your team.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final assignee = users.where((u) => u.id == task.assigneeId).firstOrNull;
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        child: Dismissible(
                          key: ValueKey(task.id),
                          background: Container(
                            padding: const EdgeInsets.only(left: 16),
                            alignment: Alignment.centerLeft,
                            color: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.check_circle_outline),
                          ),
                          secondaryBackground: Container(
                            padding: const EdgeInsets.only(right: 16),
                            alignment: Alignment.centerRight,
                            color: Theme.of(context).colorScheme.error,
                            child: const Icon(Icons.delete_outline),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await ref.read(tasksProvider.notifier).markDone(task);
                              if (!context.mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.markDone)),
                              );
                              return false;
                            }
                            ref.read(tasksProvider.notifier).delete(task.id);
                            if (!context.mounted) return true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.taskDeleted)),
                            );
                            return true;
                          },
                          child: TaskCard(
                            task: task,
                            assignee: assignee,
                            onStatusTap: () => ref.read(tasksProvider.notifier).cycleStatus(task),
                            onTap: () => context.go('/tasks/form/${task.id}'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/form'),
        icon: const Icon(Icons.add_task_outlined),
        label: Text(l10n.createTask),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.valueText,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  final String Function(String value)? valueText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String?>(
            value: value,
            underline: const SizedBox.shrink(),
            hint: Text(label),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...values.map(
                (v) => DropdownMenuItem<String?>(
                  value: v,
                  child: Text(valueText?.call(v) ?? v),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
