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
    id:        j['id'] ?? '',
    title:     j['title'],
    amount:    (j['amount'] as num).toDouble(),
    category:  j['category'],
    note:      j['note'] ?? '',
    date:      (j['date']      as Timestamp).toDate(),
    createdAt: (j['createdAt'] as Timestamp).toDate(),
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