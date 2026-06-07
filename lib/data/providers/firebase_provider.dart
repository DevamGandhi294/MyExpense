import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';
import '../services/month_service.dart';
import '../services/expense_service.dart';
import '../services/category_service.dart';

class FirebaseProvider {
  static void init() {
    Get.put(FirestoreService(), permanent: true);
    Get.put(AuthService(),      permanent: true);
    Get.put(UserService(),      permanent: true);
    Get.put(MonthService(),     permanent: true);
    Get.put(ExpenseService(),   permanent: true);
    Get.put(CategoryService(),  permanent: true);
  }
}