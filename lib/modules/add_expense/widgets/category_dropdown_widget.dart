import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/models/category_model.dart';
import '../add_expense_controller.dart';
import 'category_chip_widget.dart'; // reuses colorFromHex & categoryIconFor

class CategoryDropdownWidget extends StatelessWidget {
  const CategoryDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Obx(() {
      return DropdownButtonFormField<CategoryModel>(
        value: ctrl.selectedCategory.value,
        hint: const Row(
          children: [
            Icon(Icons.grid_view_rounded,
                size: 18, color: Color(0xFF6C5CE7)),
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
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF6C5CE7),
        ),
        items: ctrl.categories.map((cat) {
          final color = colorFromHex(cat.color);
          return DropdownMenuItem<CategoryModel>(
            value: cat,
            child: Row(
              children: [
                // Coloured icon square
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(categoryIconFor(cat.icon),
                      color: color, size: 18),
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