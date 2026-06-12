import 'package:flutter/material.dart';

import '../models/money_entry.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';

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

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            entry.isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: color,
          ),
        ),
        title: Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(entry.category),
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
