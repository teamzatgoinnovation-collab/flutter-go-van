import 'package:flutter/material.dart';

import '../data/mock_repo.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stops = mockRepo.listStops();

    return PageScaffold(
      title: 'Visits',
      subtitle: 'Customer calls with GPS stubs',
      child: stops.isEmpty
          ? const EmptyHint(
              'No visits scheduled.',
              icon: Icons.place_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: stops.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = stops[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Icon(switch (s.visitStatus) {
                      VisitStatus.completed => Icons.check_circle_outline,
                      VisitStatus.checkedIn => Icons.my_location,
                      VisitStatus.skipped => Icons.skip_next,
                      VisitStatus.planned => Icons.schedule,
                    }, color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      s.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${s.address}\nPlan ${timeLabel(s.plannedAt)} · '
                      '${s.lat.toStringAsFixed(3)}, ${s.lng.toStringAsFixed(3)}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      s.visitStatus.key,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

extension on VisitStatus {
  String get key => switch (this) {
    VisitStatus.planned => 'Planned',
    VisitStatus.checkedIn => 'In',
    VisitStatus.completed => 'Done',
    VisitStatus.skipped => 'Skip',
  };
}
