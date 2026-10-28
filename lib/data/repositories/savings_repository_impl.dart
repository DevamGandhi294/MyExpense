import 'package:get/get.dart';
import '../models/month_model.dart';
import '../models/savings_model.dart';
import '../services/firestore_service.dart';
import 'savings_repository.dart';

class SavingsRepositoryImpl extends GetxService implements SavingsRepository {
  final _fs = Get.find<FirestoreService>();

  @override
  Future<List<SavingsModel>> getSavings() async {
    final snap = await _fs.savingsCol.get();
    final list = snap.docs
        .map((d) => SavingsModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.monthId.compareTo(a.monthId)); // newest first
    return list;
  }

  /// Adds the month to savings when it saved >= threshold, otherwise removes it.
  @override
  Future<void> syncMonth(MonthModel month) async {
    final ref = _fs.savingsCol.doc(month.monthId);
    final saved = month.salaryAmount - month.totalExpense;

    if (month.salaryAmount > 0 && saved >= SavingsRepository.savingsThreshold) {
      await ref.set(SavingsModel(
        monthId: month.monthId,
        month: month.month,
        year: month.year,
        salaryAmount: month.salaryAmount,
        totalExpense: month.totalExpense,
        savedAmount: saved,
        updatedAt: DateTime.now(),
      ).toJson());
    } else {
      await ref.delete();
    }
  }
}
