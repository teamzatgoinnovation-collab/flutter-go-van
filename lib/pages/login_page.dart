import 'package:flutter/material.dart';
import 'package:zatgo_dart_sdk/zatgo_dart_sdk.dart';

import '../services/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.session, required this.onAuthed});

  final GoVanSession session;
  final VoidCallback onAuthed;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usr = TextEditingController();
  final _pwd = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _usr.dispose();
    _pwd.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final result = await widget.session.login(
      usr: _usr.text.trim(),
      pwd: _pwd.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result is ErpnextLoginOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in as ${result.session.fullName}'),
        ),
      );
      widget.onAuthed();
    } else if (result is ErpnextLoginFail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _ping() async {
    setState(() => _busy = true);
    final result = await widget.session.ping();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'ZatGo',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Go Van',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your ERPNext / Frappe site account.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usr,
                  decoration: const InputDecoration(
                    labelText: 'Email / User',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pwd,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                if (widget.session.lastError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.session.lastError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _login,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _ping,
                        child: const Text('Test site'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
