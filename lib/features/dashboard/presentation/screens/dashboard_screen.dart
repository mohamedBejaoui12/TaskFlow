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
    final overdueCount = tasks.where((t) => t.status != 'done' && AppDateUtils.isOverdue(t.dueDate)).length;
    final dueToday = tasks.where((t) => t.status != 'done' && AppDateUtils.isDueToday(t.dueDate)).toList();

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FadeInUp(
                child: Row(
                  children: [
                    _StatCard(label: l10n.total, value: tasks.length),
                    _StatCard(label: l10n.done, value: doneCount),
                  ],
                ),
              ),
              Row(
                children: [
                  _StatCard(label: l10n.inProgress, value: inProgressCount),
                  _StatCard(label: l10n.overdue, value: overdueCount),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 48,
                        sections: [
                          PieChartSectionData(value: doneCount.toDouble(), title: l10n.done),
                          PieChartSectionData(value: inProgressCount.toDouble(), title: l10n.inProgress),
                          PieChartSectionData(
                            value: (tasks.length - doneCount - inProgressCount).toDouble(),
                            title: 'Todo',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(l10n.tasksDueToday, style: Theme.of(context).textTheme.titleLarge),
              if (dueToday.isEmpty)
                EmptyStateWidget(
                  icon: Icons.event_available,
                  title: l10n.noData,
                  subtitle: 'No due tasks today.',
                )
              else
                ...dueToday.take(4).map(
                      (task) => ListTile(
                        title: Text(task.title),
                        subtitle: Text(AppDateUtils.humanDate(task.dueDate)),
                      ),
                    ),
              const SizedBox(height: 18),
              Text(l10n.recentProjects, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              SizedBox(
                height: 240,
                child: projects.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.folder_off_outlined,
                        title: l10n.noData,
                        subtitle: 'Start by creating a project.',
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: projects.length > 5 ? 5 : projects.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
                          final done = projectTasks.where((t) => t.status == 'done').length;
                          final progress = projectTasks.isEmpty ? 0.0 : done / projectTasks.length;
                          final members = allUsers.where((u) => project.memberIds.contains(u.id)).toList();

                          return SizedBox(
                            width: 290,
                            child: ProjectCard(
                              project: project,
                              progress: progress,
                              members: members,
                              onTap: () => context.go('/projects/${project.id}'),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 22),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
