import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/modules/home/home_controller.dart';

class GreetingHeaderWidget extends GetView<HomeController> {
  const GreetingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  'Hello, ${controller.userName.value} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                )),
                const SizedBox(height: 4),
                Text(
                  controller.monthLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x0F000000)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: AppColors.accentPurple),
                const SizedBox(width: 4),
                const Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.w600,
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