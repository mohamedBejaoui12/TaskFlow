import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/projects/presentation/providers/projects_providers.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/project_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(sessionProvider);
    final tasks = ref.watch(tasksProvider);
    final projects = ref.watch(projectsProvider);
    final allUsers = ref.watch(allUsersProvider);

    final doneCount = tasks.where((t) => t.status == 'done').length;
    final inProgressCount = tasks.where((t) => t.status == 'inProgress').length;
    final todoCount = tasks.where((t) => t.status == 'todo').length;
    final unknownCount = tasks.length - doneCount - inProgressCount - todoCount;
    final normalizedTodoCount = todoCount + (unknownCount > 0 ? unknownCount : 0);
    final hasDistributionData = doneCount + inProgressCount + normalizedTodoCount > 0;
    final overdueCount = tasks.where((t) => t.status != 'done' && AppDateUtils.isOverdue(t.dueDate)).length;
    final dueToday = tasks.where((t) => t.status != 'done' && AppDateUtils.isDueToday(t.dueDate)).toList();

    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          title: Text('${l10n.welcomeBack}, ${user?.name ?? ''}'),
          actions: [
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ───────── Welcome Banner ─────────
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary.withValues(alpha: 0.85),
                        scheme.tertiary.withValues(alpha: 0.65),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep the pace',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tasks.length} ${l10n.tasks} in your workspace',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$doneCount/${tasks.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ───────── Stat Cards ─────────
              Row(
                children: [
                  _StatCard(
                    label: l10n.total,
                    value: tasks.length,
                    icon: Icons.layers_outlined,
                    color: scheme.primary,
                  ),
                  _StatCard(
                    label: l10n.done,
                    value: doneCount,
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    label: l10n.inProgress,
                    value: inProgressCount,
                    icon: Icons.pending_actions_outlined,
                    color: Colors.blue.shade400,
                  ),
                  _StatCard(
                    label: l10n.overdue,
                    value: overdueCount,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ───────── Task Distribution Chart ─────────
              const _SectionHeader(title: 'Task Distribution'),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (!hasDistributionData)
                          const SizedBox(
                            height: 180,
                            child: Center(
                              child: Text('No tasks available for distribution yet.'),
                            ),
                          )
                        else
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 36,
                                sections: [
                                  PieChartSectionData(
                                    value: doneCount.toDouble(),
                                    title: doneCount > 0 ? '$doneCount' : '',
                                    color: Colors.green.shade400,
                                    radius: 72,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: inProgressCount.toDouble(),
                                    title: inProgressCount > 0 ? '$inProgressCount' : '',
                                    color: Colors.blue.shade400,
                                    radius: 72,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: normalizedTodoCount.toDouble(),
                                    title: normalizedTodoCount > 0 ? '$normalizedTodoCount' : '',
                                    color: Colors.grey.shade500,
                                    radius: 72,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(color: Colors.green.shade400, label: l10n.done),
                            const SizedBox(width: 16),
                            _LegendItem(color: Colors.blue.shade400, label: l10n.inProgress),
                            const SizedBox(width: 16),
                            _LegendItem(color: Colors.grey.shade500, label: 'Todo'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ───────── Tasks Due Today ─────────
              _SectionHeader(title: l10n.tasksDueToday),
              if (dueToday.isEmpty)
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: EmptyStateWidget(
                    icon: Icons.event_available,
                    title: l10n.noData,
                    subtitle: 'No due tasks today.',
                  ),
                )
              else
                ...dueToday.take(4).map(
                      (task) => FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _TaskDueCard(task: task, context: context),
                      ),
                    ),
              const SizedBox(height: 28),

              // ───────── Recent Projects ─────────
              _SectionHeader(title: l10n.recentProjects),
              const SizedBox(height: 8),
              SizedBox(
                height: 240,
                child: projects.isEmpty
                    ? FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: EmptyStateWidget(
                          icon: Icons.folder_off_outlined,
                          title: l10n.noData,
                          subtitle: 'Start by creating a project.',
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            ...List.generate(projects.length > 5 ? 5 : projects.length, (index) {
                              final project = projects[index];
                              final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
                              final done = projectTasks.where((t) => t.status == 'done').length;
                              final progress = projectTasks.isEmpty ? 0.0 : done / projectTasks.length;
                              final members = allUsers.where((u) => project.memberIds.contains(u.id)).toList();

                              return Padding(
                                padding: EdgeInsets.only(right: index == (projects.length > 5 ? 5 : projects.length) - 1 ? 0 : 14),
                                child: SizedBox(
                                  width: 280,
                                  child: FadeInUp(
                                    delay: Duration(milliseconds: 400 + (index * 100)),
                                    child: ProjectCard(
                                      project: project,
                                      progress: progress,
                                      members: members,
                                      onTap: () => context.go('/projects/${project.id}'),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

// ───────── Helper Widgets ─────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeInUp(
        delay: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TaskDueCard extends StatelessWidget {
  const _TaskDueCard({required this.task, required this.context});
  final dynamic task;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.humanDate(task.dueDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}