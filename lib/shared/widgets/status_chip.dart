import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.onTap});

  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      'done' => scheme.primary,
      'inProgress' => scheme.tertiary,
      _ => scheme.secondary,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ActionChip(
        key: ValueKey(status),
        label: Text(status),
        avatar: Icon(Icons.sync, size: 16, color: color),
        side: BorderSide(color: color),
        onPressed: onTap,
      ),
    );
  }
}
