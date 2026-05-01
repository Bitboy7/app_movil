// This is a basic Flutter widget test for the AppMovil application.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_movil/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppMovil()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
