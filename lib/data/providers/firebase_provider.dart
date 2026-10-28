import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';
import '../repositories/month_repository.dart';
import '../repositories/month_repository_impl.dart';
import '../repositories/expense_repository.dart';
import '../repositories/expense_repository_impl.dart';
import '../repositories/category_repository.dart';
import '../repositories/category_repository_impl.dart';
import '../repositories/savings_repository.dart';
import '../repositories/savings_repository_impl.dart';
import '../repositories/debt_repository.dart';
import '../repositories/debt_repository_impl.dart';

class FirebaseProvider {
  static void init() {
    Get.put(FirestoreService(), permanent: true);
    Get.put<AuthRepository>(AuthRepositoryImpl(), permanent: true);
    Get.put<UserRepository>(UserRepositoryImpl(), permanent: true);
    Get.put<SavingsRepository>(SavingsRepositoryImpl(), permanent: true);
    Get.put<MonthRepository>(MonthRepositoryImpl(), permanent: true);
    Get.put<ExpenseRepository>(ExpenseRepositoryImpl(), permanent: true);
    Get.put<DebtRepository>(DebtRepositoryImpl(), permanent: true);
    Get.put<CategoryRepository>(CategoryRepositoryImpl(), permanent: true);
  }
}