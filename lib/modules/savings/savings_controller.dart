import 'package:get/get.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/models/month_model.dart';
import '../../data/models/savings_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/month_repository.dart';
import '../../data/repositories/savings_repository.dart';
import '../../shared/utils/app_toast.dart';

class SavingsController extends GetxController {
  final MonthRepository _monthRepository = Get.find<MonthRepository>();
  final ExpenseRepository _expenseRepository = Get.find<ExpenseRepository>();
  final SavingsRepository _savingsRepository = Get.find<SavingsRepository>();

  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<MonthModel> months = <MonthModel>[].obs;
  final RxList<SavingsModel> savings = <SavingsModel>[].obs;
  final RxList<ExpenseModel> allExpenses = <ExpenseModel>[].obs;
  final RxList<DebtModel> debts = <DebtModel>[].obs;
  final RxBool isLoading = true.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadSavingsData();
  }

  // ── Public methods ───────────────────────────────────────────────────────────
  Future<void> loadSavingsData() async {
    try {
      isLoading.value = true;
      final monthList = await _monthRepository.getAllMonths();

      // Backfill savings for months created before savings existed
      await Future.wait(monthList.map(_savingsRepository.syncMonth));

      loadDebts();
      final results = await Future.wait([
        _savingsRepository.getSavings(),
        Future.wait(monthList.map((m) => _expenseRepository.getExpenses(m.monthId))),
      ]);

      months.assignAll(monthList);
      savings.assignAll(results[0] as List<SavingsModel>);
      allExpenses.assignAll(
        (results[1] as List<List<ExpenseModel>>).expand((e) => e),
      );
    } catch (e) {
      AppToast.error('Error', 'Failed to load savings: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDebts() async {
    try {
      debts.assignAll(await Get.find<DebtRepository>().getDebts());
    } catch (_) {
      // Lend & Borrow summary is optional on this page
    }
  }

  double _pendingDebt(String type) => debts
      .where((d) => d.type == type && !d.isSettled)
      .fold(0.0, (sum, d) => sum + d.amount);

  /// Money people still have to give me.
  double get toReceive => _pendingDebt(DebtModel.lent);

  /// Money I still have to give people.
  double get toPay => _pendingDebt(DebtModel.borrowed);

  // ── Computed states ──────────────────────────────────────────────────────────
  double get totalIncome => months.fold(0.0, (sum, m) => sum + m.salaryAmount);

  double get totalSpent => allExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Income minus spending across every month.
  double get overallBalance => totalIncome - totalSpent;

  /// Saved amount for one month (salary minus that month's spending).
  double savedIn(MonthModel m) => m.salaryAmount - m.totalExpense;

  /// Months with a salary set, newest first.
  List<MonthModel> get monthsWithSalary =>
      months.where((m) => m.salaryAmount > 0).toList();

  /// Overall savings: sum of every month's saved amount.
  double get totalSaved =>
      monthsWithSalary.fold(0.0, (sum, m) => sum + savedIn(m));

  /// Whether the month reached the savings goal (stored in savings collection).
  bool reachedGoal(MonthModel m) => savings.any((s) => s.monthId == m.monthId);

  /// Category totals across all months, highest first.
  List<MapEntry<String, double>> get overallCategoryExpenses {
    final map = <String, double>{};
    for (final exp in allExpenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.amount;
    }
    final list = map.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  int countFor(String category) =>
      allExpenses.where((e) => e.category == category).length;
}
