import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/app/theme/app_colors.dart';

class SummaryCardWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isDark;
  final VoidCallback? onTap;

  const SummaryCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    this.isDark = false,
    this.onTap,
  });

  String _fmt(double v) => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(v);

  @override
  Widget build(BuildContext context) {
    final labelColor =
        isDark ? Colors.white.withOpacity(0.75) : Colors.grey.shade500;
    final amountColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final iconBg = isDark
        ? Colors.white.withOpacity(0.15)
        : const Color(0xFFF1EEFC);
    final iconColor = isDark ? Colors.white : AppColors.accentPurple;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3D35C4),
                  AppColors.accentPurple,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: isDark
            ? null
            : Border.all(
                color: const Color(0x0F000000),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.accentPurple.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    ),
  );
}
}