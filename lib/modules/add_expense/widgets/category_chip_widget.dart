import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_expense_controller.dart';

/// Maps a category icon string to a Flutter [IconData].
IconData categoryIconFor(String icon) {
  switch (icon.toLowerCase()) {
    case 'food':          return Icons.restaurant;
    case 'transport':     return Icons.directions_bus;
    case 'shopping':      return Icons.shopping_bag;
    case 'entertainment': return Icons.movie;
    case 'groceries':     return Icons.local_grocery_store;
    case 'housing':       return Icons.home;
    case 'health':        return Icons.favorite;
    default:              return Icons.category;
  }
}

/// Converts a hex color string (e.g. "#FF6B6B") to a Flutter [Color].
Color colorFromHex(String hex) {
  try {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return const Color(0xFF6C5CE7);
  }
}

class CategoryChipWidget extends StatelessWidget {
  /// Names of the categories to surface as quick-select chips.
  final List<String> quickCategories;

  const CategoryChipWidget({
    super.key,
    this.quickCategories = const ['Food & Dining', 'Transport', 'Shopping'],
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Obx(() {
      // Filter the full list to only the quick-select names
      final chips = ctrl.categories.where((c) {
        return quickCategories
            .map((q) => q.toLowerCase())
            .contains(c.name.toLowerCase());
      }).toList();

      if (chips.isEmpty) return const SizedBox(height: 36);

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((cat) {
          final isSelected =
              ctrl.selectedCategory.value?.name == cat.name;
          final catColor = colorFromHex(cat.color);

          return GestureDetector(
            onTap: () => ctrl.selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C5CE7)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoryIconFor(cat.icon),
                    size: 15,
                    color: isSelected ? Colors.white : catColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name.split(' ').first, // "Food", "Transport" etc.
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}