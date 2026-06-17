import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/money_entry.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_header.dart';
import '../widgets/transaction_tile.dart';
import 'add_entry_sheet.dart';

class UniSpendShell extends StatefulWidget {
  const UniSpendShell({super.key});

  @override
  State<UniSpendShell> createState() => _UniSpendShellState();
}

class _UniSpendShellState extends State<UniSpendShell> {
  static const _entriesKey = 'unispend.transactions';
  static const _moneyNoteKey = 'unispend.moneyNote';

  final List<MoneyEntry> entries = [];
  final moneyNoteController = TextEditingController();
  int selectedIndex = 0;
  String moneyNote = '';

  double get totalIncome => entries
      .where((entry) => entry.isIncome)
      .fold(0, (sum, entry) => sum + entry.amount);

  double get totalExpense => entries
      .where((entry) => !entry.isIncome)
      .fold(0, (sum, entry) => sum + entry.amount);

  double get balance => totalIncome - totalExpense;

  double get safeWeeklySpend => balance / 4;

  double get safeDailySpend => balance / 30;

  List<MoneyEntry> get recentEntries => entries.reversed.take(5).toList();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    moneyNoteController.dispose();
    super.dispose();
  }

  void addEntry(MoneyEntry entry) {
    setState(() => entries.add(entry));
    _saveTransactions();
  }

  void deleteEntry(MoneyEntry entry) {
    setState(() => entries.remove(entry));
    _saveTransactions();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEntries = prefs.getStringList(_entriesKey) ?? [];
    final savedNote = prefs.getString(_moneyNoteKey) ?? '';

    final loadedEntries = savedEntries
        .map((entryJson) {
          try {
            final decoded = jsonDecode(entryJson) as Map<String, dynamic>;
            return MoneyEntry.fromJson(decoded);
          } on FormatException {
            return null;
          } on TypeError {
            return null;
          }
        })
        .whereType<MoneyEntry>()
        .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      entries
        ..clear()
        ..addAll(loadedEntries);
      moneyNote = savedNote;
      moneyNoteController.text = savedNote;
    });
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final entryJson = entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(_entriesKey, entryJson);
  }

  Future<void> _saveMoneyNote(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_moneyNoteKey, value);
  }

  void updateMoneyNote(String value) {
    setState(() => moneyNote = value);
    _saveMoneyNote(value);
  }

  void openAddEntrySheet(bool isIncome) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddEntrySheet(isIncome: isIncome, onSave: addEntry);
      },
    );
  }

  void onNavTap(int index) {
    if (index == 1) {
      _showAddChoice();
      return;
    }

    setState(() => selectedIndex = index);
  }

  void _showAddChoice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                Text(
                  'Add transaction',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          openAddEntrySheet(true);
                        },
                        icon: const Icon(Icons.south_west_rounded),
                        label: const Text('Income'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          openAddEntrySheet(false);
                        },
                        icon: const Icon(Icons.north_east_rounded),
                        label: const Text('Expense'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardView(
        entries: entries,
        recentEntries: recentEntries,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        safeWeeklySpend: safeWeeklySpend,
        safeDailySpend: safeDailySpend,
        moneyNoteController: moneyNoteController,
        moneyNote: moneyNote,
        onMoneyNoteChanged: updateMoneyNote,
        onAddIncome: () => openAddEntrySheet(true),
        onAddExpense: () => openAddEntrySheet(false),
        onDeleteEntry: deleteEntry,
      ),
      const SizedBox.shrink(),
      BudgetView(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        safeWeeklySpend: safeWeeklySpend,
        onAddExpense: () => openAddEntrySheet(false),
      ),
      ReportsView(
        entries: entries,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ),
      const ProfileView(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onNavTap,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.mintStrong,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  final List<MoneyEntry> entries;
  final List<MoneyEntry> recentEntries;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double safeWeeklySpend;
  final double safeDailySpend;
  final TextEditingController moneyNoteController;
  final String moneyNote;
  final ValueChanged<String> onMoneyNoteChanged;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final ValueChanged<MoneyEntry> onDeleteEntry;

  const DashboardView({
    super.key,
    required this.entries,
    required this.recentEntries,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.safeWeeklySpend,
    required this.safeDailySpend,
    required this.moneyNoteController,
    required this.moneyNote,
    required this.onMoneyNoteChanged,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 18,
            vertical: isWide ? 28 : 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(
                    balance: balance,
                    safeWeeklySpend: safeWeeklySpend,
                    onAddIncome: onAddIncome,
                    onAddExpense: onAddExpense,
                  ),
                  const SizedBox(height: 18),
                  _BudgetProgressCard(
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    balance: balance,
                  ),
                  const SizedBox(height: 26),
                  _MetricGrid(
                    isWide: isWide,
                    children: [
                      MetricCard(
                        label: 'Income',
                        amount: totalIncome,
                        icon: Icons.trending_up_rounded,
                        color: AppColors.forest,
                        helper: 'Money in',
                      ),
                      MetricCard(
                        label: 'Expenses',
                        amount: totalExpense,
                        icon: Icons.trending_down_rounded,
                        color: AppColors.coral,
                        helper: 'Money out',
                      ),
                      MetricCard(
                        label: 'Balance',
                        amount: balance,
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.blue,
                        helper: 'Available now',
                      ),
                      MetricCard(
                        label: 'Safe to spend',
                        amount: safeWeeklySpend,
                        icon: Icons.verified_rounded,
                        color: AppColors.amber,
                        helper: 'Weekly guide',
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _RecentTransactions(
                            recentEntries: recentEntries,
                            onAddExpense: onAddExpense,
                            onDeleteEntry: onDeleteEntry,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _WeeklySummaryCard(
                                totalIncome: totalIncome,
                                totalExpense: totalExpense,
                                balance: balance,
                                safeWeeklySpend: safeWeeklySpend,
                              ),
                              const SizedBox(height: 18),
                              _MoneyNotesCard(
                                controller: moneyNoteController,
                                note: moneyNote,
                                onChanged: onMoneyNoteChanged,
                              ),
                              const SizedBox(height: 18),
                              _SpendingCoach(
                                entries: entries,
                                balance: balance,
                                safeDailySpend: safeDailySpend,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _RecentTransactions(
                      recentEntries: recentEntries,
                      onAddExpense: onAddExpense,
                      onDeleteEntry: onDeleteEntry,
                    ),
                    const SizedBox(height: 18),
                    _WeeklySummaryCard(
                      totalIncome: totalIncome,
                      totalExpense: totalExpense,
                      balance: balance,
                      safeWeeklySpend: safeWeeklySpend,
                    ),
                    const SizedBox(height: 18),
                    _MoneyNotesCard(
                      controller: moneyNoteController,
                      note: moneyNote,
                      onChanged: onMoneyNoteChanged,
                    ),
                    const SizedBox(height: 18),
                    _SpendingCoach(
                      entries: entries,
                      balance: balance,
                      safeDailySpend: safeDailySpend,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const _BudgetProgressCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalIncome == 0
        ? 0.0
        : (totalExpense / totalIncome).clamp(0.0, 1.0);
    final progressColor = progress >= 0.9
        ? AppColors.coral
        : progress >= 0.65
        ? AppColors.amber
        : AppColors.forest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'A quick pulse on weekly spending.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              color: progressColor,
              backgroundColor: AppColors.border,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ProgressPill(
                  icon: Icons.payments_rounded,
                  label: 'Income ${money(totalIncome)}',
                  color: AppColors.forest,
                ),
                _ProgressPill(
                  icon: Icons.receipt_long_rounded,
                  label: 'Spent ${money(totalExpense)}',
                  color: AppColors.coral,
                ),
                _ProgressPill(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Left ${money(balance)}',
                  color: AppColors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double safeWeeklySpend;

  const _WeeklySummaryCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.safeWeeklySpend,
  });

  String get summaryMessage {
    if (balance > 0) {
      return "You're on track this week.";
    }
    if (balance == 0) {
      return 'You are balanced, but be careful with extra spending.';
    }
    return 'Your expenses are higher than your income this week.';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = balance < 0
        ? AppColors.coral
        : balance == 0
        ? AppColors.amber
        : AppColors.forest;
    final progress = totalIncome == 0
        ? 0.0
        : (totalExpense / totalIncome).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_view_week_rounded,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Weekly Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              summaryMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: statusColor,
              backgroundColor: AppColors.border,
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.south_west_rounded,
              label: 'Total income',
              value: money(totalIncome),
              color: AppColors.forest,
            ),
            _SummaryRow(
              icon: Icons.north_east_rounded,
              label: 'Total expenses',
              value: money(totalExpense),
              color: AppColors.coral,
            ),
            _SummaryRow(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Current balance',
              value: money(balance),
              color: AppColors.blue,
            ),
            _SummaryRow(
              icon: Icons.verified_rounded,
              label: 'Safe to spend',
              value: money(safeWeeklySpend),
              color: AppColors.amber,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyNotesCard extends StatelessWidget {
  final TextEditingController controller;
  final String note;
  final ValueChanged<String> onChanged;

  const _MoneyNotesCard({
    required this.controller,
    required this.note,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasNote = note.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.coralSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Money Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Keep one short reminder for this week.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasNote)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No note yet. Add a reminder like “save for books” or “limit takeout.”',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedInk,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasNote) const SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: onChanged,
              maxLength: 120,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: "This week's note",
                hintText: 'Example: Keep dining out under \$40.',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ProgressPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final double balance;
  final double safeWeeklySpend;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _DashboardHeader({
    required this.balance,
    required this.safeWeeklySpend,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ink, AppColors.forest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: .18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 22,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UniSpend',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Know what you can spend.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Current balance',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money(balance),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safe-to-spend this week',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        money(safeWeeklySpend),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.mintStrong,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAddIncome,
                        icon: const Icon(Icons.south_west_rounded),
                        label: const Text('Income'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddExpense,
                        icon: const Icon(Icons.north_east_rounded),
                        label: const Text('Expense'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.34),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _MetricGrid({required this.isWide, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      childAspectRatio: isWide ? 1.45 : 1.08,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<MoneyEntry> recentEntries;
  final VoidCallback onAddExpense;
  final ValueChanged<MoneyEntry> onDeleteEntry;

  const _RecentTransactions({
    required this.recentEntries,
    required this.onAddExpense,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent transactions',
          actionLabel: recentEntries.isEmpty ? null : 'Add expense',
          onAction: recentEntries.isEmpty ? null : onAddExpense,
        ),
        const SizedBox(height: 10),
        if (recentEntries.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No transactions yet',
            message:
                'Add your first income or expense to unlock your student budget dashboard.',
            buttonLabel: 'Add an expense',
            onPressed: onAddExpense,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = recentEntries[index];
              return TransactionTile(
                entry: entry,
                onDelete: () => onDeleteEntry(entry),
              );
            },
          ),
      ],
    );
  }
}

class _SpendingCoach extends StatelessWidget {
  final List<MoneyEntry> entries;
  final double balance;
  final double safeDailySpend;

  const _SpendingCoach({
    required this.entries,
    required this.balance,
    required this.safeDailySpend,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = entries.isNotEmpty;
    final title = balance >= 0 ? 'On track' : 'Needs attention';
    final message = hasData
        ? 'Your daily guide is ${money(safeDailySpend)}. Keep recurring costs visible before weekend spending.'
        : 'Once you add activity, UniSpend will turn your balance into simple daily and weekly spending signals.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Student spending coach',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: balance >= 0 ? AppColors.forest : AppColors.coral,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedInk,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetView extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double safeWeeklySpend;
  final VoidCallback onAddExpense;

  const BudgetView({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.safeWeeklySpend,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalIncome == 0
        ? 0.0
        : (totalExpense / totalIncome).clamp(0.0, 1.0);

    return _PageScaffold(
      title: 'Budget',
      subtitle: 'Track how much of your money is already spoken for.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly envelope',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                    color: progress > 0.75 ? AppColors.coral : AppColors.forest,
                    backgroundColor: AppColors.border,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% of income spent',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Balance ${money(balance)} - Weekly safe-to-spend ${money(safeWeeklySpend)}',
                    style: const TextStyle(color: AppColors.mutedInk),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          EmptyState(
            icon: Icons.tune_rounded,
            title: 'Budget categories are ready for your next step',
            message:
                'For now, UniSpend uses your live income and expenses to estimate a simple safe-to-spend amount.',
            buttonLabel: 'Add expense',
            onPressed: onAddExpense,
          ),
        ],
      ),
    );
  }
}

class ReportsView extends StatelessWidget {
  final List<MoneyEntry> entries;
  final double totalIncome;
  final double totalExpense;

  const ReportsView({
    super.key,
    required this.entries,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Reports',
      subtitle: 'A quick read on your money flow.',
      child: entries.isEmpty
          ? const EmptyState(
              icon: Icons.insights_rounded,
              title: 'No report data yet',
              message:
                  'Add a few transactions and your income-versus-expense report will appear here.',
            )
          : Column(
              children: [
                MetricCard(
                  label: 'Net cash flow',
                  amount: totalIncome - totalExpense,
                  icon: Icons.show_chart_rounded,
                  color: AppColors.blue,
                  helper: 'Income minus expenses',
                ),
                const SizedBox(height: 12),
                MetricCard(
                  label: 'Total tracked',
                  amount: totalIncome + totalExpense,
                  icon: Icons.pie_chart_rounded,
                  color: AppColors.amber,
                  helper: '${entries.length} transactions logged',
                ),
              ],
            ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageScaffold(
      title: 'Profile',
      subtitle: 'Your UniSpend setup.',
      child: EmptyState(
        icon: Icons.person_rounded,
        title: 'Student profile',
        message:
            'Firebase is intentionally not connected yet. Your current session keeps transactions in memory while the frontend takes shape.',
      ),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
