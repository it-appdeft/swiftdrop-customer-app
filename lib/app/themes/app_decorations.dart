import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.darkBorder, width: 0.5),
  );

  static BoxDecoration cardElevated = BoxDecoration(
    color: AppColors.darkSurfaceElevated,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.darkBorder, width: 0.5),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration input = BoxDecoration(
    color: AppColors.darkInputBg,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.darkBorder),
  );

  static BoxDecoration inputFocused = BoxDecoration(
    color: AppColors.darkInputBg,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.primary, width: 1.5),
  );

  static BoxDecoration surface = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: AppRadius.md,
  );

  static BoxDecoration primaryButton = BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppRadius.lg,
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration bottomSheet = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: AppRadius.topXl,
  );

  static BoxDecoration badge({required Color color}) => BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: AppRadius.full,
    border: Border.all(color: color.withOpacity(0.3)),
  );

  static BoxDecoration otpBox = BoxDecoration(
    color: AppColors.darkInputBg,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.darkBorder),
  );

  static BoxDecoration otpBoxFocused = BoxDecoration(
    color: AppColors.darkInputBg,
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.primary, width: 1.5),
  );
}
