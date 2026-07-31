import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpenses(String monthId);
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 5});
  Future<void> deleteExpense(String monthId, ExpenseModel expense);
  Future<void> updateExpense(String monthId, ExpenseModel expense, double oldAmount);
}
