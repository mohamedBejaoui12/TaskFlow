import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import 'priority_badge.dart';
import 'status_chip.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.assignee,
    required this.onStatusTap,
    required this.onTap,
  });

  final TaskModel task;
  final UserModel? assignee;
  final VoidCallback onStatusTap;
  final VoidCallback onTap;

  Color _priorityColor(ColorScheme scheme) {
    return switch (task.priority) {
      'high' => scheme.error,
      'medium' => scheme.tertiary,
      _ => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        child: Row(
          children: [
            Container(
              width: 6,
              height: 100,
              decoration: BoxDecoration(
                color: _priorityColor(scheme),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        PriorityBadge(priority: task.priority),
                        const SizedBox(width: 8),
                        StatusChip(status: task.status, onTap: onStatusTap),
                        const Spacer(),
                        if (assignee != null) UserAvatar(user: assignee!, radius: 14),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppDateUtils.isOverdue(task.dueDate)
                            ? scheme.errorContainer
                            : scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Due: ${AppDateUtils.humanDate(task.dueDate)}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
