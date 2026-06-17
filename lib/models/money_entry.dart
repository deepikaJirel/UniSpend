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

  factory MoneyEntry.fromJson(Map<String, dynamic> json) {
    return MoneyEntry(
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isIncome: json['isIncome'] as bool? ?? false,
      category: json['category'] as String? ?? 'Other',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
