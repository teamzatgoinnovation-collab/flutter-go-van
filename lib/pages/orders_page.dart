import 'package:flutter/material.dart';

import '../data/mock_repo.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _newOrder() async {
    final customer = TextEditingController(text: 'City Grocer');
    final items = TextEditingController(text: '4 SKUs · beverages');
    final amount = TextEditingController(text: '560');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New offline order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customer,
              decoration: const InputDecoration(labelText: 'Customer'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: items,
              decoration: const InputDecoration(labelText: 'Items summary'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Queue'),
          ),
        ],
      ),
    );

    if (ok == true) {
      mockRepo.createOrder(
        customerName: customer.text.trim().isEmpty
            ? 'Customer'
            : customer.text.trim(),
        itemsLabel: items.text.trim().isEmpty ? 'Items' : items.text.trim(),
        amount: double.tryParse(amount.text) ?? 0,
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order queued offline (mock)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = mockRepo.listOrders(query: _query.text);

    return PageScaffold(
      title: 'Orders',
      subtitle: 'Offline-first van sales tickets',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newOrder,
        icon: const Icon(Icons.add),
        label: const Text('Order'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Filter orders…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const EmptyHint('No orders')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final o = orders[i];
                      return Card(
                        child: ListTile(
                          title: Text(o.customerName),
                          subtitle: Text('${o.itemsLabel}\n${o.id}'),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                money(o.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _SyncBadge(status: o.syncStatus),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.status});

  final OrderSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderSyncStatus.synced => ('Synced', const Color(0xFF0F4C5C)),
      OrderSyncStatus.queued => ('Queued', const Color(0xFFE36414)),
      OrderSyncStatus.failed => ('Failed', Colors.red.shade700),
    };
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}
