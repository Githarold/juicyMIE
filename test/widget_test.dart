// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pentastic/main.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PrinterControlApp());

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the MainScreen is present
    expect(find.byType(MainScreen), findsOneWidget);

    // Verify that the BottomNavigationBar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that the initial screen is HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap the Files icon and verify that FilesScreen appears
    await tester.tap(find.byIcon(Icons.file_copy));
    await tester.pumpAndSettle();
    expect(find.byType(FilesScreen), findsOneWidget);

    // Tap the Settings icon and verify that SettingsScreen appears
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
