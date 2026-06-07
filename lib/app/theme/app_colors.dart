import 'package:flutter/material.dart';

class AppColors {

  // ── Primary (Deep Blue) ──────────────────────────────
  static const primary50  = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF3B82F6);
  static const primary600 = Color(0xFF2563EB);
  static const primary700 = Color(0xFF1D4ED8);
  static const primary800 = Color(0xFF1E40AF);
  static const primary    = Color(0xFF1E3A8A); // base
  static const primary900 = Color(0xFF1E3A8A);

  // ── Secondary (Purple) ───────────────────────────────
  static const secondary50  = Color(0xFFF5F3FF);
  static const secondary100 = Color(0xFFEDE9FE);
  static const secondary200 = Color(0xFFDDD6FE);
  static const secondary300 = Color(0xFFC4B5FD);
  static const secondary400 = Color(0xFFA78BFA);
  static const secondary500 = Color(0xFF8B5CF6);
  static const secondary600 = Color(0xFF7C3AED);
  static const secondary700 = Color(0xFF6D28D9);
  static const secondary    = Color(0xFF8D2BD9); // base
  static const secondary800 = Color(0xFF5B21B6);
  static const secondary900 = Color(0xFF4C1D95);

  // ── Tertiary (Teal/Green) ────────────────────────────
  static const tertiary50  = Color(0xFFECFDF5);
  static const tertiary100 = Color(0xFFD1FAE5);
  static const tertiary200 = Color(0xFFA7F3D0);
  static const tertiary300 = Color(0xFF6EE7B7);
  static const tertiary400 = Color(0xFF34D399);
  static const tertiary500 = Color(0xFF10B981);  // base
  static const tertiary    = Color(0xFF10B981);
  static const tertiary600 = Color(0xFF059669);
  static const tertiary700 = Color(0xFF047857);
  static const tertiary800 = Color(0xFF065F46);
  static const tertiary900 = Color(0xFF064E3B);

  // ── Neutral ──────────────────────────────────────────
  static const neutral     = Color(0xFFF8FAFC); // base bg
  static const neutral50   = Color(0xFFF8FAFC);
  static const neutral100  = Color(0xFFF1F5F9);
  static const neutral200  = Color(0xFFE2E8F0);
  static const neutral300  = Color(0xFFCBD5E1);
  static const neutral400  = Color(0xFF94A3B8);
  static const neutral500  = Color(0xFF64748B);
  static const neutral600  = Color(0xFF475569);
  static const neutral700  = Color(0xFF334155);
  static const neutral800  = Color(0xFF1E293B);
  static const neutral900  = Color(0xFF0F172A);

  // ── Semantic ─────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);

  // ── Button variants (from UI) ─────────────────────────
  static const buttonPrimary   = primary;           // filled deep blue
  static const buttonSecondary = Color(0xFFE2E8F0); // light grey filled
  static const buttonInverted  = neutral900;         // black filled
  static const buttonOutlined  = Colors.transparent; // outlined only

  // ── Common ───────────────────────────────────────────
  static const white       = Color(0xFFFFFFFF);
  static const black       = Color(0xFF000000);
  static const transparent = Colors.transparent;

  // ── Expense specific ─────────────────────────────────
  static const expenseRed    = Color(0xFFEF4444);  // negative amount
  static const incomeGreen   = Color(0xFF10B981);  // positive income
  static const cardShadow    = Color(0x0F1E293B);  // soft shadow

  // ── Gradient ─────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF8D2BD9),
  ];

  static const List<Color> splashGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF5B21B6),
    Color(0xFF8D2BD9),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1E40AF),
    Color(0xFF7C3AED),
  ];
}