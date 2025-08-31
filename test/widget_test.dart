// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart'; // This should be TouristApp

void main() {
  testWidgets('Login Page UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // CHANGE MyApp() to TouristApp() to match your main.dart
    await tester.pumpWidget(const TouristApp());

    // Verify that the welcome text is present.
    expect(find.text("Welcome\nস্বাগতম\nस्वागत"), findsOneWidget);

    // Verify that the two registration buttons are present.
    expect(find.text("Self-Register"), findsOneWidget);
    expect(find.text("Counter Desk Register"), findsOneWidget);
  });
}