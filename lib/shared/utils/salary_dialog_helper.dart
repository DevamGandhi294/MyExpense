import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'package:myexpense/data/repositories/month_repository.dart';
import 'package:myexpense/shared/utils/app_toast.dart';

class SalaryDialogHelper {
  static void showEditSalaryDialog({
    required String monthId,
    required double currentSalary,
    required VoidCallback onSuccess,
  }) {
    final textController = TextEditingController(
      text: currentSalary > 0 ? currentSalary.toStringAsFixed(0) : '',
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        title: const Text(
          'Set Monthly Salary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your salary or budget limit for this month ($monthId).',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: textController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 50000',
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPurple,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accentPurple,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amt = double.tryParse(value.trim());
                  if (amt == null || amt < 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final salary = double.parse(textController.text.trim());
                Get.back(); // close dialog
                
                try {
                  final mr = Get.find<MonthRepository>();
                  await mr.updateSalary(monthId, salary);
                  AppToast.success('Success', 'Salary updated successfully');
                  onSuccess();
                } catch (e) {
                  AppToast.error('Error', 'Failed to update salary: $e');
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
