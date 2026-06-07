import 'package:get/get.dart';
import 'package:myexpense/data/services/expense_service.dart';
import 'package:myexpense/data/services/month_service.dart';
import 'monthly_detail_controller.dart';

class MonthlyDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyDetailController>(
      () => MonthlyDetailController(
        monthService: Get.find<MonthService>(),
        expenseService: Get.find<ExpenseService>(),
      ),
    );
  }
}