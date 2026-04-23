import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/projects/presentation/providers/projects_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../data/models/task_model.dart';
import '../providers/tasks_providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _status = 'todo';
  String _priority = 'medium';
  String? _projectId;
  String? _assigneeId;
  DateTime? _dueDate;
  TaskModel? _editing;

  @override
  void initState() {
    super.initState();
    final projects = ref.read(projectsProvider);
    if (projects.isNotEmpty) {
      _projectId = projects.first.id;
    }

    if (widget.taskId != null) {
      final tasks = ref.read(tasksProvider);
      _editing = tasks.firstWhere((t) => t.id == widget.taskId);
      _titleCtrl.text = _editing!.title;
      _descriptionCtrl.text = _editing!.description;
      _status = _editing!.status;
      _priority = _editing!.priority;
      _projectId = _editing!.projectId;
      _assigneeId = _editing!.assigneeId;
      _dueDate = _editing!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(sessionProvider);
    if (user == null || _projectId == null) return;

    if (_editing == null) {
      await ref.read(tasksProvider.notifier).create(
            title: _titleCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            projectId: _projectId!,
            creatorId: user.id,
            assigneeId: _assigneeId,
            status: _status,
            priority: _priority,
            tags: const [],
            comments: const [],
            dueDate: _dueDate,
          );
    } else {
      await ref.read(tasksProvider.notifier).update(
            _editing!.copyWith(
              title: _titleCtrl.text.trim(),
              description: _descriptionCtrl.text.trim(),
              projectId: _projectId,
              assigneeId: _assigneeId,
              status: _status,
              priority: _priority,
              dueDate: _dueDate,
            ),
          );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.taskSaved)),
    );
    context.go('/tasks');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectsProvider);
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_editing == null ? l10n.createTask : l10n.editTask)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(labelText: l10n.title),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.description),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _projectId,
                  items: projects
                      .map((p) => DropdownMenuItem<String>(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _projectId = value),
                  decoration: InputDecoration(labelText: l10n.projects),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'todo', child: Text('todo')),
                    DropdownMenuItem(value: 'inProgress', child: Text('inProgress')),
                    DropdownMenuItem(value: 'done', child: Text('done')),
                  ],
                  onChanged: (value) => setState(() => _status = value ?? 'todo'),
                  decoration: InputDecoration(labelText: l10n.status),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('low')),
                    DropdownMenuItem(value: 'medium', child: Text('medium')),
                    DropdownMenuItem(value: 'high', child: Text('high')),
                  ],
                  onChanged: (value) => setState(() => _priority = value ?? 'medium'),
                  decoration: InputDecoration(labelText: l10n.priority),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dueDate),
                  subtitle: Text(_dueDate?.toLocal().toString().split(' ').first ?? '-'),
                  trailing: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _assigneeId,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
                    ...users.map(
                      (u) => DropdownMenuItem<String?>(
                        value: u.id,
                        child: Row(
                          children: [
                            UserAvatar(user: u, radius: 12),
                            const SizedBox(width: 8),
                            Text(u.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _assigneeId = value),
                  decoration: InputDecoration(labelText: l10n.assignee),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
