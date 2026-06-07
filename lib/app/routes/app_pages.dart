import 'package:get/get.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/auth/auth_binding.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/shell/shell_binding.dart';
import '../../modules/shell/shell_view.dart';
import '../../modules/add_expense/add_expense_binding.dart';
import '../../modules/add_expense/add_expense_view.dart';
import '../../modules/monthly_detail/monthly_detail_binding.dart';
import '../../modules/monthly_detail/monthly_detail_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SHELL,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_EXPENSE,
      page: () => const AddExpenseView(),
      binding: AddExpenseBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.MONTHLY_DETAIL,
      page: () => const MonthlyDetailView(),
      binding: MonthlyDetailBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}