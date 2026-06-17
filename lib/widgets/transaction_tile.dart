import 'package:flutter/material.dart';

import '../models/money_entry.dart';
import '../models/category_data.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import 'category_badge.dart';

class TransactionTile extends StatelessWidget {
  final MoneyEntry entry;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = entry.isIncome ? AppColors.forest : AppColors.coral;
    final category = CategoryCatalog.find(
      entry.category,
      isIncome: entry.isIncome,
    );

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CategoryBadge(category: category),
        title: Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(entry.category),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '${entry.isIncome ? '+' : '-'}${money(entry.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Delete transaction',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
