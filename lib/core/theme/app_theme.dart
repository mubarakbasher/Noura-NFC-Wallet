import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App Theme Configuration
/// Provides light and dark theme with RedotPay-inspired fintech design
class AppTheme {
  AppTheme._();

  // ============ SPACING SCALE ============
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ============ BORDER RADIUS ============
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircle = 999.0;

  // ============ ELEVATION/SHADOW ============
  static const double elevation1 = 2.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 12.0;
  static const double elevation5 = 16.0;

  /// Custom shadow for cards with colored glow
  static List<BoxShadow> cardShadow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.shadowDefault).withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Elevated shadow with colored glow
  static List<BoxShadow> elevatedShadow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.shadowDefault).withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Primary gradient shadow (for balance card)
  static List<BoxShadow> primaryGradientShadow = [
    BoxShadow(
      color: AppColors.shadowPrimary,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // ============ LIGHT THEME ============
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryPurple,
      tertiary: AppColors.primaryTeal,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: AppColors.white,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardLight,
      shadowColor: AppColors.shadowDefault,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: space24,
          vertical: space16,
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.all(space16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiaryLight,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: elevation3,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textSecondaryLight,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: space16,
    ),
  );

  // ============ DARK THEME ============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryTeal,
      secondary: AppColors.secondaryPurple,
      tertiary: AppColors.primaryBlue,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.black,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardDark,
      shadowColor: AppColors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: space24,
          vertical: space16,
        ),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.black,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryTeal,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.all(space16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiaryDark,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: elevation3,
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryDark),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryDark),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryDark),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryDark),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryDark),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryDark),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryDark),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiaryDark),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textSecondaryDark,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.grey700,
      thickness: 1,
      space: space16,
    ),
  );
}
