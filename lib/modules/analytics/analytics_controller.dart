import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/month_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/month_repository.dart';
import '../../shared/utils/app_toast.dart';
import '../../shared/utils/salary_dialog_helper.dart';

class AnalyticsController extends GetxController {
  final MonthRepository _monthRepository = Get.find<MonthRepository>();

  void editSalary() {
    SalaryDialogHelper.showEditSalaryDialog(
      monthId: monthId,
      currentSalary: salary,
      onSuccess: () => loadAnalyticsData(),
    );
  }
  final ExpenseRepository _expenseRepository = Get.find<ExpenseRepository>();

  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<DateTime> availableMonths = <DateTime>[].obs;
  final RxInt selectedMonthIndex = 0.obs; // index in availableMonths
  final Rx<MonthModel?> selectedMonthModel = Rx<MonthModel?>(null);
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isFullMonthView = false.obs; // false = Last 7 Days, true = Full Month
  final RxBool showAllCategories = false.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _generateMonths();
    loadAnalyticsData();
    _loadAllMonths();
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  void _generateMonths() {
    final now = DateTime.now();
    final list = <DateTime>[];
    for (int i = 0; i < 4; i++) {
      int year = now.year;
      int month = now.month - i;
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      list.add(DateTime(year, month));
    }
    availableMonths.assignAll(list);
  }

  /// Extends the selector with every month stored in Firestore.
  Future<void> _loadAllMonths() async {
    try {
      final stored = await _monthRepository.getAllMonths();
      final selected = selectedMonthDate;
      final set = <DateTime>{...availableMonths};
      for (final m in stored) {
        final parts = m.monthId.split('-');
        final y = int.tryParse(parts[0]);
        final mo = int.tryParse(parts.length > 1 ? parts[1] : '');
        if (y != null && mo != null) set.add(DateTime(y, mo));
      }
      final list = set.toList()..sort((a, b) => b.compareTo(a)); // newest first
      availableMonths.assignAll(list);
      selectedMonthIndex.value = list.indexOf(selected);
    } catch (_) {
      // Keep the default range if this fails
    }
  }

  // ── Public methods ───────────────────────────────────────────────────────────
  DateTime get selectedMonthDate => availableMonths[selectedMonthIndex.value];

  String get monthId {
    final d = selectedMonthDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  String get monthTitle {
    final d = selectedMonthDate;
    return DateFormat('MMMM yyyy').format(d);
  }

  void previousMonth() {
    if (selectedMonthIndex.value < availableMonths.length - 1) {
      selectedMonthIndex.value++;
      loadAnalyticsData();
    }
  }

  void nextMonth() {
    if (selectedMonthIndex.value > 0) {
      selectedMonthIndex.value--;
      loadAnalyticsData();
    }
  }

  bool get hasPreviousMonth => selectedMonthIndex.value < availableMonths.length - 1;
  bool get hasNextMonth => selectedMonthIndex.value > 0;

  Future<void> loadAnalyticsData() async {
    try {
      isLoading.value = true;
      final mId = monthId;

      final results = await Future.wait([
        _monthRepository.getMonthById(mId),
        _expenseRepository.getExpenses(mId),
      ]);

      selectedMonthModel.value = results[0] as MonthModel?;
      expenses.assignAll(results[1] as List<ExpenseModel>);
    } catch (e) {
      AppToast.error('Error', 'Failed to load analytics: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Computed states ──────────────────────────────────────────────────────────
  double get salary => selectedMonthModel.value?.salaryAmount ?? 0.0;
  
  double get totalSpent {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get remaining {
    final s = salary;
    if (s <= 0) return 0.0;
    return s - totalSpent;
  }

  /// Maps category name to total spent in that category
  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final exp in expenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.amount;
    }
    return map;
  }

  /// Sorted category entries (highest spending first)
  List<MapEntry<String, double>> get sortedCategoryExpenses {
    final list = categoryTotals.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Top 3 categories with their percentages
  List<MapEntry<String, double>> get topCategories {
    final list = sortedCategoryExpenses;
    return list.take(3).toList();
  }

  /// Maps day of the month (1-31) to total spent on that day
  Map<int, double> get dailyTotals {
    final map = <int, double>{};
    for (final exp in expenses) {
      map[exp.date.day] = (map[exp.date.day] ?? 0.0) + exp.amount;
    }
    return map;
  }

  /// Get list of days to display in the bar chart
  List<DateTime> get barChartDays {
    final selectedDate = selectedMonthDate;
    final now = DateTime.now();

    // Check if the selected month is the current month
    final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;

    if (isFullMonthView.value) {
      // Return all days in that month
      final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      return List.generate(daysInMonth, (i) => DateTime(selectedDate.year, selectedDate.month, i + 1));
    } else {
      // Last 7 days view
      if (isCurrentMonth) {
        // Today and the preceding 6 days
        return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
      } else {
        // Last 7 days of that past month
        final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        return List.generate(7, (i) => DateTime(selectedDate.year, selectedDate.month, lastDayOfMonth - 6 + i));
      }
    }
  }
}
