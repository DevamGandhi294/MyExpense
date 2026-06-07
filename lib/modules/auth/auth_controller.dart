import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _box = GetStorage();

  // ── Storage keys ──────────────────────────────────────────────────────────
  static const _kPhone    = 'cached_phone';
  static const _kPassword = 'cached_password';

  // ── Reactive state ────────────────────────────────────────────────────────
  final phone             = ''.obs;
  final password          = ''.obs;
  final isPasswordHidden  = true.obs;
  final isLoading         = false.obs;

  final phoneController    = TextEditingController();
  final passwordController = TextEditingController();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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

  // ── Credential cache ──────────────────────────────────────────────────────

  /// Pre-fills fields with the last successfully used phone/password so the
  /// user never has to retype them after a session expiry.
  void _loadCachedCredentials() {
    final cachedPhone    = _box.read<String>(_kPhone)    ?? '';
    final cachedPassword = _box.read<String>(_kPassword) ?? '';

    if (cachedPhone.isNotEmpty) {
      phone.value              = cachedPhone;
      phoneController.text     = cachedPhone;
    }
    if (cachedPassword.isNotEmpty) {
      password.value           = cachedPassword;
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

  // ── Actions ───────────────────────────────────────────────────────────────

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  bool _validate() {
    final ph = phone.value.trim();
    final pw = password.value.trim();

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
    final ph = phone.value.trim();
    final pw = password.value.trim();

    try {
      await _authService.login(ph, pw);

      // ✅ Cache only on success
      _saveCredentials(ph, pw);

      Get.offAllNamed(AppRoutes.SHELL);
    } catch (e) {
      // On bad credentials wipe the stale cache so the user sees empty fields
      // next time rather than re-submitting wrong data automatically.
      _clearCredentials();
      _showError('Login Failed', _friendlyError(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF4757),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }
}

class GetStorage {
  static Future<void> init() async {
    // This is a placeholder to satisfy the reference in main.dart.
    // The actual GetStorage.init() is called in main.dart, so this class
    // won't be used at runtime.
  }

  String? read<String>(String key) {
    // Placeholder method. The real GetStorage will handle this.
    return null;
  }

  void write(String key, String value) {
    // Placeholder method. The real GetStorage will handle this.
  }

  void remove(String key) {
    // Placeholder method. The real GetStorage will handle this.
  }
}