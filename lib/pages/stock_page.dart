import 'package:flutter/material.dart';

import '../data/mock_repo.dart';
import '../widgets/widgets.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Future<void> _transfer(String itemCode, String itemName) async {
    final qty = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Transfer $itemName'),
        content: TextField(
          controller: qty,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Qty out (to customer / return)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (ok == true) {
      mockRepo.transferStock(
        itemCode: itemCode,
        qty: double.tryParse(qty.text) ?? 0,
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock adjusted (mock transfer)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = mockRepo.listStock();

    return PageScaffold(
      title: 'Van stock',
      subtitle: 'On-board inventory & transfers',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: stock.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final line = stock[i];
          return Card(
            child: ListTile(
              title: Text(line.itemName),
              subtitle: Text(line.itemCode),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${money(line.qty)} ${line.uom}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    tooltip: 'Transfer',
                    onPressed: () => _transfer(line.itemCode, line.itemName),
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
