import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'add_expense_controller.dart';
import 'widgets/amount_input_widget.dart';
import 'widgets/category_chip_widget.dart';
import 'widgets/category_dropdown_widget.dart';

class AddExpenseView extends GetView<AddExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (no AppBar) ───────────────────────────────────────────
            _Header(),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount hero input
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: const AmountInputWidget(),
                    ),

                    const SizedBox(height: 20),

                    // ── Title ────────────────────────────────────────────────
                    _SectionLabel('TITLE'),
                    const SizedBox(height: 6),
                    _RoundedTextField(
                      controller: controller.titleController,
                      hint: 'What did you spend on?',
                      prefixIcon: Icons.receipt_long_outlined,
                    ),

                    const SizedBox(height: 20),

                    // ── Category ─────────────────────────────────────────────
                    _SectionLabel('CATEGORY'),
                    const SizedBox(height: 6),
                    const CategoryDropdownWidget(),
                    const SizedBox(height: 10),
                    const CategoryChipWidget(),

                    const SizedBox(height: 20),

                    // ── Date ─────────────────────────────────────────────────
                    _SectionLabel('DATE'),
                    const SizedBox(height: 6),
                    _DateRow(),

                    const SizedBox(height: 20),

                    // ── Note ─────────────────────────────────────────────────
                    _SectionLabel('NOTE (OPTIONAL)'),
                    const SizedBox(height: 6),
                    _RoundedTextField(
                      controller: controller.noteController,
                      hint: 'Add details...',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Save button (pinned) ─────────────────────────────────────────
            _SaveButton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // X close button – left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF555555)),
              onPressed: () => Get.back(),
              splashRadius: 22,
            ),
          ),

          // Title – center
          const Text(
            'Add Expense',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C5CE7),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Color(0xFF999999),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable rounded text field
// ─────────────────────────────────────────────────────────────────────────────
class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final int maxLines;

  const _RoundedTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
      cursorColor: const Color(0xFF6C5CE7),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        prefixIcon:
            Icon(prefixIcon, size: 18, color: const Color(0xFFBBBBBB)),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 44),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date row
// ─────────────────────────────────────────────────────────────────────────────
class _DateRow extends GetView<AddExpenseController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.openDatePicker(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Text(
                    DateFormat('dd-MM-yyyy')
                        .format(controller.selectedDate.value),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ),
            const Icon(Icons.edit_calendar_outlined,
                size: 18, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save button
// ─────────────────────────────────────────────────────────────────────────────
class _SaveButton extends GetView<AddExpenseController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: GestureDetector(
            onTap:
                controller.isLoading.value ? null : controller.saveExpense,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: controller.isLoading.value
                    ? const LinearGradient(
                        colors: [Color(0xFFBBBBBB), Color(0xFFCCCCCC)],
                      )
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                      ),
                boxShadow: [
                  if (!controller.isLoading.value)
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Save Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ));
  }
}