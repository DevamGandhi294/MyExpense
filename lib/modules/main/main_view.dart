import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_controller.dart';
import '../home/home_view.dart';
import '../analytics/analytics_view.dart';
import '../profile/profile_view.dart';
import '../savings/savings_view.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => IndexedStack(
                index: controller.selectedIndex.value,
                children: const [
                  HomeView(),
                  AnalyticsView(),
                  SavingsView(),
                  ProfileView(),
                ],
              )),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigationBar(),
          ),
        ],
      ),
    );
  }
}
