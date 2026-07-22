import 'package:flutter/material.dart';

import '../data/mock_repo.dart';
import '../widgets/widgets.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  Future<void> _collect() async {
    final customer = TextEditingController(text: 'Fresh Basket Co-op');
    final amount = TextEditingController(text: '750');
    var method = 'Cash';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Record collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customer,
                decoration: const InputDecoration(labelText: 'Customer'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 10),
              DropdownMenu<String>(
                initialSelection: method,
                label: const Text('Method'),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Cash', label: 'Cash'),
                  DropdownMenuEntry(value: 'Card', label: 'Card'),
                  DropdownMenuEntry(value: 'Transfer', label: 'Transfer'),
                ],
                onSelected: (v) => setLocal(() => method = v ?? 'Cash'),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      mockRepo.recordCollection(
        customerName: customer.text.trim().isEmpty
            ? 'Customer'
            : customer.text.trim(),
        amount: double.tryParse(amount.text) ?? 0,
        method: method,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = mockRepo.listCollections();
    final total = rows.fold<double>(0, (s, c) => s + c.amount);
    final theme = Theme.of(context);

    return PageScaffold(
      title: 'Collections',
      subtitle: 'Cash / card take on the route',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _collect,
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Collect'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Card(
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Collected today'),
                trailing: Text(
                  money(total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const EmptyHint(
                    'No collections yet',
                    icon: Icons.payments_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final c = rows[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          title: Text(
                            c.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${c.method} · ${timeLabel(c.collectedAt)}'
                            '${c.synced ? '' : ' · pending sync'}',
                          ),
                          trailing: Text(
                            money(c.amount),
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
