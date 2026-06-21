import 'package:get/get.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/auth/auth_binding.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/auth/register_view.dart';
import '../../modules/main/main_binding.dart';
import '../../modules/main/main_view.dart';
import '../../modules/add_expense/add_expense_binding.dart';
import '../../modules/add_expense/add_expense_view.dart';
import '../../modules/monthly_detail/monthly_detail_binding.dart';
import '../../modules/monthly_detail/monthly_detail_view.dart';
import '../../modules/analytics/analytics_binding.dart';
import '../../modules/analytics/analytics_view.dart';
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
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
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
    GetPage(
      name: AppRoutes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
  ];
}