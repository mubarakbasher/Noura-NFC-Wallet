import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Text Styles - Typography system
/// Using Google Fonts: Inter for body, Outfit for display
class AppTextStyles {
  AppTextStyles._();

  // ============ DISPLAY STYLES ============
  static TextStyle displayLarge = GoogleFonts.outfit(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle displayMedium = GoogleFonts.outfit(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle displaySmall = GoogleFonts.outfit(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============ HEADLINE STYLES ============
  static TextStyle headlineLarge = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle headlineSmall = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============ TITLE STYLES ============
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============ BODY STYLES ============
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============ LABEL STYLES ============
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============ CUSTOM STYLES FOR WALLET ============
  
  /// Large balance display
  static TextStyle balanceAmount = GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.0,
    color: AppColors.white,
  );

  /// Currency symbol for balance
  static TextStyle balanceCurrency = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.0,
  );

  /// Transaction amount
  static TextStyle transactionAmount = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.0,
  );

  /// Card number on virtual card
  static TextStyle cardNumber = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    height: 1.0,
    color: AppColors.white,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Button text
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  /// Chip/Tag text
  static TextStyle chip = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );
}
