import 'package:flutter_test/flutter_test.dart';
import 'package:go_van/main.dart';
import 'package:go_van/services/session.dart';

void main() {
  testWidgets('shell shows Go Van brand and route', (tester) async {
    await tester.pumpWidget(GoVanApp(session: GoVanSession()));
    expect(find.text('Go Van'), findsWidgets);
    expect(find.textContaining('Riyadh North'), findsOneWidget);
  });
}
