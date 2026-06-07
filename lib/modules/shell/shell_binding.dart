// lib/app/modules/shell/shell_binding.dart
import 'package:get/get.dart';
import 'shell_controller.dart';
import '../profile/profile_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}