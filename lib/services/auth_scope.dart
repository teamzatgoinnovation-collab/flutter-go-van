import 'package:flutter/material.dart';

import 'session.dart';

class GoVanAuthScope extends InheritedWidget {
  const GoVanAuthScope({
    super.key,
    required this.session,
    required this.onSignOut,
    required super.child,
  });

  final GoVanSession session;
  final Future<void> Function() onSignOut;

  static GoVanAuthScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GoVanAuthScope>();
  }

  @override
  bool updateShouldNotify(GoVanAuthScope oldWidget) {
    return session != oldWidget.session || onSignOut != oldWidget.onSignOut;
  }
}
