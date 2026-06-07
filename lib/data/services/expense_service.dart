import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/expense_model.dart';
import 'firestore_service.dart';
import 'month_service.dart';

class ExpenseService extends GetxService {
  final _fs = Get.find<FirestoreService>();
  final _ms = Get.find<MonthService>();

  Future<void> addExpense(ExpenseModel expense) async {
    final monthId = _ms.currentMonthId();
    final ref     = _fs.expensesCol(monthId).doc();
    final batch   = _fs.db.batch();

    batch.set(ref, expense.toJson());
    await batch.commit();

    // Update totals via transaction
    await _ms.updateTotals(monthId, expense.amount);
  }

  Future<List<ExpenseModel>> getExpenses(String monthId) async {
    final snap = await _fs.expensesCol(monthId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExpenseModel>> getRecentExpenses({int limit = 5}) async {
    final monthId = _ms.currentMonthId();
    final snap    = await _fs.expensesCol(monthId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteExpense(String monthId, String expenseId) async {
    await _fs.expensesCol(monthId).doc(expenseId).delete();
  }
}