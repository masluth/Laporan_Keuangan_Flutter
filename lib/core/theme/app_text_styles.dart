import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headlines
  static TextStyle headlineLarge({Color color = AppColors.textPrimaryLight}) {
    return GoogleFonts.inter(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      height: 1.33,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle headlineMedium({Color color = AppColors.textPrimaryLight}) {
    return GoogleFonts.inter(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle headlineSmall({Color color = AppColors.textPrimaryLight}) {
    return GoogleFonts.inter(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: color,
    );
  }

  // Body
  static TextStyle bodyLarge({Color color = AppColors.textPrimaryLight}) {
    return GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.textPrimaryLight}) {
    return GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 1.43,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.textSecondaryLight}) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: color,
    );
  }

  // Labels & Data
  static TextStyle labelMedium({Color color = AppColors.textSecondaryLight}) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: color,
    );
  }

  static TextStyle numericData({Color color = AppColors.textPrimaryLight, double fontSize = 18.0}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color,
    );
  }
}
