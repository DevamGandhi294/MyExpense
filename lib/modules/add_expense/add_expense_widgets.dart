import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/models/category_model.dart';
import 'add_expense_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: map icon string → IconData
// ─────────────────────────────────────────────────────────────────────────────
IconData _iconFor(String icon) {
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

// ─────────────────────────────────────────────────────────────────────────────
// AmountInputWidget
// ─────────────────────────────────────────────────────────────────────────────
class AmountInputWidget extends StatelessWidget {
  const AmountInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Column(
      children: [
        // Label
        const Text(
          'AMOUNT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 10),

        // ₹ + input row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '₹',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(width: 6),
            IntrinsicWidth(
              child: TextField(
                controller: ctrl.amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFCCCCCC),
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFCCCCCC),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.center,
                cursorColor: const Color(0xFF6C5CE7),
                cursorWidth: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryDropdownWidget
// ─────────────────────────────────────────────────────────────────────────────
class CategoryDropdownWidget extends StatelessWidget {
  const CategoryDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Obx(() {
      // Build color map from loaded categories
      Color colorFor(CategoryModel cat) {
        try {
          final hex = cat.color.replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        } catch (_) {
          return const Color(0xFF6C5CE7);
        }
      }

      return DropdownButtonFormField<CategoryModel>(
        value: ctrl.selectedCategory.value,
        hint: const Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF6C5CE7)),
            SizedBox(width: 10),
            Text(
              'Select Category',
              style: TextStyle(color: Color(0xFF999999), fontSize: 14),
            ),
          ],
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6C5CE7)),
        items: ctrl.categories.map((cat) {
          final color = colorFor(cat);
          return DropdownMenuItem<CategoryModel>(
            value: cat,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconFor(cat.icon), color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  cat.name,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF333333)),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (cat) {
          if (cat != null) ctrl.selectCategory(cat);
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryChipWidget
// ─────────────────────────────────────────────────────────────────────────────
class CategoryChipWidget extends StatelessWidget {
  /// Which category names to show as quick-select chips.
  final List<String> quickCategories;

  const CategoryChipWidget({
    super.key,
    this.quickCategories = const ['Food & Dining', 'Transport', 'Shopping'],
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Obx(() {
      // Filter loaded categories to the quick list
      final chips = ctrl.categories
          .where((c) => quickCategories
              .map((q) => q.toLowerCase())
              .contains(c.name.toLowerCase()))
          .toList();

      // Fallback: if categories not loaded yet, show skeleton
      if (chips.isEmpty) {
        return const SizedBox(height: 36);
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((cat) {
          final isSelected =
              ctrl.selectedCategory.value?.name == cat.name;

          Color catColor;
          try {
            final hex = cat.color.replaceAll('#', '');
            catColor = Color(int.parse('FF$hex', radix: 16));
          } catch (_) {
            catColor = const Color(0xFF6C5CE7);
          }

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
                    _iconFor(cat.icon),
                    size: 15,
                    color: isSelected ? Colors.white : catColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // Show only the first word for brevity on chips
                    cat.name.split(' ').first,
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