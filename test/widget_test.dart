// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:delta_compressor_202501017/core/env/dev_environment.dart';
import 'package:delta_compressor_202501017/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize environment
    final appEnvironment = DevEnvironment();
    await appEnvironment.loadEnv();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(appEnvironment: appEnvironment));
    await tester.pumpAndSettle();

    // Verify that the app loads (check for MaterialApp)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
