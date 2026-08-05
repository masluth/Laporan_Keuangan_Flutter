import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tester_antigravity/main.dart';

void main() {
  testWidgets('RevenantFinanceApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RevenantFinanceApp()));
    expect(find.byType(MaterialApp), findsNothing); // routed via MaterialApp.router
    expect(find.byType(Router), findsOneWidget);
  });
}
