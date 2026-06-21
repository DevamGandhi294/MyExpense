import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/routes/app_routes.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/modules/add_expense/add_expense_binding.dart';
import 'package:myexpense/modules/add_expense/add_expense_view.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/modules/home/widgets/circular_chart_widget.dart';
import 'package:myexpense/modules/home/widgets/greeting_header_widget.dart';
import 'package:myexpense/modules/home/widgets/summary_card_widget.dart';
import 'package:myexpense/modules/home/widgets/transaction_tile_widget.dart';
import 'package:myexpense/shared/widgets/common_sliver_app_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () => Get.to(
            () => const AddExpenseView(),
            binding: AddExpenseBinding(),
          ),
          backgroundColor: AppColors.accentPurple,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentPurple,
          onRefresh: controller.loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const CommonSliverAppBar(
                showLogo: true,
              ),
              const SliverToBoxAdapter(child: GreetingHeaderWidget()),
              const SliverToBoxAdapter(child: CircularChartWidget()),
              SliverToBoxAdapter(child: _SummaryRow()),
              SliverToBoxAdapter(child: _RecentHeader()),
              SliverToBoxAdapter(child: _TransactionList()),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal sub-widgets
// ─────────────────────────────────────────────────────────────────────────────


/// Horizontal scrollable row of 3 summary cards
class _SummaryRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
          children: [
            SummaryCardWidget(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Salary',
              amount: controller.salary,
              isDark: true,
              onTap: controller.editSalary,
            ),
            SummaryCardWidget(
              icon: Icons.trending_down_rounded,
              label: 'Total Expense',
              amount: controller.totalExpense,
            ),
            SummaryCardWidget(
              icon: Icons.savings_outlined,
              label: 'Remaining Balance',
              amount: controller.remaining,
            ),
          ],
        ),
      );
    });
  }
}

/// "Recent Transactions" heading + "View All" button
class _RecentHeader extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to monthly detail; pass current monthId
                final monthId = controller.currentMonth.value?.monthId;
                Get.toNamed(
                  AppRoutes.MONTHLY_DETAIL,
                  arguments: monthId,
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPurple,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// List of recent transaction tiles
class _TransactionList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      final expenses = controller.recentExpenses;

      if (expenses.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: expenses
              .map((e) => TransactionTileWidget(expense: e))
              .toList(),
        ),
      );
    });
  }
}
