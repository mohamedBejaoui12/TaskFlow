import 'package:animate_do/animate_do.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/app_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_backdrop.dart';
import '../../../../shared/widgets/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String initialName,
    String initialEmail,
    String initialAvatarColor,
  ) async {
    final nameCtrl = TextEditingController(text: initialName);
    final emailCtrl = TextEditingController(text: initialEmail);
    var avatarColor = ColorUtils.fromHex(initialAvatarColor);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Avatar color'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final selected = await showColorPickerDialog(
                              context,
                              avatarColor,
                              title: const Text('Avatar Color'),
                              width: 40,
                              height: 40,
                              borderRadius: 20,
                              enableShadesSelection: false,
                              pickersEnabled: const {
                                ColorPickerType.wheel: true,
                                ColorPickerType.primary: true,
                                ColorPickerType.accent: false,
                              },
                            );
                            setDialogState(() => avatarColor = selected);
                          },
                          child: CircleAvatar(backgroundColor: avatarColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();

                    if (name.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter valid name and email.')),
                      );
                      return;
                    }

                    try {
                      ref.read(sessionProvider.notifier).updateProfile(
                            name: name,
                            email: email,
                            avatarColor: ColorUtils.toHex(avatarColor),
                          );
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                e.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final user = ref.watch(sessionProvider);

    return Scaffold(
      body: AppBackdrop(
        child: ListView(
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.18),
                              Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withValues(alpha: 0.16),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.tune_rounded,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settings,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Personalize the workspace experience',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (user != null)
              FadeInUp(
                delay: const Duration(milliseconds: 90),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: UserAvatar(user: user, radius: 20),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: TextButton.icon(
                      onPressed: () => _showEditProfileDialog(
                        context,
                        ref,
                        user.name,
                        user.email,
                        user.avatarColor,
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                ),
              ),
            if (user != null) const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: themeMode == ThemeMode.dark,
                      title: Text(l10n.darkMode),
                      subtitle: Text(
                          'Toggle the interface between light and dark tones'),
                      onChanged: (value) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setMode(value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.language),
                      subtitle: Text(locale.languageCode == 'fr'
                          ? l10n.french
                          : l10n.english),
                      trailing: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'en', label: Text(l10n.english)),
                          ButtonSegment(value: 'fr', label: Text(l10n.french)),
                        ],
                        selected: {locale.languageCode},
                        onSelectionChanged: (selection) {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(selection.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logout),
                  subtitle:
                      const Text('Sign out of the current workspace session'),
                  onTap: () async {
                    await ref.read(sessionProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
