// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/widgets.dart';
import 'package:myapp/main.dart';
void main() {
  testWidgets('Chess game smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChessApp());

    // Verify that the chess game loads properly.
    expect(find.text('Chess Game'), findsOneWidget);
    expect(find.text('White\'s turn'), findsOneWidget);
    
    // Verify that the chess board is present
    expect(find.byType(GridView), findsOneWidget);
  });
}
