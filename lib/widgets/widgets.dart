import 'package:flutter/material.dart';

import '../services/auth_scope.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final auth = GoVanAuthScope.maybeOf(context);
    final mergedActions = <Widget>[
      ...?actions,
      if (auth != null)
        IconButton(
          tooltip: 'Sign out',
          onPressed: () => auth.onSignOut(),
          icon: const Icon(Icons.logout_rounded),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        actions: mergedActions.isEmpty ? null : mergedActions,
      ),
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

String money(num value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 2);

String timeLabel(DateTime? dt) {
  if (dt == null) return '—';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
