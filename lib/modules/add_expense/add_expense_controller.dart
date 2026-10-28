import 'package:flutter/material.dart';
import 'package:myexpense/modules/savings/savings_controller.dart';
import 'package:myexpense/modules/category_detail/category_detail_controller.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/data/models/category_model.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/repositories/category_repository.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/modules/analytics/analytics_controller.dart';
import 'package:myexpense/modules/monthly_detail/monthly_detail_controller.dart';
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
  final isEditing        = false.obs;
  final quickSelectCategories = <CategoryModel>[].obs;

  ExpenseModel? editingExpense;

  // Text-editing controllers so the view can drive them
  final amountController = TextEditingController();
  final titleController  = TextEditingController();
  final noteController   = TextEditingController();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadCategories();

    if (Get.arguments is ExpenseModel) {
      final expense = Get.arguments as ExpenseModel;
      editingExpense = expense;
      isEditing.value = true;

      // Prefill fields
      amountController.text = expense.amount.toStringAsFixed(0);
      titleController.text = expense.title;
      noteController.text = expense.note;
      selectedDate.value = expense.date;
      amount.value = expense.amount;
      isAmountTextEmpty.value = false;
    } else if (Get.arguments is DateTime) {
      selectedDate.value = Get.arguments as DateTime;
    }

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

      // Assign fallback defaults immediately so UI renders instantly
      final defaults = ['Food & Dining', 'Transport', 'Shopping'];
      final fallbackCats = categories.where((c) => defaults.contains(c.name)).toList();
      quickSelectCategories.assignAll(fallbackCats.take(3));

      // Fetch actual usage data asynchronously in background
      _loadQuickCategories();

      // Select category if editing
      if (isEditing.value && editingExpense != null) {
        final cat = categories.firstWhereOrNull(
          (c) => c.name.toLowerCase() == editingExpense!.category.toLowerCase(),
        );
        if (cat != null) {
          selectedCategory.value = cat;
        }
      }
    } catch (e) {
      AppToast.error('Error', 'Failed to load categories: $e');
    }
  }

  Future<void> _loadQuickCategories() async {
    try {
      final list = await _categoryService.getQuickCategories();
      quickSelectCategories.assignAll(list);
    } catch (_) {
      // Fallback defaults are already set in _loadCategories
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
        id:        isEditing.value ? editingExpense!.id : '',
        title:     currentTitle,
        amount:    amount.value,
        category:  selectedCategory.value?.name ?? 'Uncategorized',
        note:      currentNote,
        date:      selectedDate.value,
        createdAt: isEditing.value ? editingExpense!.createdAt : DateTime.now(),
      );

      if (isEditing.value && editingExpense != null) {
        final originalMonthId = '${editingExpense!.date.year}-${editingExpense!.date.month.toString().padLeft(2, '0')}';
        final newMonthId = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';

        if (originalMonthId != newMonthId) {
          // Date changed to a different month!
          // Delete from old month and add to new month
          await _expenseService.deleteExpense(originalMonthId, editingExpense!);
          await _expenseService.addExpense(expense);
        } else {
          // Same month update
          await _expenseService.updateExpense(originalMonthId, expense, editingExpense!.amount);
        }
      } else {
        await _expenseService.addExpense(expense);
      }

      // Refresh all registered controllers
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboard();
      }
      if (Get.isRegistered<AnalyticsController>()) {
        Get.find<AnalyticsController>().loadAnalyticsData();
      }
      if (Get.isRegistered<CategoryDetailController>()) {
        Get.find<CategoryDetailController>().loadData();
      }
      if (Get.isRegistered<SavingsController>()) {
        Get.find<SavingsController>().loadSavingsData();
      }
      if (Get.isRegistered<MonthlyDetailController>()) {
        Get.find<MonthlyDetailController>().loadMonthDetail();
      }

      AppToast.success(isEditing.value ? 'Expense updated successfully.' : 'Expense saved successfully.');

      Get.back();
    } catch (e) {
      AppToast.error('Save failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewCategory(String name) async {
    if (name.isEmpty) return;

    final exists = categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      AppToast.warning('Duplicate category', 'This category already exists.');
      return;
    }

    final presetColors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
      '#DDA0DD', '#98FB98', '#FFA07A', '#87CEFA', '#F0E68C',
      '#B0C4DE', '#FFD700', '#FF8C00', '#FF1493', '#9400D3',
    ];
    final color = presetColors[DateTime.now().millisecond % presetColors.length];

    final newCat = CategoryModel(
      id: '',
      name: name,
      icon: 'category',
      color: color,
      createdAt: DateTime.now(),
    );

    try {
      await _categoryService.addCategory(newCat);
      await _loadCategories();
      AppToast.success('Category added.');
    } catch (e) {
      AppToast.error('Error', 'Failed to add category: $e');
    }
  }

  Future<void> removeCategory(CategoryModel category) async {
    try {
      await _categoryService.deleteCategory(category.id);

      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = null;
      }

      await _loadCategories();
      AppToast.success('Category deleted.');
    } catch (e) {
      AppToast.error('Error', 'Failed to delete category: $e');
    }
  }
}