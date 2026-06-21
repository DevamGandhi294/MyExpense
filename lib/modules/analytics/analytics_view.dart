import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/app_loader.dart';
import '../../shared/widgets/common_sliver_app_bar.dart';
import '../home/widgets/transaction_tile_widget.dart';
import 'analytics_controller.dart';
import 'widgets/category_donut_widget.dart';
import 'widgets/daily_bar_chart_widget.dart';
import 'widgets/month_selector_widget.dart';
import 'widgets/spending_summary_card.dart';
import 'widgets/top_categories_widget.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentPurple,
          onRefresh: controller.loadAnalyticsData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Logo header
              const CommonSliverAppBar(
                showLogo: true,
              ),

              // Month switcher
              const SliverToBoxAdapter(
                child: MonthSelectorWidget(),
              ),

              // Main content (dependent on loading)
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: AppLoader(size: 80)),
                    );
                  }

                  final recentExpenses = controller.expenses.take(5).toList();

                  return Column(
                    children: [
                      // Salary / Spent / Remaining card
                      const SpendingSummaryCard(),

                      // Daily Bar Chart
                      const DailyBarChartWidget(),

                      // Category Pie Chart
                      const CategoryDonutWidget(),

                      // Top Categories List
                      const TopCategoriesWidget(),

                      // Recent Transactions header
                      Padding(
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
                            if (recentExpenses.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.MONTHLY_DETAIL,
                                    arguments: controller.monthId,
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
                      ),

                      // Transactions list
                      if (recentExpenses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions this month',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: recentExpenses
                                .map((e) => TransactionTileWidget(expense: e))
                                .toList(),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}