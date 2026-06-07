import 'package:get/get.dart';
import 'package:myexpense/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.SHELL);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}