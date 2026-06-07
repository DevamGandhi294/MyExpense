import 'package:get/get.dart';
import 'package:myexpense/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    // onReady fires AFTER the first frame — all bindings are guaranteed
    // to be registered by this point, so Get.find<AuthService>() is safe.
    super.onReady();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    // AuthService is registered as a permanent GetxService in main.dart via
    // await Get.putAsync(() => AuthService().init());
    // so it is always findable here.
    final auth = Get.find<AuthService>();

    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.SHELL);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}