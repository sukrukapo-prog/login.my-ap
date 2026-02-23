import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitmatrics_app/main.dart'; // ← make sure this import is correct

void main() {
  testWidgets('Welcome screen shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const FitMetricsApp());

    // Check that the app title appears
    expect(find.text('FitMetrics'), findsOneWidget);

    // Optional: check quote text exists
    expect(find.text('"Ready for our fitness journey?"'), findsOneWidget);
    expect(find.text('"Start tracking today!"'), findsOneWidget);

    // Optional: check Sign Up button exists
    expect(find.text('Sign Up'), findsOneWidget);
  });
}