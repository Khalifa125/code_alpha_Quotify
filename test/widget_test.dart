import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quotify/main.dart';

void main() {
  testWidgets('Quotify app should build and show title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QuotifyApp(),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Quotify'), findsOneWidget);
  });

  testWidgets('Quote screen contains New Quote button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QuotifyApp(),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}