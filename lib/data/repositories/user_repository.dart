import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser();
  Future<void> createUser(UserModel user);
  Future<void> updateUser(Map<String, dynamic> data);
}
