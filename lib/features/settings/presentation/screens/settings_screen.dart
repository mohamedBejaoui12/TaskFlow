import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            value: themeMode == ThemeMode.dark,
            title: Text(l10n.darkMode),
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).setMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(locale.languageCode == 'fr' ? l10n.french : l10n.english),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.english)),
                ButtonSegment(value: 'fr', label: Text(l10n.french)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (selection) {
                ref.read(localeProvider.notifier).setLocale(selection.first);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
