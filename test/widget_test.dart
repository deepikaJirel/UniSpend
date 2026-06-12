import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unispend/unispend_app.dart';

void main() {
  testWidgets('UniSpend dashboard renders and tracks entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UniSpendApp());

    expect(find.text('UniSpend'), findsOneWidget);
    expect(find.text('Know what you can spend.'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Safe to spend'), findsWidgets);
    expect(find.text('Weekly Summary'), findsOneWidget);
    expect(find.text('Money Notes'), findsOneWidget);
    expect(
      find.text('You are balanced, but be careful with extra spending.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Income'));
    await tester.pumpAndSettle();
    final incomeFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(incomeFields.first, 'Campus job');
    await tester.enterText(incomeFields.last, '120');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Campus job'), findsOneWidget);
    expect(find.textContaining('\$120.00'), findsWidgets);
    expect(find.text("You're on track this week."), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Expense'));
    await tester.pumpAndSettle();
    final expenseFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(expenseFields.first, 'Groceries');
    await tester.enterText(expenseFields.last, '35');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('\$85.00'), findsWidgets);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Save for lab supplies');
    expect(find.text('Save for lab supplies'), findsOneWidget);
  });
}
