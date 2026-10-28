import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/month_model.dart';
import '../services/firestore_service.dart';
import 'month_repository.dart';
import 'savings_repository.dart';

class MonthRepositoryImpl extends GetxService implements MonthRepository {
  final _fs = Get.find<FirestoreService>();

  @override
  String currentMonthId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  Future<MonthModel?> getCurrentMonth() async {
    final id = currentMonthId();
    final snap = await _fs.monthDoc(id).get();
    if (!snap.exists) return null;
    return MonthModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<MonthModel?> getMonthById(String monthId) async {
    final snap = await _fs.monthDoc(monthId).get();
    if (!snap.exists) return null;
    return MonthModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<List<MonthModel>> getAllMonths() async {
    final snap = await _fs.userDoc.collection('months').get();
    final list = snap.docs
        .map((d) => MonthModel.fromJson(d.data()))
        .where((m) => m.monthId.isNotEmpty)
        .toList();
    list.sort((a, b) => b.monthId.compareTo(a.monthId)); // newest first
    return list;
  }

  @override
  Future<void> createMonth(double salary) async {
    final now = DateTime.now();
    final id = currentMonthId();
    final month = MonthModel(
      monthId: id,
      month: _monthName(now.month),
      year: now.year,
      salaryAmount: salary,
      salaryAddedDate: DateTime.now(),
      totalExpense: 0,
      remainingBalance: salary,
      createdAt: DateTime.now(),
    );
    await _fs.monthDoc(id).set(month.toJson());
    await _syncSavings(id);
  }

  @override
  Future<void> updateSalary(String monthId, double salary) async {
    final ref = _fs.monthDoc(monthId);
    final snap = await ref.get();
    if (!snap.exists) {
      final parts = monthId.split('-');
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? DateTime.now().month;
      final month = MonthModel(
        monthId: monthId,
        month: _monthName(m),
        year: y,
        salaryAmount: salary,
        salaryAddedDate: DateTime.now(),
        totalExpense: 0,
        remainingBalance: salary,
        createdAt: DateTime.now(),
      );
      await ref.set(month.toJson());
    } else {
      final data = snap.data() as Map<String, dynamic>;
      final totalExpense = (data['totalExpense'] as num? ?? 0.0).toDouble();
      await ref.update({
        'salaryAmount': salary,
        'remainingBalance': salary - totalExpense,
      });
    }
    await _syncSavings(monthId);
  }

  @override
  Future<void> updateTotals(String monthId, double amount) async {
    await _fs.db.runTransaction((tx) async {
      final ref  = _fs.monthDoc(monthId);
      final snap = await tx.get(ref);

      if (!snap.exists) {
        // Month doc missing — create a minimal one so the app doesn't crash
        final parts = monthId.split('-');
        final y = int.tryParse(parts[0]) ?? DateTime.now().year;
        final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().month;
        tx.set(ref, {
          'monthId':          monthId,
          'month':            _monthName(m),
          'year':             y,
          'salaryAmount':     0.0,
          'salaryAddedDate':  Timestamp.fromDate(DateTime.now()),
          'totalExpense':     amount,
          'remainingBalance': -amount,
          'createdAt':        Timestamp.fromDate(DateTime.now()),
        });
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      tx.update(ref, {
        'totalExpense':     (data['totalExpense']     as num? ?? 0) + amount,
        'remainingBalance': (data['remainingBalance'] as num? ?? 0) - amount,
      });
    });
    await _syncSavings(monthId);
  }

  /// Keeps users/{uid}/savings/{monthId} in step with the month's balance.
  Future<void> _syncSavings(String monthId) async {
    final month = await getMonthById(monthId);
    if (month == null) return;
    await Get.find<SavingsRepository>().syncMonth(month);
  }

  String _monthName(int m) => [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m];
}
