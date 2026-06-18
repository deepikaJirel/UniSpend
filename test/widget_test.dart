import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unispend/unispend_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
    await tester.pumpAndSettle();
    expect(find.text('Save for lab supplies'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final savedTransactions = preferences.getStringList(
      'unispend.transactions',
    );
    final savedExpense = jsonDecode(savedTransactions!.last);

    expect(savedTransactions, hasLength(2));
    expect(savedExpense['title'], 'Groceries');
    expect(savedExpense['amount'], 35);
    expect(savedExpense['isIncome'], isFalse);
    expect(savedExpense['category'], 'Rent');
    expect(
      preferences.getString('unispend.moneyNote'),
      'Save for lab supplies',
    );
  });

  testWidgets('restores saved transactions, categories, and Money Notes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'unispend.transactions': [
        jsonEncode({
          'title': 'Coffee before class',
          'amount': 6.75,
          'isIncome': false,
          'category': 'Coffee / Starbucks',
          'createdAt': '2026-06-17T08:30:00.000',
        }),
        jsonEncode({
          'title': 'Math tutoring',
          'amount': 45.0,
          'isIncome': true,
          'category': 'Tutoring',
          'createdAt': '2026-06-17T14:00:00.000',
        }),
      ],
      'unispend.moneyNote': 'Textbook payment is due Friday',
    });

    await tester.pumpWidget(const UniSpendApp());
    await tester.pumpAndSettle();

    expect(find.text('Coffee before class'), findsOneWidget);
    expect(find.text('Coffee / Starbucks'), findsOneWidget);
    expect(find.text('Math tutoring'), findsOneWidget);
    expect(find.text('Tutoring'), findsOneWidget);
    expect(find.textContaining(r'$38.25'), findsWidgets);

    final notesField = tester.widget<TextField>(find.byType(TextField));
    expect(notesField.controller?.text, 'Textbook payment is due Friday');
  });

  testWidgets('remembers the last selected income and expense categories', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'unispend.selectedIncomeCategory': 'Scholarship',
      'unispend.selectedExpenseCategory': 'Rent',
    });

    await tester.pumpWidget(const UniSpendApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Income'));
    await tester.pumpAndSettle();
    final incomeFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(incomeFields.first, 'Merit award');
    await tester.enterText(incomeFields.last, '500');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    final savedTransactions = preferences.getStringList(
      'unispend.transactions',
    );
    final savedIncome = jsonDecode(savedTransactions!.single);
    expect(savedIncome['category'], 'Scholarship');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Expense'));
    await tester.pumpAndSettle();
    final coffeeCategory = find.text('Coffee / Starbucks');
    await tester.ensureVisible(coffeeCategory);
    await tester.tap(coffeeCategory);
    await tester.pumpAndSettle();

    expect(
      preferences.getString('unispend.selectedExpenseCategory'),
      'Coffee / Starbucks',
    );
  });
}
