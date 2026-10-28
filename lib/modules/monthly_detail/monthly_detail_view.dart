import 'package:flutter/material.dart';
import 'package:myexpense/modules/savings/savings_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/app/theme/app_dimensions.dart';
import 'package:myexpense/app/theme/app_text_styles.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/modules/analytics/analytics_controller.dart';
import 'package:myexpense/shared/utils/app_toast.dart';
import 'package:myexpense/modules/monthly_detail/widgets/balance_banner_widget.dart';
import 'package:myexpense/app/routes/app_routes.dart';
import 'package:myexpense/modules/monthly_detail/widgets/filter_toggle_widget.dart';
import 'package:myexpense/shared/widgets/app_loader.dart';
import 'package:myexpense/shared/widgets/common_sliver_app_bar.dart';
import 'package:myexpense/shared/widgets/day_header_widget.dart';
import 'package:myexpense/shared/widgets/app_add_button.dart';
import 'monthly_detail_controller.dart';

class MonthlyDetailView extends GetView<MonthlyDetailController> {
  const MonthlyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      floatingActionButton: AppAddButton(
        tooltip: 'Add expense to this month',
        onPressed: () => Get.toNamed(
          AppRoutes.ADD_EXPENSE,
          arguments: controller.defaultExpenseDate,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          CommonSliverAppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    controller.monthTitle.value,
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: BalanceBannerWidget(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding,
                vertical: AppDimensions.spaceMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Timeline', style: AppTextStyles.headlineSmall),
                  Obx(() => FilterToggleWidget(
                        filterMode: controller.filterMode.value,
                        onToggle: controller.toggleFilter,
                      )),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: AppLoader(size: 90),
                ),
              );
            }
            return _buildExpenseList();
          }),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceXXL),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    if (controller.filteredExpenses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'No expenses this month',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.filterMode.value == 'category') {
      return _buildGroupedList();
    } else {
      return _buildFlatList();
    }
  }

  Widget _buildGroupedList() {
    final grouped = <String, List<ExpenseModel>>{};
    for (final expense in controller.filteredExpenses) {
      grouped.putIfAbsent(expense.category, () => []).add(expense);
    }

    final categories = grouped.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = categories[index];
          final expenses = grouped[category]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.pagePadding,
                  right: AppDimensions.pagePadding,
                  top: AppDimensions.spaceMD,
                  bottom: AppDimensions.spaceXS,
                ),
                child: Text(
                  category.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutral400,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                color: AppColors.white,
                child: Column(
                  children: expenses
                      .map(
                        (e) => _ExpenseListTile(
                          expense: e,
                          showDivider: e != expenses.last,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildFlatList() {
    final days = groupExpensesByDay(controller.filteredExpenses);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final day = days[index];
          final expenses = day.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DayHeaderWidget(
                day: day.key,
                total: expenses.fold(0.0, (s, e) => s + e.amount),
                count: expenses.length,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePadding,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: expenses
                      .map((e) => _ExpenseListTile(
                            expense: e,
                            showDivider: e != expenses.last,
                            showDate: false,
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
        childCount: days.length,
      ),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool showDivider;
  final bool showDate;

  const _ExpenseListTile({
    required this.expense,
    this.showDivider = true,
    this.showDate = true,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat('##,##,##0.00', 'en_IN');
    return '- ₹${formatter.format(amount)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'dining':
        return Icons.restaurant;
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'groceries':
        return Icons.shopping_cart;
      case 'housing':
      case 'rent':
        return Icons.home;
      case 'health':
      case 'fitness':
        return Icons.favorite;
      case 'utilities':
        return Icons.bolt;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'subscriptions':
        return Icons.subscriptions;
      default:
        return Icons.attach_money;
    }
  }

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
    if (Get.isRegistered<SavingsController>()) {
      Get.find<SavingsController>().loadSavingsData();
    }
    if (Get.isRegistered<MonthlyDetailController>()) {
      Get.find<MonthlyDetailController>().loadMonthDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id.isEmpty ? expense.hashCode.toString() : expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade600,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding,
                vertical: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: AppDimensions.categoryIconSize,
                    height: AppDimensions.categoryIconSize,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      size: AppDimensions.iconSM,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          showDate
                              ? '${expense.category} · ${_formatDate(expense.date)}'
                              : [expense.category, if (expense.note.isNotEmpty) expense.note]
                                  .join(' · '),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatAmount(expense.amount),
                        style: AppTextStyles.amountExpense.copyWith(fontSize: 14),
                        textAlign: TextAlign.right,
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
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppDimensions.pagePadding,
                endIndent: AppDimensions.pagePadding,
                color: AppColors.neutral100,
              ),
          ],
        ),
      ),
    );
  }
}
