import '../models/month_model.dart';

abstract class MonthRepository {
  String currentMonthId();
  Future<MonthModel?> getCurrentMonth();
  Future<MonthModel?> getMonthById(String monthId);
  Future<void> createMonth(double salary);
  Future<void> updateSalary(String monthId, double salary);
  Future<void> updateTotals(String monthId, double amount);
}
