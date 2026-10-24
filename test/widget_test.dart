// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:docvexa/core/navigation/app_shell.dart';
import 'package:docvexa/core/navigation/user_role.dart';
import 'package:docvexa/main.dart';

void main() {
  testWidgets('shows the Docvexa appointment flow', (tester) async {
    await tester.pumpWidget(const DocvexaApp());

    expect(find.text('Docvexa'), findsOneWidget);
    expect(find.text('Your care, simplified'), findsOneWidget);
    expect(find.text('Appointment flow'), findsOneWidget);
    expect(find.text('Select Doctor'), findsOneWidget);
  });

  testWidgets('advances through the appointment flow', (tester) async {
    await tester.pumpWidget(const DocvexaApp());

    final nextButton = find.text('Next').first;
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Select Date & Time'), findsOneWidget);
    expect(
      find.text('Pick a time slot that works best for your consultation.'),
      findsOneWidget,
    );
  });

  testWidgets('patient shell exposes its main navigation areas', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppShell(role: UserRole.patient)),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);

    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();

    expect(
      find.text('Appointment history will appear here once connected.'),
      findsOneWidget,
    );
  });
}
