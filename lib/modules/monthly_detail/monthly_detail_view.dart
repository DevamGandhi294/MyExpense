import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/app/theme/app_dimensions.dart';
import 'package:myexpense/app/theme/app_text_styles.dart';
import 'package:myexpense/data/models/expense_model.dart';
import 'package:myexpense/modules/monthly_detail/widgets/balance_banner_widget.dart';
import 'package:myexpense/modules/monthly_detail/widgets/filter_toggle_widget.dart';
import 'monthly_detail_controller.dart';

class MonthlyDetailView extends GetView<MonthlyDetailController> {
  const MonthlyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.neutral900,
            size: AppDimensions.iconMD,
          ),
        ),
        title: Obx(
          () => Text(
            controller.monthTitle,
            style: AppTextStyles.headlineMedium,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceMD),
            child: CircleAvatar(
              radius: AppDimensions.avatarSizeSM / 2,
              backgroundColor: AppColors.primary300,
              child: Text(
                'AJ',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: BalanceBannerWidget(
                remainingBalance: controller.remainingBalance,
                salaryAmount: controller.salaryAmount,
                totalExpense: controller.totalExpense,
              ),
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
                    FilterToggleWidget(
                      filterMode: controller.filterMode.value,
                      onToggle: controller.toggleFilter,
                    ),
                  ],
                ),
              ),
            ),
            _buildExpenseList(),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spaceXXL),
            ),
          ],
        );
      }),
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
    final expenses = controller.filteredExpenses;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          color: AppColors.white,
          child: _ExpenseListTile(
            expense: expenses[index],
            showDivider: index != expenses.length - 1,
          ),
        ),
        childCount: expenses.length,
      ),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool showDivider;

  const _ExpenseListTile({
    required this.expense,
    this.showDivider = true,
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      '${expense.category} · ${_formatDate(expense.date)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text(
                _formatAmount(expense.amount),
                style: AppTextStyles.amountExpense.copyWith(fontSize: 14),
                textAlign: TextAlign.right,
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
    );
  }
}