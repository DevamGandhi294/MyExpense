import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/shared/widgets/app_loader.dart';
import 'package:myexpense/shared/widgets/hand_and_bag_logo.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    const HandAndBagLogo(size: 90),
                    const SizedBox(height: 20),
                    Text(
                      'create_account'.tr,
                      style: const TextStyle(
                        color: AppColors.accentPurple,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'join_app'.tr,
                style: const TextStyle(
                  color: AppColors.brandTextDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'start_tracking'.tr,
                style: const TextStyle(
                  color: AppColors.brandTextMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 28),

              _FieldLabel('full_name'.tr),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.nameController,
                hintText: 'Enter name',
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 18),

              _FieldLabel('phone_number'.tr),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.phoneController,
                hintText: 'Enter phone',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              _FieldLabel('password'.tr),
              const SizedBox(height: 6),
              Obx(() => CustomTextField(
                    controller: controller.passwordController,
                    hintText: 'Enter password',
                    obscureText: controller.isPasswordHidden.value,
                    suffixIcon: IconButton(
                      onPressed: controller.togglePasswordVisibility,
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.brandTextMuted,
                        size: 20,
                      ),
                      splashRadius: 18,
                    ),
                  )),

              const SizedBox(height: 28),

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        disabledBackgroundColor: AppColors.lightPurple.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const AppLoader(size: 36)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'register'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  )),

              const SizedBox(height: 28),

              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: 'already_have_account'.tr,
                      style: const TextStyle(
                        color: AppColors.brandTextMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'login'.tr,
                          style: const TextStyle(
                            color: AppColors.accentPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF5A5A6E),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
