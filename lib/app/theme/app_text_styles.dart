import 'package:flutter/material.dart';
import 'app_colors.dart';

// Font: Inter (as per design system)
class AppTextStyles {

  static const String _font = 'Inter';

  // ── Display ──────────────────────────────────────────
  static const displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── Headline (Inter — from design) ───────────────────
  static const headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
    height: 1.35,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
    height: 1.4,
  );

  // ── Body (Inter — from design) ────────────────────────
  static const bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral800,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral700,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral500,
    height: 1.5,
  );

  // ── Label (Inter — from design) ──────────────────────
  static const labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral700,
    letterSpacing: 0.1,
  );

  static const labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral600,
    letterSpacing: 0.5,
  );

  static const labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral500,
    letterSpacing: 0.5,
  );

  // ── Amount styles (expense specific) ─────────────────
  static const amountHero = TextStyle(
    fontFamily: _font,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral300,
    letterSpacing: -1,
  );

  static const amountLarge = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static const amountMedium = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
    letterSpacing: -0.3,
  );

  static const amountExpense = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.expenseRed,
  );

  static const amountIncome = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.incomeGreen,
  );

  // ── Button text ──────────────────────────────────────
  static const buttonText = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  static const buttonTextDark = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
    letterSpacing: 0.2,
  );

  // ── Input/Form ───────────────────────────────────────
  static const inputText = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral800,
  );

  static const inputHint = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral400,
  );

  static const inputLabel = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral500,
    letterSpacing: 0.8,
  );

  // ── Card / Chip ──────────────────────────────────────
  static const cardTitle = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral500,
  );

  static const cardAmount = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
  );

  static const chipText = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ── Greeting ─────────────────────────────────────────
  static const greeting = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
  );

  static const greetingSubtitle = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral500,
  );

  // ── Splash ───────────────────────────────────────────
  static const splashTitle = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const splashTagline = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xCCFFFFFF),
    letterSpacing: 0.3,
  );
}