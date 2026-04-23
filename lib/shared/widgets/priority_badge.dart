import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final String priority;

  Color _color(ColorScheme scheme) {
    return switch (priority) {
      'high' => scheme.error,
      'medium' => scheme.tertiary,
      _ => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = _color(scheme).withValues(alpha: 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: _color(scheme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
