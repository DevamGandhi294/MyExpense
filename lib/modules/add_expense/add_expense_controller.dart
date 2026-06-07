import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/models/category_model.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/services/category_service.dart';
import 'package:myexpense/data/services/expense_service.dart';
import 'package:myexpense/modules/home/home_controller.dart';

class AddExpenseController extends GetxController {
  final _expenseService  = Get.find<ExpenseService>();
  final _categoryService = Get.find<CategoryService>();

  // ── Observables ──────────────────────────────────────────────────────────
  final amount           = 0.0.obs;
  final title            = ''.obs;
  final selectedCategory = Rx<CategoryModel?>(null);
  final selectedDate     = DateTime.now().obs;
  final note             = ''.obs;
  final isLoading        = false.obs;
  final categories       = <CategoryModel>[].obs;

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
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
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
            primary: Color(0xFF6C5CE7),
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
      Get.snackbar(
        'Missing title',
        'Please enter what you spent on.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (amount.value <= 0) {
      Get.snackbar(
        'Invalid amount',
        'Please enter an amount greater than zero.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
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

      Get.snackbar(
        'Expense saved!',
        '₹${amount.value.toStringAsFixed(2)} added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6C5CE7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Save failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }
}