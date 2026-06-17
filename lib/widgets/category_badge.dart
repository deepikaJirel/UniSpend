import 'package:flutter/material.dart';

import '../models/category_data.dart';

class CategoryBadge extends StatelessWidget {
  final CategoryData category;
  final double size;
  final bool selected;

  const CategoryBadge({
    super.key,
    required this.category,
    this.size = 46,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? category.color : category.backgroundColor,
        borderRadius: BorderRadius.circular(size * .32),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: category.color.withValues(alpha: .22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        category.icon,
        color: selected ? Colors.white : category.color,
        size: size * .48,
      ),
    );
  }
}
