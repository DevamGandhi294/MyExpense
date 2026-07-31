import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/modules/analytics/analytics_controller.dart';
import 'package:myexpense/modules/monthly_detail/monthly_detail_controller.dart';
import 'package:myexpense/shared/utils/app_toast.dart';
import 'package:myexpense/app/routes/app_routes.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/shared/utils/category_utils.dart';

class TransactionTileWidget extends StatelessWidget {
  final ExpenseModel expense;

  const TransactionTileWidget({super.key, required this.expense});

  CategoryMeta _resolve() => CategoryUtils.resolve(expense.category);

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

  Future<void> _deleteTransaction(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final expenseService = Get.find<ExpenseRepository>();
        final monthId = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        await expenseService.deleteExpense(monthId, expense);
        AppToast.success('Transaction deleted');
        
        _reloadAllControllers();
      } catch (e) {
        AppToast.error('Delete failed', e.toString());
      }
    }
  }

  void _reloadAllControllers() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadDashboard();
    }
    if (Get.isRegistered<AnalyticsController>()) {
      Get.find<AnalyticsController>().loadAnalyticsData();
    }
    if (Get.isRegistered<MonthlyDetailController>()) {
      Get.find<MonthlyDetailController>().loadMonthDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _resolve();

    return Dismissible(
      key: Key(expense.id.isEmpty ? expense.hashCode.toString() : expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          final expenseService = Get.find<ExpenseRepository>();
          final monthId = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
          await expenseService.deleteExpense(monthId, expense);
          AppToast.success('Transaction deleted');
          
          _reloadAllControllers();
        } catch (e) {
          AppToast.error('Delete failed', e.toString());
        }
      },
      child: GestureDetector(
        onLongPress: () => _deleteTransaction(context),
        child: Container(
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

              // ── Amount & Actions ─────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '- ${_fmt(expense.amount)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.ADD_EXPENSE,
                      arguments: expense,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: AppColors.accentPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}