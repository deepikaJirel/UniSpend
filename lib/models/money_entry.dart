class MoneyEntry {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime createdAt;

  MoneyEntry({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
