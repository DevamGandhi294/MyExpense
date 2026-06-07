import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/models/month_model.dart';
import 'package:myexpense/data/services/expense_service.dart';
import 'package:myexpense/data/services/month_service.dart';

class HomeController extends GetxController {
  final MonthService _monthService = Get.find<MonthService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  // ── Observables ──────────────────────────────────────────────────────────────
  final Rx<MonthModel?> currentMonth = Rx<MonthModel?>(null);
  final RxList<ExpenseModel> recentExpenses = <ExpenseModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString userName = ''.obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    loadDashboard();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────
  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Use displayName if set, otherwise derive from email
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        userName.value = user.displayName!.split(' ').first;
      } else if (user.email != null) {
        userName.value = user.email!.split('@').first;
      } else {
        userName.value = 'User';
      }
    } else {
      userName.value = 'User';
    }
  }

  // ── Public methods ───────────────────────────────────────────────────────────

  /// Fetches current month summary and recent expenses in parallel.
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _monthService.getCurrentMonth(),
        _expenseService.getRecentExpenses(limit: 5),
      ]);

      currentMonth.value = results[0] as MonthModel?;
      recentExpenses.assignAll(results[1] as List<ExpenseModel>);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Computed getters ─────────────────────────────────────────────────────────

  /// Returns spent percentage clamped between 0–100.
  double get spentPercentage {
    final month = currentMonth.value;
    if (month == null || month.salaryAmount <= 0) return 0;
    final pct = (month.totalExpense / month.salaryAmount) * 100;
    return pct.clamp(0.0, 100.0);
  }

  /// Convenience getters used by widgets.
  double get salary => currentMonth.value?.salaryAmount ?? 0;
  double get totalExpense => currentMonth.value?.totalExpense ?? 0;
  double get remaining => currentMonth.value?.remainingBalance ?? 0;

  /// Current month label e.g. "June 2026".
  String get monthLabel {
    final now = DateTime.now();
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month]} ${now.year}';
  }
}