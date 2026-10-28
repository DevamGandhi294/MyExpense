import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/utils/category_utils.dart';
import '../../shared/widgets/app_loader.dart';
import '../../shared/widgets/day_header_widget.dart';
import '../home/widgets/transaction_tile_widget.dart';
import 'category_detail_controller.dart';

String _fmt(double amount) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x0F000000), width: 1),
    );

const _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A2E),
);

class CategoryDetailView extends GetView<CategoryDetailController> {
  const CategoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final meta = CategoryUtils.resolve(controller.category);
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A2E),
        title: Text(
          controller.category,
          style: const TextStyle(
            color: AppColors.accentPurple,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accentPurple,
        onRefresh: controller.loadData,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: AppLoader(size: 80));
          }
          final days = groupExpensesByDay(controller.expenses);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              _SummaryCard(meta: meta),
              if (controller.isAllTime && controller.monthlyTotals.length > 1)
                const _MonthlyCard(),
              if (controller.titleTotals.length > 1) _ItemsCard(color: meta.color),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text('Transactions', style: _titleStyle),
              ),
              if (days.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No transactions',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
                  ),
                ),
              for (final day in days) ...[
                DayHeaderWidget(
                  day: day.key,
                  total: day.value.fold(0.0, (s, e) => s + e.amount),
                  count: day.value.length,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: day.value
                        .map((e) => TransactionTileWidget(expense: e))
                        .toList(),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends GetView<CategoryDetailController> {
  final CategoryMeta meta;

  const _SummaryCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final biggest = controller.biggest;
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.icon, color: meta.color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(controller.scopeLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Total spent',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            _fmt(controller.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Transactions', '${controller.expenses.length}'),
              _stat('Average', _fmt(controller.average)),
              _stat('Biggest', biggest != null ? _fmt(biggest.amount) : '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
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

class _MonthlyCard extends GetView<CategoryDetailController> {
  const _MonthlyCard();

  @override
  Widget build(BuildContext context) {
    final months = controller.monthlyTotals;
    final max = months.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By Month', style: _titleStyle),
          const SizedBox(height: 14),
          ...months.map((m) => _BarRow(
                label: DateFormat('MMM yyyy').format(m.key),
                amount: m.value,
                fraction: max > 0 ? m.value / max : 0,
                color: AppColors.accentPurple,
              )),
        ],
      ),
    );
  }
}

class _ItemsCard extends GetView<CategoryDetailController> {
  final Color color;

  const _ItemsCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final items = controller.titleTotals;
    final total = controller.total;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spent On', style: _titleStyle),
          const SizedBox(height: 14),
          ...items.take(10).map((i) => _BarRow(
                label: i.key,
                amount: i.value,
                fraction: total > 0 ? i.value / total : 0,
                color: color,
                trailing: total > 0
                    ? '${(i.value / total * 100).toStringAsFixed(0)}%'
                    : null,
              )),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double amount;
  final double fraction;
  final Color color;
  final String? trailing;

  const _BarRow({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(trailing!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
              Text(
                _fmt(amount),
                style: const TextStyle(
                  fontSize: 13,
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
              value: fraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.neutral100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
