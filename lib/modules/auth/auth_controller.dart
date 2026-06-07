import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final phone = ''.obs;
  final password = ''.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool _validate() {
    final phoneVal = phone.value.trim();
    final passVal = password.value.trim();

    if (phoneVal.isEmpty) {
      _showError('Validation Error', 'Please enter your phone number.');
      return false;
    }
    if (phoneVal.length < 6) {
      _showError('Validation Error', 'Please enter a valid phone number.');
      return false;
    }
    if (passVal.isEmpty) {
      _showError('Validation Error', 'Please enter your password.');
      return false;
    }
    if (passVal.length < 6) {
      _showError('Validation Error', 'Password must be at least 6 characters.');
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!_validate()) return;

    isLoading.value = true;
    try {
      await _authService.login(
        phone.value.trim(),
        password.value.trim(),
      );
      // Navigation is handled by AuthService / app-level auth stream
    } catch (e) {
      final message = _friendlyError(e.toString());
      _showError('Login Failed', message);
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found')) return 'No account found for this number.';
    if (raw.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (raw.contains('invalid-email')) return 'Invalid phone number format.';
    if (raw.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    if (raw.contains('network-request-failed')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF4757),
      colorText: const Color(0xFFFFFFFF),
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }
}