import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/main.dart';

void main() {
  testWidgets('App should display Yoyotime', (WidgetTester tester) async {
    await tester.pumpWidget(const YoyotimeApp());
    expect(find.text('Yoyotime'), findsWidgets);
  });
}
