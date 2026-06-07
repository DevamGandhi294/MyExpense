import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/routes/app_routes.dart';
import 'package:myexpense/modules/home/home_controller.dart';
import 'package:myexpense/modules/home/widgets/circular_chart_widget.dart';
import 'package:myexpense/modules/home/widgets/greeting_header_widget.dart';
import 'package:myexpense/modules/home/widgets/summary_card_widget.dart';
import 'package:myexpense/modules/home/widgets/transaction_tile_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ── Bottom Navigation Bar ──────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.ADD_EXPENSE),
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A237E),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF1A237E),
            onRefresh: controller.loadDashboard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App brand header ────────────────────────────────────
                SliverToBoxAdapter(child: _AppHeader()),

                // ── Greeting ────────────────────────────────────────────
                const SliverToBoxAdapter(child: GreetingHeaderWidget()),

                // ── Donut chart card ─────────────────────────────────────
                const SliverToBoxAdapter(child: CircularChartWidget()),

                // ── Summary cards (horizontal scroll) ────────────────────
                SliverToBoxAdapter(child: _SummaryRow()),

                // ── Recent Transactions heading ───────────────────────────
                SliverToBoxAdapter(child: _RecentHeader()),

                // ── Transaction tiles ─────────────────────────────────────
                SliverToBoxAdapter(child: _TransactionList()),

                // Bottom padding so FAB doesn't cover last tile
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Top bar with hamburger + brand + avatar
class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 26, color: Color(0xFF1A1A2E)),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'My',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                TextSpan(
                  text: 'Expense',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable row of 3 summary cards
class _SummaryRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            children: [
              SummaryCardWidget(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Salary',
                amount: controller.salary,
                isDark: true,
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
        ));
  }
}

/// "Recent Transactions" heading + "View All" button
class _RecentHeader extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List of recent transaction tiles
class _TransactionList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
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

/// Bottom navigation bar
class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                onTap: () => Get.toNamed(AppRoutes.MONTHLY_DETAIL),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                onTap: () => Get.toNamed(AppRoutes.PROFILE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF1A237E) : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}