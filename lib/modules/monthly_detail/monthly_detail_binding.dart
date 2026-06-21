import 'package:get/get.dart';
import 'package:myexpense/data/repositories/expense_repository.dart';
import 'package:myexpense/data/repositories/month_repository.dart';
import 'monthly_detail_controller.dart';

class MonthlyDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyDetailController>(
      () => MonthlyDetailController(
        monthService: Get.find<MonthRepository>(),
        expenseService: Get.find<ExpenseRepository>(),
      ),
    );
  }
}