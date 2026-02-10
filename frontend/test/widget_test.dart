// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:localai_frontend/main.dart';
import 'package:localai_frontend/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LocalAIApp());

    // Verify that the login page is shown.
    expect(find.text('LocalAI'), findsAtLeast(1));
    expect(find.text('Login'), findsAtLeast(1));
  });
}

