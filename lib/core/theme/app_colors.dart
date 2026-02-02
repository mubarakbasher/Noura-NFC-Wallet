import 'package:flutter/material.dart';

/// App Color Palette - RedotPay-inspired fintech colors
/// Professional, modern, and trustworthy color scheme
class AppColors {
  AppColors._();

  // ============ PRIMARY COLORS ============
  static const Color primaryTeal = Color(0xFF00B8A9);
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color primaryDeep = Color(0xFF1E3A8A);
  
  // ============ GRADIENTS ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF00B8A9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ SECONDARY COLORS ============
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryPink = Color(0xFFEC4899);
  static const Color secondaryOrange = Color(0xFFF59E0B);

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ============ NEUTRAL COLORS ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ============ LIGHT MODE SURFACE COLORS ============
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // ============ DARK MODE SURFACE COLORS ============
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF374151);

  // ============ TEXT COLORS ============
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // ============ OVERLAY COLORS ============
  static Color overlayLight = black.withOpacity(0.5);
  static Color overlayDark = black.withOpacity(0.7);
  
  static Color shimmerBase = grey200;
  static Color shimmerHighlight = grey50;
  static Color shimmerBaseDark = grey700;
  static Color shimmerHighlightDark = grey600;

  // ============ SHADOW COLORS ============
  static Color shadowPrimary = primaryBlue.withOpacity(0.3);
  static Color shadowSuccess = success.withOpacity(0.3);
  static Color shadowError = error.withOpacity(0.3);
  static Color shadowDefault = black.withOpacity(0.1);
}
