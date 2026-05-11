import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
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
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const AppPhoneField({
    super.key,
    this.controller,
    this.onChanged,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: '07700 000000',
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇬🇧', style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppDimensions.gapXs),
            Text('+44', style: AppTextStyles.pMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppDimensions.gapSm),
            Container(width: 1, height: 20, color: AppColors.darkBorder),
          ],
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      onChanged: onChanged,
      errorText: errorText,
      focusNode: focusNode,
      maxLength: 11,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
