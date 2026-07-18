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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: stops.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = stops[i];
          return Card(
            child: ListTile(
              leading: Icon(switch (s.visitStatus) {
                VisitStatus.completed => Icons.check_circle_outline,
                VisitStatus.checkedIn => Icons.my_location,
                VisitStatus.skipped => Icons.skip_next,
                VisitStatus.planned => Icons.schedule,
              }, color: Theme.of(context).colorScheme.primary),
              title: Text(s.customerName),
              subtitle: Text(
                '${s.address}\nPlan ${timeLabel(s.plannedAt)} · '
                '${s.lat.toStringAsFixed(3)}, ${s.lng.toStringAsFixed(3)}',
              ),
              isThreeLine: true,
              trailing: Text(
                s.visitStatus.key,
                style: Theme.of(context).textTheme.labelMedium,
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
