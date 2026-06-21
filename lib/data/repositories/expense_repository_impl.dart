import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import 'expense_repository.dart';
import 'month_repository.dart';

class ExpenseRepositoryImpl extends GetxService implements ExpenseRepository {
  final _fs = Get.find<FirestoreService>();
  final _mr = Get.find<MonthRepository>();

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final monthId = _mr.currentMonthId();
    final ref = _fs.expensesCol(monthId).doc();
    final batch = _fs.db.batch();

    batch.set(ref, expense.toJson());
    await batch.commit();

    await _mr.updateTotals(monthId, expense.amount);
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String monthId) async {
    final snap = await _fs
        .expensesCol(monthId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 5}) async {
    final monthId = _mr.currentMonthId();
    final snap = await _fs
        .expensesCol(monthId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteExpense(String monthId, String expenseId) async {
    await _fs.expensesCol(monthId).doc(expenseId).delete();
  }
}
