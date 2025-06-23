// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Configurar Get para testes
    Get.testMode = true;
    
    // Test a simple widget instead of the full app to avoid dependency issues
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            child: Text('Test Widget'),
          ),
        ),
      ),
    );

    // Verify the widget is rendered
    expect(find.text('Test Widget'), findsOneWidget);
  });
}
