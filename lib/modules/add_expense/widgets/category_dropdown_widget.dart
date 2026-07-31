import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/data/models/category_model.dart';
import '../add_expense_controller.dart';
import 'category_chip_widget.dart'; // reuses colorFromHex & categoryIconFor

class CategoryDropdownWidget extends StatelessWidget {
  const CategoryDropdownWidget({super.key});

  static void showManageCategoriesDialog(BuildContext context, AddExpenseController ctrl) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.category_rounded, color: AppColors.accentPurple),
              SizedBox(width: 10),
              Text(
                'Manage Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // List of existing categories
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() {
                      if (ctrl.categories.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No categories found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: ctrl.categories.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, index) {
                          final cat = ctrl.categories[index];
                          final color = colorFromHex(cat.color);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(categoryIconFor(cat.icon), color: color, size: 18),
                            ),
                            title: Text(
                              cat.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Category'),
                                    content: Text('Are you sure you want to delete "${cat.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ctrl.removeCategory(cat);
                                }
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                
                // Add category input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        cursorColor: AppColors.accentPurple,
                        decoration: InputDecoration(
                          hintText: 'New category name...',
                          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.accentPurple, width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final name = textController.text.trim();
                        if (name.isNotEmpty) {
                          await ctrl.addNewCategory(name);
                          textController.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Obx(() {
      return DropdownButtonFormField<CategoryModel>(
        value: ctrl.selectedCategory.value,
        hint: const Row(
          children: [
            Icon(Icons.grid_view_rounded,
                size: 18, color: AppColors.accentPurple),
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
                const BorderSide(color: AppColors.accentPurple, width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.accentPurple,
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