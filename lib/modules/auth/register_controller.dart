import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/models/user_model.dart';
import 'package:myexpense/data/repositories/auth_repository.dart';
import 'package:myexpense/data/repositories/user_repository.dart';
import 'package:myexpense/data/repositories/category_repository.dart';
import 'package:myexpense/shared/utils/app_toast.dart';
import '../../app/routes/app_routes.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  bool _validate() {
    final n = nameController.text.trim();
    final ph = phoneController.text.trim();
    final pw = passwordController.text.trim();

    if (n.isEmpty) {
      _showError('Validation Error', 'Please enter your name.');
      return false;
    }
    if (ph.isEmpty) {
      _showError('Validation Error', 'Please enter your phone number.');
      return false;
    }
    if (ph.length < 6) {
      _showError('Validation Error', 'Please enter a valid phone number.');
      return false;
    }
    if (pw.isEmpty) {
      _showError('Validation Error', 'Please enter a password.');
      return false;
    }
    if (pw.length < 6) {
      _showError('Validation Error', 'Password must be at least 6 characters.');
      return false;
    }
    return true;
  }

  Future<void> register() async {
    if (!_validate()) return;

    isLoading.value = true;
    final n = nameController.text.trim();
    final ph = phoneController.text.trim();
    final pw = passwordController.text.trim();

    try {
      await _authRepository.signUp(n, ph, pw);

      final userModel = UserModel(
        name: n,
        phone: ph,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(userModel);

      await _categoryRepository.seedDefaultCategories();

      AppToast.success('Success', 'Account created successfully!');

      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      _showError('Registration Failed', _friendlyError(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'An account already exists for this number.';
    }
    if (raw.contains('weak-password')) {
      return 'The password is too weak.';
    }
    if (raw.contains('invalid-email')) {
      return 'Invalid phone number format.';
    }
    if (raw.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _showError(String title, String message) {
    AppToast.error(title, message);
  }
}
