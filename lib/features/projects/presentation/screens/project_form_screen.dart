import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../data/models/project_model.dart';
import '../providers/projects_providers.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.projectId});

  final String? projectId;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  Color _color = const Color(0xFF6C63FF);
  String _icon = 'work';
  final Set<String> _memberIds = {};
  ProjectModel? _editing;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      final projects = ref.read(projectsProvider);
      _editing = projects.firstWhere((p) => p.id == widget.projectId);
      _nameCtrl.text = _editing!.name;
      _descriptionCtrl.text = _editing!.description;
      _color = ColorUtils.fromHex(_editing!.colorHex);
      _icon = _editing!.icon;
      _memberIds.addAll(_editing!.memberIds);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final selected = await showColorPickerDialog(
      context,
      _color,
      title: const Text('Project Color'),
      enableShadesSelection: false,
      width: 40,
      height: 40,
    );
    if (selected != _color) {
      setState(() => _color = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(sessionProvider);
    if (user == null) return;

    if (_editing == null) {
      ref.read(projectsProvider.notifier).create(
            name: _nameCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            ownerId: user.id,
            memberIds: _memberIds.toList(),
            colorHex: ColorUtils.toHex(_color),
            icon: _icon,
          );
    } else {
      ref.read(projectsProvider.notifier).update(
            _editing!.copyWith(
              name: _nameCtrl.text.trim(),
              description: _descriptionCtrl.text.trim(),
              memberIds: _memberIds.toList(),
              colorHex: ColorUtils.toHex(_color),
              icon: _icon,
            ),
          );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.projectSaved)),
    );
    context.go('/projects');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_editing == null ? l10n.createProject : l10n.editProject)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: l10n.projectName),
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
                Row(
                  children: [
                    const Text('Color'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _pickColor,
                      child: CircleAvatar(backgroundColor: _color),
                    ),
                    const SizedBox(width: 24),
                    const Text('Icon'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _icon,
                      items: IconUtils.iconMap.keys
                          .map((key) => DropdownMenuItem(value: key, child: Text(key)))
                          .toList(),
                      onChanged: (value) => setState(() => _icon = value!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.members, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...allUsers.map(
            (u) => CheckboxListTile(
              value: _memberIds.contains(u.id),
              title: Text(u.name),
              secondary: UserAvatar(user: u),
              onChanged: (checked) {
                setState(() {
                  if (checked ?? false) {
                    _memberIds.add(u.id);
                  } else {
                    _memberIds.remove(u.id);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
