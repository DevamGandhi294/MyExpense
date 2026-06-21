import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myexpense/data/repositories/auth_repository.dart';
import 'package:myexpense/shared/utils/app_toast.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final _box = GetStorage();

  static const _kPhone    = 'cached_phone';
  static const _kPassword = 'cached_password';

  final isPasswordHidden  = true.obs;
  final isLoading         = false.obs;

  final phoneController    = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadCachedCredentials();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _loadCachedCredentials() {
    final cachedPhone    = _box.read<String>(_kPhone)    ?? '';
    final cachedPassword = _box.read<String>(_kPassword) ?? '';

    if (cachedPhone.isNotEmpty) {
      phoneController.text     = cachedPhone;
    }
    if (cachedPassword.isNotEmpty) {
      passwordController.text  = cachedPassword;
    }
  }

  void _saveCredentials(String ph, String pw) {
    _box.write(_kPhone,    ph);
    _box.write(_kPassword, pw);
  }

  void _clearCredentials() {
    _box.remove(_kPhone);
    _box.remove(_kPassword);
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  bool _validate() {
    final ph = phoneController.text.trim();
    final pw = passwordController.text.trim();

    if (ph.isEmpty) {
      _showError('Validation Error', 'Please enter your phone number.');
      return false;
    }
    if (ph.length < 6) {
      _showError('Validation Error', 'Please enter a valid phone number.');
      return false;
    }
    if (pw.isEmpty) {
      _showError('Validation Error', 'Please enter your password.');
      return false;
    }
    if (pw.length < 6) {
      _showError('Validation Error', 'Password must be at least 6 characters.');
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!_validate()) return;

    isLoading.value = true;
    final ph = phoneController.text.trim();
    final pw = passwordController.text.trim();

    try {
      await _authRepository.login(ph, pw);

      _saveCredentials(ph, pw);

      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      _clearCredentials();
      _showError('Login Failed', _friendlyError(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))        return 'No account found for this number.';
    if (raw.contains('wrong-password'))        return 'Incorrect password. Please try again.';
    if (raw.contains('invalid-credential'))    return 'Incorrect phone or password.';
    if (raw.contains('invalid-email'))         return 'Invalid phone number format.';
    if (raw.contains('too-many-requests'))     return 'Too many attempts. Try again later.';
    if (raw.contains('network-request-failed'))return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }

  void _showError(String title, String message) {
    AppToast.error(title, message);
  }
}