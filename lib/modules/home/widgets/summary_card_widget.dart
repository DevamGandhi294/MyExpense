import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCardWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isDark; // first card is dark blue

  const SummaryCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    this.isDark = false,
  });

  String _fmt(double v) => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(v);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A237E) : Colors.white;
    final labelColor =
        isDark ? Colors.white.withOpacity(0.75) : Colors.grey.shade500;
    final amountColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final iconBg = isDark
        ? Colors.white.withOpacity(0.15)
        : const Color(0xFFEEF0FF);
    final iconColor = isDark ? Colors.white : const Color(0xFF3949AB);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF1A237E).withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 14),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Amount
          Text(
            _fmt(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}