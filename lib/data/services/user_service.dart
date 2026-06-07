import 'package:get/get.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class UserService extends GetxService {
  final _fs = Get.find<FirestoreService>();

  Future<UserModel?> getUser() async {
    final snap = await _fs.userDoc.get();
    if (!snap.exists) return null;
    return UserModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  Future<void> createUser(UserModel user) async {
    await _fs.userDoc.set(user.toJson());
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    await _fs.userDoc.update(data);
  }
}