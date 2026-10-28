import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/savings_model.dart';
import '../../data/repositories/savings_repository.dart';
import '../../shared/utils/category_utils.dart';
import '../../shared/widgets/app_loader.dart';
import '../../shared/widgets/common_sliver_app_bar.dart';
import 'savings_controller.dart';

String _fmt(double amount) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
).format(amount);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0x0F000000), width: 1),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

const _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A2E),
);

class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentPurple,
          onRefresh: controller.loadSavingsData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const CommonSliverAppBar(showLogo: true),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: AppLoader(size: 80)),
                    );
                  }
                  return const Column(
                    children: [
                      _OverallBalanceCard(),
                      _LendBorrowCard(),
                      _SavingsMonthsCard(),
                      _OverallCategoryCard(),
                      SizedBox(height: 100),
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

class _OverallBalanceCard extends GetView<SavingsController> {
  const _OverallBalanceCard();

  @override
  Widget build(BuildContext context) {
    final balance = controller.overallBalance;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.cardGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            _fmt(balance),
            style: TextStyle(
              color: balance < 0 ? const Color(0xFFFFB4B4) : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat('Total Income', controller.totalIncome),
              _stat('Total Spent', controller.totalSpent),
              _stat('Total Saved', controller.totalSaved),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          _fmt(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _LendBorrowCard extends GetView<SavingsController> {
  const _LendBorrowCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Lend & Borrow', style: _titleStyle)),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Refresh totals when coming back from the Lend & Borrow screen
                onPressed: () =>
                    Get.toNamed(AppRoutes.DEBTS)?.then((_) => controller.loadDebts()),
                icon: const Icon(Icons.handshake_outlined, size: 18),
                label: const Text('Open'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  _amount('You will get', controller.toReceive, AppColors.incomeGreen),
                  _amount('You have to give', controller.toPay, AppColors.expenseRed),
                ],
              )),
        ],
      ),
    );
  }

  Widget _amount(String label, double value, Color color) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              _fmt(value),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      );
}

class _SavingsMonthsCard extends GetView<SavingsController> {
  const _SavingsMonthsCard();

  @override
  Widget build(BuildContext context) {
    final list = controller.monthsWithSalary;
    final threshold = _fmt(SavingsRepository.savingsThreshold);
    final total = controller.totalSaved;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Monthly Savings', style: _titleStyle),
              ),
              Text(
                _fmt(total),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: total < 0
                      ? AppColors.expenseRed
                      : AppColors.incomeGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Overall savings across ${list.length} month${list.length == 1 ? '' : 's'} · '
            '${controller.savings.length} reached the $threshold goal',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Add your salary for a month to see savings here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...list.map(
              (m) => _SavingsTile(
                savings: SavingsModel(
                  monthId: m.monthId,
                  month: m.month,
                  year: m.year,
                  salaryAmount: m.salaryAmount,
                  totalExpense: m.totalExpense,
                  savedAmount: controller.savedIn(m),
                  updatedAt: DateTime.now(),
                ),
                reachedGoal: controller.reachedGoal(m),
              ),
            ),
        ],
      ),
    );
  }
}

class _SavingsTile extends StatelessWidget {
  final SavingsModel savings;
  final bool reachedGoal;

  const _SavingsTile({required this.savings, this.reachedGoal = false});

  @override
  Widget build(BuildContext context) {
    final saved = savings.savedAmount;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () =>
          Get.toNamed(AppRoutes.MONTHLY_DETAIL, arguments: savings.monthId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: reachedGoal
                    ? AppColors.tertiary50
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                reachedGoal
                    ? Icons.emoji_events_outlined
                    : Icons.savings_outlined,
                color: reachedGoal
                    ? AppColors.tertiary600
                    : AppColors.neutral500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${savings.month} ${savings.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Income ${_fmt(savings.salaryAmount)} · Spent ${_fmt(savings.totalExpense)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Text(
              saved < 0 ? '- ${_fmt(-saved)}' : '+ ${_fmt(saved)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: saved < 0 ? AppColors.expenseRed : AppColors.incomeGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallCategoryCard extends GetView<SavingsController> {
  const _OverallCategoryCard();

  @override
  Widget build(BuildContext context) {
    final total = controller.totalSpent;
    final cats = controller.overallCategoryExpenses;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Where Your Money Went', style: _titleStyle),
          const SizedBox(height: 4),
          Text(
            'All-time spending by category · tap for details',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          if (cats.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No expenses yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...cats.map(
              (entry) => _CategoryRow(
                name: entry.key,
                amount: entry.value,
                pct: total > 0 ? entry.value / total : 0.0,
                count: controller.countFor(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final double amount;
  final double pct;
  final int count;

  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.pct,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final meta = CategoryUtils.resolve(name);
    final txLabel = count == 1 ? 'transaction' : 'transactions';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () =>
          Get.toNamed(AppRoutes.CATEGORY_DETAIL, arguments: {'category': name}),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meta.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(meta.icon, color: meta.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Text(
                        _fmt(amount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation(meta.color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(pct * 100).toStringAsFixed(1)}% · $count $txLabel',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
