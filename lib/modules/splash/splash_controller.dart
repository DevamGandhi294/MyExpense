import 'package:get/get.dart';
import 'package:myexpense/data/repositories/auth_repository.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/utils/app_toast.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    try {
      final auth = Get.find<AuthRepository>();

      if (auth.isLoggedIn) {
        Get.offAllNamed(AppRoutes.MAIN);
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      // Usually missing Firebase keys: run with --dart-define-from-file=config.json
      AppToast.error('Firebase not configured', e.toString());
    }
  }
}
