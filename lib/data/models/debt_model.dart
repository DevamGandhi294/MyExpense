import 'package:cloud_firestore/cloud_firestore.dart';

/// 'lent'     → I gave money, the person must pay me back.
/// 'borrowed' → I took money, I must pay the person back.
class DebtModel {
  static const lent     = 'lent';
  static const borrowed = 'borrowed';

  final String    id;
  final String    type;
  final String    personName;
  final double    amount;
  final DateTime  date;      // date the money was given / taken
  final DateTime? dueDate;   // optional expected return date
  final String    note;
  final bool      isSettled;
  final DateTime? settledDate;
  final DateTime  createdAt;

  DebtModel({
    required this.id, required this.type, required this.personName,
    required this.amount, required this.date, this.dueDate,
    required this.note, required this.isSettled, this.settledDate,
    required this.createdAt,
  });

  bool get isLent => type == lent;

  factory DebtModel.fromJson(Map<String, dynamic> j) => DebtModel(
    id:          j['id']         as String? ?? '',
    type:        j['type']       as String? ?? lent,
    personName:  j['personName'] as String? ?? '',
    amount:      (j['amount']    as num?    ?? 0).toDouble(),
    date:        j['date']        is Timestamp
                     ? (j['date'] as Timestamp).toDate()
                     : DateTime.now(),
    dueDate:     j['dueDate']     is Timestamp
                     ? (j['dueDate'] as Timestamp).toDate()
                     : null,
    note:        j['note']       as String? ?? '',
    isSettled:   j['isSettled']  as bool?   ?? false,
    settledDate: j['settledDate'] is Timestamp
                     ? (j['settledDate'] as Timestamp).toDate()
                     : null,
    createdAt:   j['createdAt']   is Timestamp
                     ? (j['createdAt'] as Timestamp).toDate()
                     : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'type':        type,
    'personName':  personName,
    'amount':      amount,
    'date':        Timestamp.fromDate(date),
    'dueDate':     dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'note':        note,
    'isSettled':   isSettled,
    'settledDate': settledDate != null ? Timestamp.fromDate(settledDate!) : null,
    'createdAt':   Timestamp.fromDate(createdAt),
  };
}
