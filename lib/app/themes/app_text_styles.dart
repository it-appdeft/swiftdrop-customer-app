import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle h1 = GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle h2 = GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle h3 = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle h4 = GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle h5 = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle h6 = GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle pLarge = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle pLargeSemiBold = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle pMedium = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle pMediumSemiBold = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle pMediumBold = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle pSmall = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle pSmallSemiBold = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle pXSmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle pXSmallMedium = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static TextStyle label = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.textPrimary);
  static TextStyle caption = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint);
  static TextStyle amount = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.success);
  static TextStyle amountLg = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.success);
  static TextStyle button = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white);
}
