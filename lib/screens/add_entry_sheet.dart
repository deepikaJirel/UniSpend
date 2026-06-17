import 'package:flutter/material.dart';

import '../models/category_data.dart';
import '../models/money_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/category_badge.dart';

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
  final formKey = GlobalKey<FormState>();
  late CategoryData selectedCategory;

  List<CategoryData> get categories => CategoryCatalog.forType(widget.isIncome);

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.isIncome
        ? categories.first
        : CategoryCatalog.find('Rent', isIncome: false);
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void saveEntry() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    widget.onSave(
      MoneyEntry(
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        isIncome: widget.isIncome,
        category: selectedCategory.name,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.isIncome;
    final accent = isIncome ? AppColors.forest : AppColors.coral;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth >= 620 ? 4 : 3;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIncome ? 'Add income' : 'Add expense',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                  ),
                            ),
                            Text(
                              isIncome
                                  ? 'Record money coming in'
                                  : 'Keep your spending picture accurate',
                              style: const TextStyle(color: AppColors.mutedInk),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'What was it for?',
                      hintText: isIncome ? 'Library shift' : 'Weekly groceries',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Add a short description'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.transactionAmount],
                    onFieldSubmitted: (_) => saveEntry(),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      return amount == null || amount <= 0
                          ? 'Enter an amount greater than zero'
                          : null;
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: saveEntry,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save transaction'),
                    style: ElevatedButton.styleFrom(backgroundColor: accent),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Choose a category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick the closest match - you can keep the title specific.',
                    style: TextStyle(color: AppColors.mutedInk),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: screenWidth < 380 ? .9 : 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = selectedCategory.name == category.name;
                      return Semantics(
                        button: true,
                        selected: selected,
                        label: category.name,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              setState(() => selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? category.backgroundColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? category.color.withValues(alpha: .55)
                                    : AppColors.border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CategoryBadge(
                                  category: category,
                                  selected: selected,
                                  size: 42,
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  category.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 12,
                                    height: 1.1,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
