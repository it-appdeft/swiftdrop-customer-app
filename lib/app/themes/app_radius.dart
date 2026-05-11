import 'package:flutter/material.dart';
import 'app_dimensions.dart';

class AppRadius {
  AppRadius._();

  static BorderRadius xs = BorderRadius.circular(AppDimensions.radiusXs);
  static BorderRadius sm = BorderRadius.circular(AppDimensions.radiusSm);
  static BorderRadius md = BorderRadius.circular(AppDimensions.radiusMd);
  static BorderRadius lg = BorderRadius.circular(AppDimensions.radiusLg);
  static BorderRadius xl = BorderRadius.circular(AppDimensions.radiusXl);
  static BorderRadius xxl = BorderRadius.circular(AppDimensions.radiusXxl);
  static BorderRadius full = BorderRadius.circular(AppDimensions.radiusFull);

  static BorderRadius topLg = const BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusLg),
    topRight: Radius.circular(AppDimensions.radiusLg),
  );

  static BorderRadius topXl = const BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusXl),
    topRight: Radius.circular(AppDimensions.radiusXl),
  );
}
