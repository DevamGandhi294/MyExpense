import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl extends GetxService implements AuthRepository {
  final _auth = FirebaseAuth.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  bool get isLoggedIn => currentUser != null;

  String _getSyntheticEmail(String phone) =>
      '${phone.replaceAll(' ', '')}@myexpense.app';

  @override
  Future<void> login(String phone, String password) async {
    final email = _getSyntheticEmail(phone);
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp(
      String name, String phone, String password) async {
    final email = _getSyntheticEmail(phone);
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.updateDisplayName(name);
    return cred;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  Future<void> changePassword(String newPassword) async {
    await currentUser!.updatePassword(newPassword);
  }
}
