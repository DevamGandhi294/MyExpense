import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../add_expense_controller.dart';

class AmountInputWidget extends StatelessWidget {
  const AmountInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddExpenseController>();

    return Column(
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        const Text(
          'AMOUNT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 10),

        // ── ₹ + number input ─────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '₹',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(width: 6),
            IntrinsicWidth(
              child: TextField(
                controller: ctrl.amountController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFCCCCCC),
                  letterSpacing: 1,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFCCCCCC),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.center,
                cursorColor: Color(0xFF6C5CE7),
                cursorWidth: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 