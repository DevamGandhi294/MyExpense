import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/data/models/category_model.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/repositories/category_repository.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/shared/utils/app_toast.dart';

class AddExpenseController extends GetxController {
  final _expenseService = Get.find<ExpenseRepository>();
  final _categoryService = Get.find<CategoryRepository>();

  // ── Observables ──────────────────────────────────────────────────────────
  final amount           = 0.0.obs;
  final title            = ''.obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedDate     = DateTime.now().obs;
  final note             = ''.obs;
  final isLoading        = false.obs;
  final categories       = <CategoryModel>[].obs;
  final isAmountTextEmpty = true.obs;

  // Text-editing controllers so the view can drive them
  final amountController = TextEditingController();
  final titleController  = TextEditingController();
  final noteController   = TextEditingController();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadCategories();

    // Keep `amount` in sync with whatever the user types
    amountController.addListener(() {
      final text = amountController.text.trim();
      amount.value = double.tryParse(text) ?? 0.0;
      isAmountTextEmpty.value = text.isEmpty;
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    titleController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  Future<void> _loadCategories() async {
    try {
      final list = await _categoryService.getCategories();
      categories.assignAll(list);
    } catch (e) {
      AppToast.error('Error', 'Failed to load categories: $e');
    }
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Quick-select a category from the chip row.
  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  /// Open the system date-picker and update [selectedDate].
  Future<void> openDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accentPurple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedDate.value = picked;
  }

  /// Validate, persist, and navigate back.
  Future<void> saveExpense() async {
    // ── Validation ──────────────────────────────────────────────────────────
    final currentTitle = titleController.text.trim();
    final currentNote  = noteController.text.trim();

    if (currentTitle.isEmpty) {
      AppToast.warning('Missing title', 'Please enter what you spent on.');
      return;
    }

    if (amount.value <= 0) {
      AppToast.warning('Invalid amount', 'Please enter an amount greater than zero.');
      return;
    }

    // ── Persist ─────────────────────────────────────────────────────────────
    isLoading.value = true;
    try {
      final expense = ExpenseModel(
        id:        '',                           // Firestore will assign
        title:     currentTitle,
        amount:    amount.value,
        category:  selectedCategory.value?.name ?? 'Uncategorized',
        note:      currentNote,
        date:      selectedDate.value,
        createdAt: DateTime.now(),
      );

      await _expenseService.addExpense(expense);

      // Refresh home dashboard if the controller is already registered
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboard();
      }

      AppToast.success('Expense saved successfully.');

      Get.back();
    } catch (e) {
      AppToast.error('Save failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}