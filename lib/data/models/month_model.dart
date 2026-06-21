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
    monthId:          j['monthId']          as String? ?? '',
    month:            j['month']            as String? ?? '',
    year:             j['year']             as int?    ?? DateTime.now().year,
    salaryAmount:     (j['salaryAmount']     as num?   ?? 0).toDouble(),
    salaryAddedDate:  j['salaryAddedDate']  is Timestamp
                          ? (j['salaryAddedDate'] as Timestamp).toDate()
                          : DateTime.now(),
    totalExpense:     (j['totalExpense']     as num?   ?? 0).toDouble(),
    remainingBalance: (j['remainingBalance'] as num?   ?? 0).toDouble(),
    createdAt:        j['createdAt']        is Timestamp
                          ? (j['createdAt'] as Timestamp).toDate()
                          : DateTime.now(),
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