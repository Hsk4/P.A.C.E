// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter1/main.dart';

void main() {
  testWidgets('Pomodoro start/pause button toggles', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Verify initial UI has Start button
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);

    // Tap Start and verify it becomes Pause
    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });
}
