import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/data/models/expense_model.dart';

class TransactionTileWidget extends StatelessWidget {
  final ExpenseModel expense;

  const TransactionTileWidget({super.key, required this.expense});

  // ── Category → icon + colour mapping ────────────────────────────────────────
  static const Map<String, _CategoryMeta> _meta = {
    'Food & Dining':   _CategoryMeta(Icons.restaurant_outlined,    Color(0xFFFF7043), Color(0xFFFFF3F0)),
    'Transport':       _CategoryMeta(Icons.local_gas_station_outlined, Color(0xFF42A5F5), Color(0xFFE8F4FD)),
    'Entertainment':   _CategoryMeta(Icons.tv_outlined,             Color(0xFFAB47BC), Color(0xFFF8F0FA)),
    'Groceries':       _CategoryMeta(Icons.shopping_basket_outlined, Color(0xFF26A69A), Color(0xFFE8F5F4)),
    'Health':          _CategoryMeta(Icons.favorite_border,          Color(0xFFEF5350), Color(0xFFFFF0F0)),
    'Shopping':        _CategoryMeta(Icons.shopping_bag_outlined,    Color(0xFFFF7043), Color(0xFFFFF3F0)),
    'Bills':           _CategoryMeta(Icons.receipt_long_outlined,    Color(0xFF78909C), Color(0xFFF0F2F4)),
    'Education':       _CategoryMeta(Icons.school_outlined,          Color(0xFF5C6BC0), Color(0xFFF0F1FB)),
    'Travel':          _CategoryMeta(Icons.flight_outlined,          Color(0xFF29B6F6), Color(0xFFE7F7FE)),
    'Other':           _CategoryMeta(Icons.category_outlined,        Color(0xFF8D6E63), Color(0xFFF5F0EE)),
  };

  _CategoryMeta _resolve() =>
      _meta[expense.category] ?? _meta['Other']!;

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}';
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    final meta = _resolve();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Category icon square ─────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.color, size: 22),
          ),

          const SizedBox(width: 14),

          // ── Title + subtitle ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${expense.category} • ${_formatDate(expense.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Amount (red, right-aligned) ──────────────────────────────
          Text(
            '- ${_fmt(expense.amount)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper data class ────────────────────────────────────────────────────────
class _CategoryMeta {
  final IconData icon;
  final Color color;
  final Color bg;

  const _CategoryMeta(this.icon, this.color, this.bg);
}