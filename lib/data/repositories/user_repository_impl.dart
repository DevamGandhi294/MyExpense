import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'user_repository.dart';

class UserRepositoryImpl extends GetxService implements UserRepository {
  final _fs = Get.find<FirestoreService>();

  @override
  Future<UserModel?> getUser() async {
    final snap = await _fs.userDoc.get();
    if (!snap.exists) return null;
    return UserModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _fs.userDoc.set(user.toJson());
  }

  @override
  Future<void> updateUser(Map<String, dynamic> data) async {
    await _fs.userDoc.update(data);
  }
}
