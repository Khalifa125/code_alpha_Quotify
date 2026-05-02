import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quotify/main.dart';

void main() {
  testWidgets('Quotify app should build', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QuotifyApp(),
      ),
    );

    expect(find.text('Quotify'), findsOneWidget);
  });
}