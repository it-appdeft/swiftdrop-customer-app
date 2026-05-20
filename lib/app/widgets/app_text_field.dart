import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_decorations.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? errorText;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onEditingComplete,
    this.errorText,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.maxLines = 1,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.pSmallSemiBold),
          const SizedBox(height: AppDimensions.gapSm),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          focusNode: focusNode,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          style: AppTextStyles.pMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final String countryFlag;
  final String countryCode;
  final VoidCallback? onCountryTap;
  final bool isLightSurface;
  final Widget? suffixAction;
  final bool readOnly;

  const AppPhoneField({
    super.key,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.countryFlag = '🇬🇧',
    this.countryCode = '+44',
    this.onCountryTap,
    this.isLightSurface = false,
    this.suffixAction,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: isLightSurface ? AppDecorations.lightInput : AppDecorations.input,
      child: Row(
        children: [
          GestureDetector(
            onTap: onCountryTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(countryFlag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppDimensions.gapXs),
                  Text(
                    countryCode,
                    style: AppTextStyles.pSmall.copyWith(
                      color: isLightSurface
                          ? AppColors.lightSurfaceText
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.gapXs),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppDimensions.iconSm,
                    color: isLightSurface
                        ? AppColors.lightSurfaceText
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: AppDimensions.inputHeight,
            color: isLightSurface ? AppColors.lightSurfaceBorder : AppColors.darkBorder,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              keyboardType: TextInputType.phone,
              textInputAction: textInputAction,
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.pSmall.copyWith(
                color: isLightSurface ? AppColors.lightSurfaceText : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.transparent,
                hintText: 'Enter Mobile Number',
                hintStyle: AppTextStyles.pSmall.copyWith(
                  color: isLightSurface
                      ? AppColors.lightSurfaceSubtitle
                      : AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterText: '',
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXs,
                ),
              ),
            ),
          ),
          if (suffixAction != null) suffixAction!,
        ],
      ),
    );
  }
}
