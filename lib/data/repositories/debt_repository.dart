import '../models/debt_model.dart';

abstract class DebtRepository {
  Future<List<DebtModel>> getDebts();
  Future<void> addDebt(DebtModel debt);
  Future<void> setSettled(String id, bool settled);
  Future<void> deleteDebt(String id);
}
