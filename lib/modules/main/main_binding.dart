import 'package:get/get.dart';
import 'main_controller.dart';
import '../profile/profile_controller.dart';
import '../home/home_controller.dart';
import '../analytics/analytics_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
