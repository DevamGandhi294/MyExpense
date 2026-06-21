import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import '../../modules/main/main_controller.dart';

class AppBottomNavigationBar extends GetView<MainController> {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 8),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    isActive: controller.selectedIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  const SizedBox(width: 14),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    isActive: controller.selectedIndex.value == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                  const SizedBox(width: 14),
                  _NavItem(
                    icon: Icons.person_rounded,
                    isActive: controller.selectedIndex.value == 2,
                    onTap: () => controller.changeTab(2),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    final iconColor = isActive ? AppColors.accentPurple : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
