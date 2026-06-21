import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import '../analytics_controller.dart';

class MonthSelectorWidget extends GetView<AnalyticsController> {
  const MonthSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final hasPrev = controller.hasPreviousMonth;
        final hasNext = controller.hasNextMonth;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous month button (left chevron)
            IconButton(
              icon: Icon(
                Icons.chevron_left_rounded,
                color: hasPrev ? AppColors.accentPurple : Colors.grey.shade300,
                size: 28,
              ),
              onPressed: hasPrev ? controller.previousMonth : null,
            ),

            // Month text
            Expanded(
              child: Center(
                child: Text(
                  controller.monthTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),

            // Next month button (right chevron)
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                color: hasNext ? AppColors.accentPurple : Colors.grey.shade300,
                size: 28,
              ),
              onPressed: hasNext ? controller.nextMonth : null,
            ),
          ],
        );
      }),
    );
  }
}
