import 'package:cloud_firestore/cloud_firestore.dart';

class MonthModel {
  final String   monthId;
  final String   month;
  final int      year;
  final double   salaryAmount;
  final DateTime salaryAddedDate;
  final double   totalExpense;
  final double   remainingBalance;
  final DateTime createdAt;

  MonthModel({
    required this.monthId, required this.month, required this.year,
    required this.salaryAmount, required this.salaryAddedDate,
    required this.totalExpense, required this.remainingBalance,
    required this.createdAt,
  });

  factory MonthModel.fromJson(Map<String, dynamic> j) => MonthModel(
    monthId:          j['monthId'],
    month:            j['month'],
    year:             j['year'],
    salaryAmount:     (j['salaryAmount']     as num).toDouble(),
    salaryAddedDate:  (j['salaryAddedDate']  as Timestamp).toDate(),
    totalExpense:     (j['totalExpense']     as num).toDouble(),
    remainingBalance: (j['remainingBalance'] as num).toDouble(),
    createdAt:        (j['createdAt']        as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'monthId':          monthId,
    'month':            month,
    'year':             year,
    'salaryAmount':     salaryAmount,
    'salaryAddedDate':  Timestamp.fromDate(salaryAddedDate),
    'totalExpense':     totalExpense,
    'remainingBalance': remainingBalance,
    'createdAt':        Timestamp.fromDate(createdAt),
  };
}