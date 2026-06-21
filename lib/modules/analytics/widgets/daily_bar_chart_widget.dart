import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import '../analytics_controller.dart';

class DailyBarChartWidget extends GetView<AnalyticsController> {
  const DailyBarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x0F000000),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final days = controller.barChartDays;
        final dailyTotals = controller.dailyTotals;
        final isFullView = controller.isFullMonthView.value;

        // Calculate max Y to scale the chart nicely
        double maxVal = 0;
        for (final d in days) {
          final amt = dailyTotals[d.day] ?? 0.0;
          if (amt > maxVal) maxVal = amt;
        }
        // Round up to nearest nice interval
        if (maxVal == 0) maxVal = 1000;
        final maxY = (maxVal * 1.15).ceilToDouble();

        // Build bar groups
        final barGroups = List.generate(days.length, (index) {
          final date = days[index];
          final amount = dailyTotals[date.day] ?? 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.brandPrimaryLight,
                    AppColors.accentPurple,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: isFullView ? 12 : 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: const Color(0xFFF1EEFC),
                ),
              ),
            ],
          );
        });

        // X-axis labels
        Widget getBottomTitles(double value, TitleMeta meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= days.length) return const SizedBox();
          final date = days[idx];

          String text = '';
          if (isFullView) {
            // Only show labels every 5 days to avoid crowding
            if (date.day == 1 || date.day % 5 == 0 || date.day == days.last.day) {
              text = '${date.day}';
            }
          } else {
            text = DateFormat('E\nd').format(date);
          }

          return SideTitleWidget(
            meta: meta,
            space: 8,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          );
        }

        Widget chartWidget = SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.neutral800,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = days[group.x.toInt()];
                    final formattedDate = DateFormat('d MMM').format(date);
                    final formattedAmt = NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 0,
                    ).format(rod.toY);

                    return BarTooltipItem(
                      '$formattedDate\n$formattedAmt',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 34,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + View Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Spending',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),

                // Pill Selector
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildPillTab('7 Days', !isFullView, () {
                        controller.isFullMonthView.value = false;
                      }),
                      _buildPillTab('Full Month', isFullView, () {
                        controller.isFullMonthView.value = true;
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart area
            isFullView
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: days.length * 26.0 + 32.0, // Scrollable width
                      child: chartWidget,
                    ),
                  )
                : chartWidget,
          ],
        );
      }),
    );
  }

  Widget _buildPillTab(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.accentPurple : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
