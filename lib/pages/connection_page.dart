import 'package:flutter/material.dart';

import '../services/connection.dart';
import '../services/session.dart';
import '../widgets/widgets.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({
    super.key,
    required this.session,
    this.onSignOut,
  });

  final GoVanSession session;
  final VoidCallback? onSignOut;

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _ping() async {
    setState(() => _busy = true);
    final result = await testConnection(widget.session);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    setState(() => _busy = false);
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    await widget.session.logout();
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onSignOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return PageScaffold(
      title: 'Connection',
      subtitle: 'ERPNext session status',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Sign in with site email and password. API keys are for server '
            'integrations, not app login.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListenableBuilder(
                listenable: session,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (session.connected)
                        Text(
                          'Signed in as ${session.fullName ?? session.user}',
                          style: Theme.of(context).textTheme.titleSmall,
                        )
                      else
                        Text(
                          'Not signed in (mock data available).',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    await _logout();
                                  },
                            child: const Text('Sign out'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _busy ? null : _ping,
                            child: const Text('Test site'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        session.connected
                            ? 'Status: Connected as ${session.user}'
                            : 'Status: Not signed in'
                                '${session.lastError != null ? ' — ${session.lastError}' : ''}',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
