import 'package:flutter/material.dart';

import '../models/money_entry.dart';
import '../theme/app_theme.dart';

class AddEntrySheet extends StatefulWidget {
  final bool isIncome;
  final ValueChanged<MoneyEntry> onSave;

  const AddEntrySheet({
    super.key,
    required this.isIncome,
    required this.onSave,
  });

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  late String selectedCategory;

  List<String> get categories {
    if (widget.isIncome) {
      return const [
        'Campus Job',
        'Tutoring',
        'Scholarship',
        'Family Support',
        'Other Income',
      ];
    }

    return const [
      'Rent',
      'Groceries',
      'Food',
      'Transportation',
      'Shopping',
      'Phone Bill',
      'School Supplies',
      'Other Expense',
    ];
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void saveEntry() {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and a valid amount.')),
      );
      return;
    }

    widget.onSave(
      MoneyEntry(
        title: title,
        amount: amount,
        isIncome: widget.isIncome,
        category: selectedCategory,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isIncome ? 'Add income' : 'Add expense';
    final accent = widget.isIncome ? AppColors.forest : AppColors.coral;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.isIncome
                            ? Icons.add_card_rounded
                            : Icons.receipt_long_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Dining hall shift, groceries, textbook',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => selectedCategory = value);
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saveEntry,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
