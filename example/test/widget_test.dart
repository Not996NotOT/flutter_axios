// Flutter Axios widget test.
//
// This test file verifies that the Flutter Axios example app
// initializes properly and displays the expected UI elements.

import 'package:flutter/material.dart';
import 'package:flutter_axios_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flutter Axios app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('Flutter Axios + Build Runner'), findsOneWidget);

    // Verify that the FAB (add button) is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify that the refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Verify that the main content area is displayed (either loading, empty, or data)
    final hasRefreshIndicator =
        find.byType(RefreshIndicator).evaluate().isNotEmpty;
    final hasLoadingIndicator =
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasNoDataText = find.text('No user data').evaluate().isNotEmpty;
    expect(hasRefreshIndicator || hasLoadingIndicator || hasNoDataText, isTrue);
  });

  testWidgets('User dialog can be opened', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap the add button to open user dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the dialog opened
    expect(find.text('Create User'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Avatar URL'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);

    // Verify dialog buttons
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });
}
