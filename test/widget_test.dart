import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:password_generator/main.dart';

void main() {
  testWidgets('shows generator controls', (WidgetTester tester) async {
    await tester.pumpWidget(const PasswordGeneratorApp());

    expect(find.text('Password Generator'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
