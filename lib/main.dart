import 'package:flutter/material.dart';

import 'data/mock_repo.dart';
import 'pages/login_page.dart';
import 'pages/shell.dart';
import 'services/session.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GoVanApp(session: GoVanSession()));
}

class GoVanApp extends StatefulWidget {
  const GoVanApp({super.key, required this.session});

  final GoVanSession session;

  @override
  State<GoVanApp> createState() => _GoVanAppState();
}

class _GoVanAppState extends State<GoVanApp> {
  bool _showLogin = true;

  @override
  void initState() {
    super.initState();
    _syncGate();
    widget.session.addListener(_syncGate);
  }

  @override
  void dispose() {
    widget.session.removeListener(_syncGate);
    super.dispose();
  }

  void _syncGate() {
    final authed = widget.session.connected;
    if (_showLogin == !authed) {
      if (authed) {
        mockRepo.refreshFromErpnext(widget.session);
      }
      return;
    }
    setState(() => _showLogin = !authed);
    if (authed) {
      mockRepo.refreshFromErpnext(widget.session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Van',
      debugShowCheckedModeBanner: false,
      theme: buildGoVanTheme(),
      home: _showLogin
          ? LoginPage(
              session: widget.session,
              onAuthed: () {
                setState(() => _showLogin = false);
                mockRepo.refreshFromErpnext(widget.session);
              },
            )
          : GoVanShell(
              session: widget.session,
              onRequireLogin: () => setState(() => _showLogin = true),
            ),
    );
  }
}
