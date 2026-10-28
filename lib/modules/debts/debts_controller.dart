import 'package:get/get.dart';
import '../../data/models/debt_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../shared/utils/app_toast.dart';

class DebtsController extends GetxController {
  final DebtRepository _debtRepository = Get.find<DebtRepository>();

  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<DebtModel> debts = <DebtModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedTab = DebtModel.lent.obs;
  final RxBool showSettled = false.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  // ── Public methods ───────────────────────────────────────────────────────────
  Future<void> loadDebts() async {
    try {
      isLoading.value = true;
      debts.assignAll(await _debtRepository.getDebts());
    } catch (e) {
      AppToast.error('Error', 'Failed to load: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    try {
      await _debtRepository.addDebt(debt);
      AppToast.success('Saved.');
      await loadDebts();
    } catch (e) {
      AppToast.error('Save failed', e.toString());
    }
  }

  Future<void> toggleSettled(DebtModel debt) async {
    try {
      await _debtRepository.setSettled(debt.id, !debt.isSettled);
      await loadDebts();
    } catch (e) {
      AppToast.error('Update failed', e.toString());
    }
  }

  Future<void> deleteDebt(DebtModel debt) async {
    try {
      await _debtRepository.deleteDebt(debt.id);
      await loadDebts();
    } catch (e) {
      AppToast.error('Delete failed', e.toString());
    }
  }

  // ── Computed states ──────────────────────────────────────────────────────────
  double _pending(String type) => debts
      .where((d) => d.type == type && !d.isSettled)
      .fold(0.0, (sum, d) => sum + d.amount);

  /// Money people still have to give me.
  double get toReceive => _pending(DebtModel.lent);

  /// Money I still have to give people.
  double get toPay => _pending(DebtModel.borrowed);

  List<DebtModel> get visibleDebts => debts
      .where((d) => d.type == selectedTab.value)
      .where((d) => showSettled.value || !d.isSettled)
      .toList();
}
