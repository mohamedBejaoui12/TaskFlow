import 'package:flutter/material.dart';

import '../../core/utils/color_utils.dart';
import '../../core/utils/icon_utils.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/projects/data/models/project_model.dart';
import 'user_avatar.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.progress,
    required this.members,
    required this.onTap,
  });

  final ProjectModel project;
  final double progress;
  final List<UserModel> members;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = ColorUtils.fromHex(project.colorHex);

    return Hero(
      tag: 'project-${project.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: color.withValues(alpha: 0.22),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(IconUtils.fromKey(project.icon), color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: Stack(
                        children: [
                          for (var i = 0; i < members.take(4).length; i++)
                            Positioned(
                              left: i * 20,
                              child: UserAvatar(user: members[i], radius: 14),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
