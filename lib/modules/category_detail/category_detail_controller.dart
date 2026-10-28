import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/month_repository.dart';
import '../../shared/utils/app_toast.dart';

/// Arguments: {'category': String, 'monthId': String?}.
/// Without a monthId the screen shows the category across all months.
class CategoryDetailController extends GetxController {
  final MonthRepository _monthRepository = Get.find<MonthRepository>();
  final ExpenseRepository _expenseRepository = Get.find<ExpenseRepository>();

  late final String category;
  String? monthId;

  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = true.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    category = args['category'] as String? ?? 'Other';
    monthId = args['monthId'] as String?;
    loadData();
  }

  // ── Public methods ───────────────────────────────────────────────────────────
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final ids = monthId != null
          ? [monthId!]
          : (await _monthRepository.getAllMonths()).map((m) => m.monthId).toList();
      final lists = await Future.wait(ids.map(_expenseRepository.getExpenses));
      expenses.assignAll(
        lists.expand((e) => e).where((e) => e.category == category),
      );
    } catch (e) {
      AppToast.error('Error', 'Failed to load category: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Computed states ──────────────────────────────────────────────────────────
  bool get isAllTime => monthId == null;

  String get scopeLabel {
    if (isAllTime) return 'All time';
    final parts = monthId!.split('-');
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(d);
  }

  double get total => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get average => expenses.isEmpty ? 0 : total / expenses.length;

  ExpenseModel? get biggest => expenses.isEmpty
      ? null
      : expenses.reduce((a, b) => a.amount >= b.amount ? a : b);

  /// Totals per month (newest first) — used for the all-time view.
  List<MapEntry<DateTime, double>> get monthlyTotals {
    final map = <DateTime, double>{};
    for (final e in expenses) {
      final key = DateTime(e.date.year, e.date.month);
      map[key] = (map[key] ?? 0) + e.amount;
    }
    return map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
  }

  /// Totals per item title, highest first — shows what exactly the money went on.
  List<MapEntry<String, double>> get titleTotals {
    final map = <String, double>{};
    for (final e in expenses) {
      final key = e.title.trim().isEmpty ? 'Untitled' : e.title.trim();
      map[key] = (map[key] ?? 0) + e.amount;
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
}
