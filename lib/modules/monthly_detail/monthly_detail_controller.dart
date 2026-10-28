import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/models/month_model.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/data/repositories/month_repository.dart';
import 'package:myexpense/shared/utils/app_toast.dart';
import 'package:myexpense/shared/utils/salary_dialog_helper.dart';

class MonthlyDetailController extends GetxController {
  final MonthRepository monthService;
  final ExpenseRepository expenseService;

  MonthlyDetailController({
    required this.monthService,
    required this.expenseService,
  });

  void editSalary() {
    SalaryDialogHelper.showEditSalaryDialog(
      monthId: selectedMonthId.value,
      currentSalary: salaryAmount.value,
      onSuccess: () => loadMonthDetail(),
    );
  }

  final currentMonth      = Rx<MonthModel?>(null);
  final allExpenses       = <ExpenseModel>[].obs;
  final filteredExpenses  = <ExpenseModel>[].obs;
  final filterMode        = 'category'.obs;
  final isLoading         = false.obs;
  final selectedMonthId   = ''.obs;

  // ── Reactive balance values — update independently of isLoading ───────────
  final remainingBalance  = 0.0.obs;
  final salaryAmount      = 0.0.obs;
  final totalExpense      = 0.0.obs;
  final monthTitle        = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Open the month passed by the caller (e.g. a past month from Analytics)
    final arg = Get.arguments;
    selectedMonthId.value = (arg is String && arg.isNotEmpty)
        ? arg
        : monthService.currentMonthId();
    loadMonthDetail();
  }

  Future<void> loadMonthDetail() async {
    try {
      isLoading.value = true;
      final month = await monthService.getMonthById(selectedMonthId.value);
      currentMonth.value = month;

      // Update Rx values immediately so banner reacts without waiting
      remainingBalance.value = month?.remainingBalance ?? 0;
      salaryAmount.value     = month?.salaryAmount     ?? 0;
      totalExpense.value     = month?.totalExpense     ?? 0;
      monthTitle.value       = month != null
          ? '${month.month} ${month.year}'
          : DateFormat('MMMM yyyy').format(defaultExpenseDate);

      final monthId = selectedMonthId.value;
      final expenses = await expenseService.getExpenses(monthId);
      allExpenses.assignAll(expenses);

      applyFilter();
    } catch (e) {
      AppToast.error('Error', 'Failed to load month details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Default date for a new expense added from this screen:
  /// today for the current month, otherwise the last day of the viewed month.
  DateTime get defaultExpenseDate {
    final parts = selectedMonthId.value.split('-');
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts.length > 1 ? parts[1] : '');
    final now = DateTime.now();
    if (y == null || m == null || (y == now.year && m == now.month)) return now;
    return DateTime(y, m + 1, 0);
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
}
