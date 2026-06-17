import 'package:flutter/material.dart';

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class CategoryCatalog {
  static const expenseCategories = <CategoryData>[
    CategoryData(
      name: 'Groceries',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFF39755C),
      backgroundColor: Color(0xFFE5F3EA),
    ),
    CategoryData(
      name: 'Coffee / Starbucks',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF8B5E3C),
      backgroundColor: Color(0xFFF5EADF),
    ),
    CategoryData(
      name: 'Breakfast',
      icon: Icons.breakfast_dining_rounded,
      color: Color(0xFFB56A2B),
      backgroundColor: Color(0xFFFFEBD8),
    ),
    CategoryData(
      name: 'Lunch',
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFCE7049),
      backgroundColor: Color(0xFFFFE8DF),
    ),
    CategoryData(
      name: 'Dinner',
      icon: Icons.restaurant_rounded,
      color: Color(0xFF7D568C),
      backgroundColor: Color(0xFFF1E7F5),
    ),
    CategoryData(
      name: 'Snacks',
      icon: Icons.cookie_rounded,
      color: Color(0xFFAE7B21),
      backgroundColor: Color(0xFFFFF1D5),
    ),
    CategoryData(
      name: 'Online Orders',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF3F6EA8),
      backgroundColor: Color(0xFFE5EEFA),
    ),
    CategoryData(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFB04F76),
      backgroundColor: Color(0xFFF9E5ED),
    ),
    CategoryData(
      name: 'Rent',
      icon: Icons.home_rounded,
      color: Color(0xFF326D64),
      backgroundColor: Color(0xFFE0F0ED),
    ),
    CategoryData(
      name: 'Transportation',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF376E9E),
      backgroundColor: Color(0xFFE3EFF8),
    ),
    CategoryData(
      name: 'Gas',
      icon: Icons.local_gas_station_rounded,
      color: Color(0xFF65736F),
      backgroundColor: Color(0xFFE9EEEC),
    ),
    CategoryData(
      name: 'Phone Bill',
      icon: Icons.phone_iphone_rounded,
      color: Color(0xFF5964A6),
      backgroundColor: Color(0xFFE9EAF8),
    ),
    CategoryData(
      name: 'Utilities',
      icon: Icons.bolt_rounded,
      color: Color(0xFFA57A18),
      backgroundColor: Color(0xFFFFF2CF),
    ),
    CategoryData(
      name: 'School Supplies',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF3E7193),
      backgroundColor: Color(0xFFE3F0F6),
    ),
    CategoryData(
      name: 'Subscriptions',
      icon: Icons.autorenew_rounded,
      color: Color(0xFF7361A8),
      backgroundColor: Color(0xFFEDE9F8),
    ),
    CategoryData(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFF9A507E),
      backgroundColor: Color(0xFFF6E5EF),
    ),
    CategoryData(
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFC15462),
      backgroundColor: Color(0xFFFBE5E8),
    ),
    CategoryData(
      name: 'Emergency',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFFBC523F),
      backgroundColor: Color(0xFFFFE6E0),
    ),
    CategoryData(
      name: 'Gifts',
      icon: Icons.redeem_rounded,
      color: Color(0xFFB45B73),
      backgroundColor: Color(0xFFF9E5EB),
    ),
    CategoryData(
      name: 'Other Expense',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF66716D),
      backgroundColor: Color(0xFFEAEFED),
    ),
  ];

  static const incomeCategories = <CategoryData>[
    CategoryData(
      name: 'Campus Job',
      icon: Icons.badge_rounded,
      color: Color(0xFF24705F),
      backgroundColor: Color(0xFFDFF2EB),
    ),
    CategoryData(
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF2F755B),
      backgroundColor: Color(0xFFE1F2E9),
    ),
    CategoryData(
      name: 'Tutoring',
      icon: Icons.school_rounded,
      color: Color(0xFF3D7198),
      backgroundColor: Color(0xFFE2EEF7),
    ),
    CategoryData(
      name: 'Scholarship',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFF9B741C),
      backgroundColor: Color(0xFFFFF0CC),
    ),
    CategoryData(
      name: 'Family Support',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFF9D5B73),
      backgroundColor: Color(0xFFF6E6EC),
    ),
    CategoryData(
      name: 'Freelance',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF5264A1),
      backgroundColor: Color(0xFFE7EAF7),
    ),
    CategoryData(
      name: 'Refund',
      icon: Icons.currency_exchange_rounded,
      color: Color(0xFF36776C),
      backgroundColor: Color(0xFFE1F2EE),
    ),
    CategoryData(
      name: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFAF5A72),
      backgroundColor: Color(0xFFF8E4EA),
    ),
    CategoryData(
      name: 'Other Income',
      icon: Icons.add_circle_rounded,
      color: Color(0xFF52746B),
      backgroundColor: Color(0xFFE6F0ED),
    ),
  ];

  static List<CategoryData> forType(bool isIncome) =>
      isIncome ? incomeCategories : expenseCategories;

  static CategoryData find(String name, {required bool isIncome}) {
    final categories = forType(isIncome);
    return categories.firstWhere(
      (category) => category.name == name,
      orElse: () => categories.last,
    );
  }
}
