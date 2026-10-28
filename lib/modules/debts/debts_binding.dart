import 'package:get/get.dart';
import 'debts_controller.dart';

class DebtsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebtsController>(() => DebtsController());
  }
}
