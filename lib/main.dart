import 'package:flutter/material.dart';

void main() {
  runApp(const UniSpendApp());
}

class UniSpendApp extends StatelessWidget {
  const UniSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSpend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF256D5A),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class MoneyEntry {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;

  MoneyEntry({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MoneyEntry> entries = [];

  double get totalIncome {
    return entries
        .where((entry) => entry.isIncome)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  double get totalExpense {
    return entries
        .where((entry) => !entry.isIncome)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  double get balance {
    return totalIncome - totalExpense;
  }

  double get safeWeeklySpend {
    return balance / 4;
  }

  void addEntry(MoneyEntry entry) {
    setState(() {
      entries.add(entry);
    });
  }

  void deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  void openAddEntrySheet(bool isIncome) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddEntrySheet(
          isIncome: isIncome,
          onSave: addEntry,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF256D5A),
        foregroundColor: Colors.white,
        title: const Text('UniSpend'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Know what you can spend.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: totalIncome,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Expenses',
                    amount: totalExpense,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Balance',
                    amount: balance,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Safe / Week',
                    amount: safeWeeklySpend,
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => openAddEntrySheet(true),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Income'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => openAddEntrySheet(false),
                    icon: const Icon(Icons.remove),
                    label: const Text('Add Expense'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'No income or expense added yet.\nStart by adding your first entry.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                entry.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                              ),
                            ),
                            title: Text(entry.title),
                            subtitle: Text(entry.category),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${entry.isIncome ? '+' : '-'}\$${entry.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: entry.isIncome
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => deleteEntry(index),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEntrySheet extends StatefulWidget {
  final bool isIncome;
  final Function(MoneyEntry) onSave;

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
  @override
void initState() {
  super.initState();
  selectedCategory = categories.first;
}

  List<String> get categories {
    if (widget.isIncome) {
      return [
        'Campus Job',
        'Tutoring',
        'Scholarship',
        'Family Support',
        'Other Income',
      ];
    } else {
      return [
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
  }

  void saveEntry() {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      return;
    }

    final entry = MoneyEntry(
      title: title,
      amount: amount,
      isIncome: widget.isIncome,
      category: selectedCategory,
    );

    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isIncome ? 'Add Income' : 'Add Expense',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveEntry,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}