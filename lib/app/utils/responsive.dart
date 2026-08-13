import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive {
  Responsive._();

  // Screen dimensions via GetX (use inside widgets after context is ready)
  static double get width => Get.width;
  static double get height => Get.height;

  // Screen type breakpoints (phone-first)
  static bool get isSmallPhone => width < 360;
  static bool get isPhone => width >= 360 && width < 600;
  static bool get isTablet => width >= 600;

  // Percentage helpers
  static double hp(double percent) => height * percent / 100;
  static double wp(double percent) => width * percent / 100;

  // Context-based percentage helpers (preferred inside build())
  static double hpc(BuildContext context, double percent) =>
      MediaQuery.sizeOf(context).height * percent / 100;
  static double wpc(BuildContext context, double percent) =>
      MediaQuery.sizeOf(context).width * percent / 100;

  // Scaled font/icon size — baseline 375px (iPhone SE/14 logical width)
  static double sp(double size) {
    final scale = (width / 375.0).clamp(0.85, 1.25);
    return size * scale;
  }

  // Safe area
  static double get statusBarHeight => Get.statusBarHeight;
  static double get bottomSafeArea => Get.bottomBarHeight;

  // Clamped dimension — useful for components that should not grow too large
  static double clamp(double value, double min, double max) =>
      value.clamp(min, max);
}

/// GetX / ScreenUtil style responsive extensions on num (.h, .w, .sp, .r, .p)
extension ResponsiveNumExtension on num {
  /// Responsive height scaled relative to baseline (812px)
  double get h => (Responsive.height * (toDouble() / 812.0)).clamp(toDouble() * 0.8, toDouble() * 1.3);

  /// Responsive width scaled relative to baseline (375px)
  double get w => (Responsive.width * (toDouble() / 375.0)).clamp(toDouble() * 0.8, toDouble() * 1.3);

  /// Scaled font or icon size
  double get sp => Responsive.sp(toDouble());

  /// Scaled radius
  double get r => (Responsive.width * (toDouble() / 375.0)).clamp(toDouble() * 0.8, toDouble() * 1.2);

  /// Scaled padding
  double get p => (Responsive.width * (toDouble() / 375.0)).clamp(toDouble() * 0.8, toDouble() * 1.2);
}
