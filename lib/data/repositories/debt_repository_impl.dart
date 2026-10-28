import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/debt_model.dart';
import '../services/firestore_service.dart';
import 'debt_repository.dart';

class DebtRepositoryImpl extends GetxService implements DebtRepository {
  final _fs = Get.find<FirestoreService>();

  @override
  Future<List<DebtModel>> getDebts() async {
    final snap = await _fs.debtsCol.get();
    final list = snap.docs
        .map((d) => DebtModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return list;
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    final ref = _fs.debtsCol.doc();
    await ref.set(DebtModel(
      id: ref.id,
      type: debt.type,
      personName: debt.personName,
      amount: debt.amount,
      date: debt.date,
      dueDate: debt.dueDate,
      note: debt.note,
      isSettled: false,
      createdAt: DateTime.now(),
    ).toJson());
  }

  @override
  Future<void> setSettled(String id, bool settled) async {
    await _fs.debtsCol.doc(id).update({
      'isSettled': settled,
      'settledDate': settled ? Timestamp.fromDate(DateTime.now()) : null,
    });
  }

  @override
  Future<void> deleteDebt(String id) async {
    await _fs.debtsCol.doc(id).delete();
  }
}
