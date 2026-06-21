import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;
  bool get isLoggedIn;
  Future<void> login(String phone, String password);
  Future<UserCredential> signUp(String name, String phone, String password);
  Future<void> logout();
  Future<void> changePassword(String newPassword);
}
