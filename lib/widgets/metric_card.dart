import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money_format.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final String? helper;

  const MetricCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                money(amount),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (helper != null) ...[
              const SizedBox(height: 6),
              Text(
                helper!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
