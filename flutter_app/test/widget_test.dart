import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:at_gateway_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This is a basic smoke test to verify the app can be built
    // You can add more specific tests as needed
    
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

