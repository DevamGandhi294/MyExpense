import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsModel {
  final String   monthId;
  final String   month;
  final int      year;
  final double   salaryAmount;
  final double   totalExpense;
  final double   savedAmount;
  final DateTime updatedAt;

  SavingsModel({
    required this.monthId, required this.month, required this.year,
    required this.salaryAmount, required this.totalExpense,
    required this.savedAmount, required this.updatedAt,
  });

  factory SavingsModel.fromJson(Map<String, dynamic> j) => SavingsModel(
    monthId:      j['monthId']      as String? ?? '',
    month:        j['month']        as String? ?? '',
    year:         j['year']         as int?    ?? DateTime.now().year,
    salaryAmount: (j['salaryAmount'] as num?   ?? 0).toDouble(),
    totalExpense: (j['totalExpense'] as num?   ?? 0).toDouble(),
    savedAmount:  (j['savedAmount']  as num?   ?? 0).toDouble(),
    updatedAt:    j['updatedAt']    is Timestamp
                      ? (j['updatedAt'] as Timestamp).toDate()
                      : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'monthId':      monthId,
    'month':        month,
    'year':         year,
    'salaryAmount': salaryAmount,
    'totalExpense': totalExpense,
    'savedAmount':  savedAmount,
    'updatedAt':    Timestamp.fromDate(updatedAt),
  };
}
