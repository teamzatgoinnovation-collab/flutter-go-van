import 'package:flutter/material.dart';

import '../data/mock_repo.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  void _refresh() => setState(() {});

  Future<void> _sync() async {
    final n = mockRepo.flushOfflineQueue();
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(n == 0 ? 'Nothing to sync' : 'Synced $n offline items (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = mockRepo.summary();
    final stops = mockRepo.listStops();

    return PageScaffold(
      title: 'Go Van',
      subtitle: mockRepo.routeName,
      actions: [
        IconButton(
          tooltip: 'Flush offline queue',
          onPressed: _sync,
          icon: const Icon(Icons.cloud_sync_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Today on the route',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Van sales stops, offline queue, and GPS check-ins — mock until go_van APIs land.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              StatTile(
                label: 'Stops done',
                value: '${summary.stopsDone}/${summary.stopsTotal}',
                icon: Icons.route_outlined,
              ),
              StatTile(
                label: 'Orders queued',
                value: '${summary.ordersQueued}',
                icon: Icons.outbox_outlined,
              ),
              StatTile(
                label: 'Collections',
                value: money(summary.collectionsToday),
                icon: Icons.payments_outlined,
              ),
              StatTile(
                label: 'Van SKUs',
                value: '${summary.vanStockSku}',
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Route stops',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...stops.map((stop) => _StopCard(stop: stop, onChanged: _refresh)),
        ],
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.stop, required this.onChanged});

  final RouteStop stop;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    '${stop.sequence}',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        stop.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeLabel(stop.plannedAt),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: scheme.secondary),
                const SizedBox(width: 4),
                Text(
                  '${stop.lat.toStringAsFixed(4)}, ${stop.lng.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                _VisitChip(status: stop.visitStatus),
              ],
            ),
            if (stop.visitStatus != VisitStatus.completed) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (stop.visitStatus == VisitStatus.planned)
                    FilledButton.tonal(
                      onPressed: () {
                        mockRepo.updateVisit(stop.id, VisitStatus.checkedIn);
                        onChanged();
                      },
                      child: const Text('GPS check-in'),
                    ),
                  if (stop.visitStatus == VisitStatus.checkedIn)
                    FilledButton(
                      onPressed: () {
                        mockRepo.updateVisit(stop.id, VisitStatus.completed);
                        onChanged();
                      },
                      child: const Text('Complete visit'),
                    ),
                  TextButton(
                    onPressed: () {
                      mockRepo.updateVisit(stop.id, VisitStatus.skipped);
                      onChanged();
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisitChip extends StatelessWidget {
  const _VisitChip({required this.status});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      VisitStatus.planned => ('Planned', Colors.blueGrey),
      VisitStatus.checkedIn => ('Checked in', const Color(0xFFE36414)),
      VisitStatus.completed => ('Done', const Color(0xFF0F4C5C)),
      VisitStatus.skipped => ('Skipped', Colors.brown),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}
