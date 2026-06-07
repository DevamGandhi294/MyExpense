import 'dart:ui';

import 'package:get/get.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/models/month_model.dart';
import 'package:myexpense/data/services/expense_service.dart';
import 'package:myexpense/data/services/month_service.dart';

class MonthlyDetailController extends GetxController {
  final MonthService monthService;
  final ExpenseService expenseService;

  MonthlyDetailController({
    required this.monthService,
    required this.expenseService,
  });

  final currentMonth = Rx<MonthModel?>(null);
  final allExpenses = <ExpenseModel>[].obs;
  final filteredExpenses = <ExpenseModel>[].obs;
  final filterMode = 'category'.obs;
  final isLoading = false.obs;
  final selectedMonthId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonthId.value = monthService.currentMonthId();
    loadMonthDetail();
  }

  Future<void> loadMonthDetail() async {
    try {
      isLoading.value = true;
      final month = await monthService.getCurrentMonth();
      currentMonth.value = month;

      final monthId = selectedMonthId.value;
      final expenses = await expenseService.getExpenses(monthId);
      allExpenses.assignAll(expenses);

      applyFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load month details: ${e.toString()}',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    final sorted = List<ExpenseModel>.from(allExpenses);

    if (filterMode.value == 'date') {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    } else {
      sorted.sort((a, b) => a.category.compareTo(b.category));
    }

    filteredExpenses.assignAll(sorted);
  }

  void toggleFilter(String mode) {
    filterMode.value = mode;
    applyFilter();
  }

  double get remainingBalance => currentMonth.value?.remainingBalance ?? 0;
  double get salaryAmount => currentMonth.value?.salaryAmount ?? 0;
  double get totalExpense => currentMonth.value?.totalExpense ?? 0;
  String get monthTitle =>
      currentMonth.value != null
          ? '${currentMonth.value!.month} ${currentMonth.value!.year}'
          : '';
}