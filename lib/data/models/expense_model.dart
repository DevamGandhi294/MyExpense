import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String   id;
  final String   title;
  final double   amount;
  final String   category;
  final String   note;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id, required this.title, required this.amount,
    required this.category, required this.note,
    required this.date, required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
    id:        j['id']       as String? ?? '',
    title:     j['title']    as String? ?? '',
    amount:    (j['amount']  as num?    ?? 0).toDouble(),
    category:  j['category'] as String? ?? 'Uncategorized',
    note:      j['note']     as String? ?? '',
    date:      j['date']      is Timestamp
                  ? (j['date'] as Timestamp).toDate()
                  : DateTime.now(),
    createdAt: j['createdAt'] is Timestamp
                  ? (j['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':        id,
    'title':     title,
    'amount':    amount,
    'category':  category,
    'note':      note,
    'date':      Timestamp.fromDate(date),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}