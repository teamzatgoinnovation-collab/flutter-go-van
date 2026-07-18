import 'package:flutter/material.dart';

import '../services/auth_scope.dart';
import '../services/session.dart';
import 'collections_page.dart';
import 'connection_page.dart';
import 'orders_page.dart';
import 'stock_page.dart';
import 'today_page.dart';
import 'visits_page.dart';

class GoVanShell extends StatefulWidget {
  const GoVanShell({
    super.key,
    required this.session,
    this.onRequireLogin,
  });

  final GoVanSession session;
  final VoidCallback? onRequireLogin;

  @override
  State<GoVanShell> createState() => _GoVanShellState();
}

class _GoVanShellState extends State<GoVanShell> {
  int _index = 0;

  Future<void> _signOut() async {
    await widget.session.logout();
    widget.onRequireLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TodayPage(),
      const OrdersPage(),
      const CollectionsPage(),
      const VisitsPage(),
      const StockPage(),
      ConnectionPage(
        session: widget.session,
        onSignOut: _signOut,
      ),
    ];

    return GoVanAuthScope(
      session: widget.session,
      onSignOut: _signOut,
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Cash',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Visits',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Stock',
            ),
            NavigationDestination(
              icon: Icon(Icons.link_outlined),
              selectedIcon: Icon(Icons.link),
              label: 'Link',
            ),
          ],
        ),
      ),
    );
  }
}
