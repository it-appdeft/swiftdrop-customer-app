import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../export.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? prefixIcon;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = textColor ?? AppColors.buttonLabel;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onTap?.call();
                    },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bg),
                foregroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(8.0),
                ),
              ),
              child: _buildChild(bg),
            )
          : ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onTap?.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                disabledBackgroundColor: bg.withValues(alpha: 0.5),
                disabledForegroundColor: fg.withValues(alpha: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(8.0),
                ),
              ),
              child: _buildChild(fg),
            ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (prefixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          prefixIcon!,
          const SizedBox(width: AppDimensions.gapSm),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color)),
        ],
      );
    }

    return Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color));
  }
}
