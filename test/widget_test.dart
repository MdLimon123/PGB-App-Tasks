// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:pgb_app_tasks/main.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FieldTrackApp());
    
    // Verify the app widget is present
    expect(find.byType(FieldTrackApp), findsOneWidget);
  });
}
