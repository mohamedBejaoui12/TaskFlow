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
    final priorityColor = _priorityColor(scheme);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 132,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (assignee != null)
                          UserAvatar(user: assignee!, radius: 15),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        PriorityBadge(priority: task.priority),
                        const SizedBox(width: 8),
                        StatusChip(status: task.status, onTap: onStatusTap),
                        const Spacer(),
                        Icon(Icons.schedule_rounded,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.humanDate(task.dueDate),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppDateUtils.isOverdue(task.dueDate)
                            ? scheme.errorContainer.withValues(alpha: 0.85)
                            : priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppDateUtils.isOverdue(task.dueDate)
                            ? 'Overdue'
                            : 'Due soon',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppDateUtils.isOverdue(task.dueDate)
                                      ? scheme.error
                                      : priorityColor,
                                ),
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
