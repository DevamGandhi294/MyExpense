import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import 'expense_repository.dart';
import 'month_repository.dart';

class ExpenseRepositoryImpl extends GetxService implements ExpenseRepository {
  final _fs = Get.find<FirestoreService>();
  final _mr = Get.find<MonthRepository>();

  String _getWeekId(DateTime date) {
    final day = date.day;
    if (day <= 7) return 'week1';
    if (day <= 14) return 'week2';
    if (day <= 21) return 'week3';
    if (day <= 28) return 'week4';
    return 'week5';
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final monthId = _mr.currentMonthId();
    final weekId = _getWeekId(expense.date);
    final docRef = _fs.expensesCol(monthId).doc(weekId);

    final newId = _fs.expensesCol(monthId).doc().id;
    final expenseWithId = ExpenseModel(
      id: newId,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      date: expense.date,
      createdAt: expense.createdAt,
    );

    await docRef.set({
      'expenses': FieldValue.arrayUnion([expenseWithId.toJson()]),
    }, SetOptions(merge: true));

    await _mr.updateTotals(monthId, expense.amount);
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String monthId) async {
    final snap = await _fs.expensesCol(monthId).get();
    final List<ExpenseModel> allExpenses = [];
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['expenses'] is List) {
        final list = data['expenses'] as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            allExpenses.add(ExpenseModel.fromJson(item));
          }
        }
      }
    }
    allExpenses.sort((a, b) => b.date.compareTo(a.date));
    return allExpenses;
  }

  @override
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 5}) async {
    final monthId = _mr.currentMonthId();
    final allExpenses = await getExpenses(monthId);
    return allExpenses.take(limit).toList();
  }

  @override
  Future<void> deleteExpense(String monthId, ExpenseModel expense) async {
    final weekId = _getWeekId(expense.date);
    final docRef = _fs.expensesCol(monthId).doc(weekId);

    await _fs.db.runTransaction((transaction) async {
      final docSnap = await transaction.get(docRef);
      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>?;
        if (data != null && data['expenses'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (data['expenses'] as List).map((item) => Map<String, dynamic>.from(item as Map)),
          );
          list.removeWhere((item) => item['id'] == expense.id);
          transaction.update(docRef, {'expenses': list});
        }
      }
    });

    await _mr.updateTotals(monthId, -expense.amount);
  }

  @override
  Future<void> updateExpense(String monthId, ExpenseModel expense, double oldAmount) async {
    final newWeekId = _getWeekId(expense.date);
    final newDocRef = _fs.expensesCol(monthId).doc(newWeekId);

    await _fs.db.runTransaction((transaction) async {
      final weekRefs = List.generate(5, (index) => _fs.expensesCol(monthId).doc('week${index + 1}'));
      final snaps = await Future.wait(weekRefs.map((ref) => transaction.get(ref)));

      String? foundOldWeekId;
      Map<String, List<Map<String, dynamic>>> weekData = {};

      for (int i = 0; i < 5; i++) {
        final wId = 'week${i + 1}';
        final snap = snaps[i];
        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>?;
          if (data != null && data['expenses'] is List) {
            final list = List<Map<String, dynamic>>.from(
              (data['expenses'] as List).map((item) => Map<String, dynamic>.from(item as Map)),
            );
            weekData[wId] = list;
            final hasExpense = list.any((item) => item['id'] == expense.id);
            if (hasExpense) {
              foundOldWeekId = wId;
            }
          }
        }
      }

      if (foundOldWeekId != null) {
        if (foundOldWeekId == newWeekId) {
          final list = weekData[newWeekId]!;
          final idx = list.indexWhere((item) => item['id'] == expense.id);
          if (idx != -1) {
            list[idx] = expense.toJson();
          }
          transaction.update(newDocRef, {'expenses': list});
        } else {
          final oldList = weekData[foundOldWeekId]!;
          oldList.removeWhere((item) => item['id'] == expense.id);
          transaction.update(_fs.expensesCol(monthId).doc(foundOldWeekId), {'expenses': oldList});

          final newList = weekData[newWeekId] ?? [];
          newList.add(expense.toJson());
          transaction.set(newDocRef, {'expenses': newList}, SetOptions(merge: true));
        }
      } else {
        final newList = weekData[newWeekId] ?? [];
        newList.add(expense.toJson());
        transaction.set(newDocRef, {'expenses': newList}, SetOptions(merge: true));
      }
    });

    await _mr.updateTotals(monthId, expense.amount - oldAmount);
  }
}
