import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class AuthService extends GetxService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn   => currentUser != null;

  // Phone + password login
  // phone used as email: phone@myexpense.app
  Future<void> login(String phone, String password) async {
    final email = '${phone.replaceAll(' ', '')}@myexpense.app';
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  Future<void> changePassword(String newPassword) async {
    await currentUser!.updatePassword(newPassword);
  }
}