import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/data/models/expense_model.dart';

/// Groups expenses by calendar day, newest day first.
List<MapEntry<DateTime, List<ExpenseModel>>> groupExpensesByDay(
    List<ExpenseModel> expenses) {
  final map = <DateTime, List<ExpenseModel>>{};
  for (final e in expenses) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    map.putIfAbsent(day, () => []).add(e);
  }
  final list = map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
  for (final entry in list) {
    entry.value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  return list;
}

/// "Today", "Yesterday", or e.g. "Wed, 14 Oct 2026".
String dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('EEE, dd MMM yyyy').format(day);
}

class DayHeaderWidget extends StatelessWidget {
  final DateTime day;
  final double total;
  final int count;

  const DayHeaderWidget({
    super.key,
    required this.day,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(day),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentPurple,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(day).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel(day),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '$count transaction${count == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '- $amount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.expenseRed,
            ),
          ),
        ],
      ),
    );
  }
}
