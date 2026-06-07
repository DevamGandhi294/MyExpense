import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/month_model.dart';
import 'firestore_service.dart';

class MonthService extends GetxService {
  final _fs = Get.find<FirestoreService>();

  String currentMonthId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<MonthModel?> getCurrentMonth() async {
    final id   = currentMonthId();
    final snap = await _fs.monthDoc(id).get();
    if (!snap.exists) return null;
    return MonthModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  Future<void> createMonth(double salary) async {
    final now   = DateTime.now();
    final id    = currentMonthId();
    final month = MonthModel(
      monthId:         id,
      month:           _monthName(now.month),
      year:            now.year,
      salaryAmount:    salary,
      salaryAddedDate: DateTime.now(),
      totalExpense:    0,
      remainingBalance: salary,
      createdAt:       DateTime.now(),
    );
    await _fs.monthDoc(id).set(month.toJson());
  }

  // Called inside a Firestore transaction when expense is added
  Future<void> updateTotals(String monthId, double amount) async {
    await _fs.db.runTransaction((tx) async {
      final ref  = _fs.monthDoc(monthId);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;
      tx.update(ref, {
        'totalExpense':    (data['totalExpense']    as num) + amount,
        'remainingBalance':(data['remainingBalance'] as num) - amount,
      });
    });
  }

  String _monthName(int m) => [
    '', 'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ][m];
}