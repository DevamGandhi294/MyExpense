import '../models/month_model.dart';
import '../models/savings_model.dart';

abstract class SavingsRepository {
  /// A month counts as savings once its remaining balance reaches this amount.
  static const double savingsThreshold = 5000;

  Future<List<SavingsModel>> getSavings();
  Future<void> syncMonth(MonthModel month);
}
